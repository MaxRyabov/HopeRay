---
name: neuraldeep-image
description: Generate and process graphics for HopeRay via the NeuralDeep Image API (FLUX text-to-image, upscale ×4, background removal, enhance, avatar). Use when the user asks to create an icon, illustration, banner, splash/marketing image, placeholder art, or to upscale/clean up an existing image. Auth via the NEURALDEEP_TOKEN env var.
---

# NeuralDeep Image API

Generate and process images with the same key used for the rest of NeuralDeep
(`NEURALDEEP_TOKEN`). Base URL: `https://api.neuraldeep.ru/v1/images`.

The API is **asynchronous**: a `POST` creates a task and returns a `task_uid`; you
poll the task until `status == "finished"`, then download the image as a **binary**
(raw S3 URLs are not exposed). The fastest path is the bundled helper script — use it
unless you need something it doesn't cover.

## Quick start (preferred): the helper script

`scripts/nd-image.ps1` does create → poll → download in one call. Run it from the repo root.

```powershell
# Text-to-image (prompt may be Russian — auto-translated RU→EN for FLUX)
./.claude/skills/neuraldeep-image/scripts/nd-image.ps1 `
  -Action generate -Prompt "минималистичная иконка ракеты, плоский стиль" -Aspect 1:1 -Out assets/icon.png

# Process an existing image
./.claude/skills/neuraldeep-image/scripts/nd-image.ps1 -Action upscale   -Image in.jpg -Out out.png
./.claude/skills/neuraldeep-image/scripts/nd-image.ps1 -Action remove-bg -Image in.jpg -Out out.png
./.claude/skills/neuraldeep-image/scripts/nd-image.ps1 -Action enhance   -Image in.jpg -Out out.png
./.claude/skills/neuraldeep-image/scripts/nd-image.ps1 -Action avatar    -Image face.jpg -Out avatar.png

# Check remaining quota (does NOT consume any)
./.claude/skills/neuraldeep-image/scripts/nd-image.ps1 -Action quota
```

Params: `-Action` (required), `-Prompt`, `-Aspect` (one of the ratios below, default `1:1`),
`-NoTranslate` (keep the prompt verbatim), `-Image`, `-Out` (default `out.png`),
`-TimeoutSec` (poll budget, default 180). After generating, verify the file with the Read
tool (it renders PNG/JPG) before reporting success.

## Endpoints

| Action      | Endpoint                          | Input                          | Notes |
|-------------|-----------------------------------|--------------------------------|-------|
| generate    | `POST /v1/images/generate`        | JSON `{prompt, options, translate}` | FLUX text-to-image |
| upscale     | `POST /v1/images/upscale`         | multipart `image=@file`        | RealESRGAN ×4 |
| remove-bg   | `POST /v1/images/background/remove` | multipart `image=@file`      | ISNet / RMBG |
| enhance     | `POST /v1/images/enhance`         | multipart `image=@file`        | FLUX enhance |
| avatar      | `POST /v1/images/avatar`          | multipart `image=@file`        | avatar from a photo |
| poll        | `GET /v1/images/tasks/{uid}`      | —                              | returns `status` |
| result      | `GET /v1/images/tasks/{uid}/result` | —                            | binary image bytes |
| quota       | `GET /v1/images/quota`            | —                              | remaining ops |

All requests require header `Authorization: Bearer $NEURALDEEP_TOKEN`.

## Generate request body

```json
{
  "prompt": "a cosmic cat in neon",
  "options": { "aspect_ratio": "1:1" },
  "translate": true
}
```

- **`prompt`** — FLUX understands **English only**. A Cyrillic prompt is auto-translated
  RU→EN. Set top-level **`translate: false`** to send the prompt verbatim.
- **Size is set ONLY via `options.aspect_ratio`.** Allowed: `1:1`, `9:16`, `16:9`, `4:5`,
  `3:2`, `5:3`, `3:5`. `width` / `height` / `size` are **not** supported. Anything missing or
  invalid falls back to `1:1` (the request does not fail). `1:1` renders at 1024×1024.

### POST /generate response
```json
{
  "task_uid": "0b9c04d2-...",
  "prompt_used": "a cosmic cat in neon",
  "translated": false,
  "poll":   "/v1/images/tasks/0b9c04d2-.../",
  "result": "/v1/images/tasks/0b9c04d2-.../result",
  "quota":  { "pool": "img", "day": {...}, "month": {...} }
}
```

### Poll response (`GET /tasks/{uid}`)
`status` progresses to `"finished"` (terminal: also `"failed"` / `"error"` with `error` set):
```json
{ "uid": "...", "status": "finished", "error": null,
  "result": { "filename": "...png", "size": 430493, "mimetype": "image/png",
              "width": 1024, "height": 1024, "result_url": "/v1/images/tasks/.../result" } }
```
Then `GET /tasks/{uid}/result` returns the raw image bytes — save with `-OutFile` / `-o`.

## Quota & cost

- Image ops share a **separate bucket** from chat; available on **all tiers**.
  1 operation = 1 `POST` (create). **Polling and downloading the result are free** — you pay
  only for task creation.
- Free tier seen: **10/day, 50/month**. Check before bulk work with `-Action quota`.
- On exhaustion the API returns **`429`** with a **`Retry-After`** header.

## Raw curl (when the script isn't usable)

```bash
TOKEN="$NEURALDEEP_TOKEN"
# 1. create
uid=$(curl -s https://api.neuraldeep.ru/v1/images/generate \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"prompt":"кот-космонавт, неон","options":{"aspect_ratio":"1:1"}}' | jq -r .task_uid)
# 2. poll until finished
curl -s https://api.neuraldeep.ru/v1/images/tasks/$uid -H "Authorization: Bearer $TOKEN"
# 3. download
curl -s https://api.neuraldeep.ru/v1/images/tasks/$uid/result -H "Authorization: Bearer $TOKEN" -o out.png
# processing (multipart):
curl https://api.neuraldeep.ru/v1/images/upscale -H "Authorization: Bearer $TOKEN" -F "image=@photo.jpg"
```

## Gotchas

- **Generation is GPU-expensive and the queue occasionally stalls** — always keep a poll
  timeout (the script uses 180s). On timeout the task may still finish; re-poll the `poll` URL.
- **Don't burn quota on trivial tests** — free tier is tight (10/day). Reuse `quota` to check.
- For app assets, prefer an explicit aspect ratio that matches the target slot (e.g. `9:16`
  for a phone splash, `16:9` for a banner) rather than relying on the `1:1` fallback.
- FLUX output is raster PNG. For crisp UI icons that need to scale, treat results as source
  art / placeholders — the project's real icons live in `assets/` and platform resource dirs.
