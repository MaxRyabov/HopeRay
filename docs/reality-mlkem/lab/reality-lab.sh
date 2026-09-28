#!/usr/bin/env bash
# REALITY compatibility lab: sing-box client x Xray-core REALITY server, all on 127.0.0.1.
#
#   reality-lab.sh <path-to-sing-box-binary> [expect]
#
# expect = pass (default): every case must connect with no "reality verification failed".
# expect = legacy: an unpatched sing-box; prints the matrix and does not fail.
#
# Downloads Xray-core releases into $LAB_DIR (default ./.reality-lab), generates throwaway
# keys, starts one server at a time and drives the client through its local SOCKS inbound.
# The client needs to be built with `-tags with_utls`. Traffic leaves via the servers'
# freedom outbound, so the lab needs internet access. Works in Git Bash, Linux and macOS.
set -u

SB="${1:?usage: reality-lab.sh <sing-box binary> [pass|legacy]}"
EXPECT="${2:-pass}"
LAB_DIR="${LAB_DIR:-./.reality-lab}"
SERVER_PORT=18443
SOCKS_PORT=10829
SNI="${LAB_SNI:-www.google.com}"
UUID="11111111-2222-3333-4444-555555555555"
SHORT_ID="abcd1234"
URLS="https://www.google.com/generate_204 https://www.cloudflare.com/cdn-cgi/trace"

mkdir -p "$LAB_DIR"
LAB_DIR="$(cd "$LAB_DIR" && pwd)"
case "$(uname -s)" in
	MINGW*|MSYS*|CYGWIN*) XRAY_ASSET="Xray-windows-64.zip"; EXE=".exe" ;;
	Darwin) [ "$(uname -m)" = arm64 ] && XRAY_ASSET="Xray-macos-arm64-v8a.zip" || XRAY_ASSET="Xray-macos-64.zip"; EXE="" ;;
	*) [ "$(uname -m)" = aarch64 ] && XRAY_ASSET="Xray-linux-arm64-v8a.zip" || XRAY_ASSET="Xray-linux-64.zip"; EXE="" ;;
esac

fetch_xray() { # $1 = version, prints the binary path
	local dir="$LAB_DIR/xray-$1"
	if [ ! -x "$dir/xray$EXE" ]; then
		mkdir -p "$dir"
		curl -fsSL -o "$dir/xray.zip" "https://github.com/XTLS/Xray-core/releases/download/v$1/$XRAY_ASSET" || { echo "download of Xray $1 failed" >&2; exit 2; }
		(cd "$dir" && unzip -oq xray.zip && chmod +x "xray$EXE")
	fi
	echo "$dir/xray$EXE"
}

wait_port() {
	for _ in $(seq 1 60); do
		(exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null && return 0
		sleep 0.25
	done
	return 1
}

XRAY_NEW="$(fetch_xray 26.9.9)"
XRAY_OLD="$(fetch_xray 26.7.28)"
KEYS="$("$XRAY_NEW" x25519)"
PRIVATE_KEY="$(echo "$KEYS" | sed -n 's/^PrivateKey: *//p' | tr -d '\r')"
PUBLIC_KEY="$(echo "$KEYS" | sed -n 's/^Password (PublicKey): *//p;s/^Public key: *//p' | tr -d '\r')"
[ -n "$PRIVATE_KEY" ] && [ -n "$PUBLIC_KEY" ] || { echo "cannot parse 'xray x25519' output:"; echo "$KEYS"; exit 2; }

write_server() { # $1 = file, $2 = minClientVer ("" to omit)
	local min=""
	[ -n "$2" ] && min="\"minClientVer\": \"$2\","
	cat >"$1" <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "listen": "127.0.0.1", "port": $SERVER_PORT, "protocol": "vless",
    "settings": {"clients": [{"id": "$UUID", "flow": "xtls-rprx-vision"}], "decryption": "none"},
    "streamSettings": {"network": "tcp", "security": "reality", "realitySettings": {
      $min
      "target": "$SNI:443", "serverNames": ["$SNI"],
      "privateKey": "$PRIVATE_KEY", "shortIds": ["$SHORT_ID"]}}
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF
}

write_client() { # $1 = file, $2 = uTLS fingerprint
	cat >"$1" <<EOF
{
  "log": {"level": "warn"},
  "inbounds": [{"type": "socks", "tag": "in", "listen": "127.0.0.1", "listen_port": $SOCKS_PORT}],
  "outbounds": [{
    "type": "vless", "tag": "proxy", "server": "127.0.0.1", "server_port": $SERVER_PORT,
    "uuid": "$UUID", "flow": "xtls-rprx-vision",
    "tls": {"enabled": true, "server_name": "$SNI",
      "utls": {"enabled": true, "fingerprint": "$2"},
      "reality": {"enabled": true, "public_key": "$PUBLIC_KEY", "short_id": "$SHORT_ID"}}
  }]
}
EOF
}

FAILED=0
printf "%-38s %-8s %-4s %s\n" "server" "fp" "ok" "reality_fail"
while read -r label xray minver <&3; do
	[ "$minver" = "-" ] && minver=""
	write_server "$LAB_DIR/server-$label.json" "$minver"
	"$xray" run -c "$LAB_DIR/server-$label.json" >"$LAB_DIR/server-$label.log" 2>&1 &
	server_pid=$!
	wait_port "$SERVER_PORT" || { echo "server $label did not start, see $LAB_DIR/server-$label.log"; exit 2; }
	for fp in firefox chrome safari; do
		write_client "$LAB_DIR/client-$fp.json" "$fp"
		log="$LAB_DIR/client-$label-$fp.log"
		"$SB" run -c "$LAB_DIR/client-$fp.json" >"$log" 2>&1 &
		client_pid=$!
		wait_port "$SOCKS_PORT" || { echo "client did not start, see $log"; kill "$server_pid"; exit 2; }
		ok=0 total=0
		for url in $URLS; do
			total=$((total + 1))
			curl -s -o /dev/null --max-time 20 --socks5-hostname "127.0.0.1:$SOCKS_PORT" "$url" && ok=$((ok + 1))
		done
		kill "$client_pid" 2>/dev/null; wait "$client_pid" 2>/dev/null
		rfail=$(grep -c "reality verification failed" "$log")
		printf "%-38s %-8s %-4s %s\n" "$label" "$fp" "$ok/$total" "$rfail"
		# A slow destination can time out; a REALITY rejection never lets anything through.
		if [ "$rfail" -ne 0 ] || [ "$ok" -eq 0 ]; then FAILED=1; fi
	done
	kill "$server_pid" 2>/dev/null; wait "$server_pid" 2>/dev/null
done 3<<EOF
xray-26.9.9 $XRAY_NEW -
xray-26.9.9+minClientVer=26.3.27 $XRAY_NEW 26.3.27
xray-26.7.28+minClientVer=1.8.0 $XRAY_OLD 1.8.0
EOF

if [ "$EXPECT" = pass ]; then
	[ "$FAILED" -eq 0 ] && echo "RESULT: PASS" || { echo "RESULT: FAIL (logs in $LAB_DIR)"; exit 1; }
fi
