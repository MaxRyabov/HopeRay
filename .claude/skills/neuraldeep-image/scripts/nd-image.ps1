<#
.SYNOPSIS
  NeuralDeep Image API helper — generate / process images and download the result.

.DESCRIPTION
  Wraps the async NeuralDeep Image API (https://api.neuraldeep.ru/v1/images/*):
  creates a task, polls until status=finished, then downloads the binary result.
  Auth token is read from the NEURALDEEP_TOKEN environment variable.

.PARAMETER Action
  generate | upscale | remove-bg | enhance | avatar | quota

.EXAMPLE
  ./nd-image.ps1 -Action generate -Prompt "cosmic cat, neon" -Aspect 16:9 -Out cat.png
.EXAMPLE
  ./nd-image.ps1 -Action upscale -Image photo.jpg -Out photo_4x.png
.EXAMPLE
  ./nd-image.ps1 -Action quota
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateSet('generate','upscale','remove-bg','enhance','avatar','quota')]
  [string]$Action,

  [string]$Prompt,
  [ValidateSet('1:1','9:16','16:9','4:5','3:2','5:3','3:5')]
  [string]$Aspect = '1:1',
  [switch]$NoTranslate,          # disable RU->EN auto-translation of the prompt

  [string]$Image,                # input file for upscale/remove-bg/enhance/avatar
  [string]$Out = 'out.png',      # where to save the produced image

  [int]$TimeoutSec = 180         # max seconds to poll before giving up
)

$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 defaults to TLS 1.0; the API requires 1.2. Harmless on PS 7+.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$Base = 'https://api.neuraldeep.ru/v1/images'

# --- token ---
$token = $env:NEURALDEEP_TOKEN
if (-not $token) { $token = [Environment]::GetEnvironmentVariable('NEURALDEEP_TOKEN','User') }
if (-not $token) { throw 'NEURALDEEP_TOKEN is not set (env var).' }
$auth = @{ Authorization = "Bearer $token" }

function Invoke-Json($Uri, $Method='Get', $Body=$null, $ContentType=$null) {
  $p = @{ Uri = $Uri; Headers = $auth; Method = $Method; TimeoutSec = 60 }
  if ($Body)        { $p.Body = $Body }
  if ($ContentType) { $p.ContentType = $ContentType }
  try {
    return (Invoke-WebRequest @p).Content | ConvertFrom-Json
  } catch {
    $msg = $_.Exception.Message
    if ($_.ErrorDetails.Message) { $msg += " :: " + $_.ErrorDetails.Message }
    throw "API call failed ($Uri): $msg"
  }
}

# Manual multipart/form-data upload. Invoke-WebRequest -Form is PowerShell 7+ only,
# so we build the body bytes by hand to also work in Windows PowerShell 5.1.
function Invoke-Multipart($Uri, $FilePath, $FieldName='image') {
  $fileName  = [System.IO.Path]::GetFileName($FilePath)
  $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
  $boundary  = '----ndimage' + [guid]::NewGuid().ToString('N')
  $crlf      = "`r`n"
  $ctype     = switch ([System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()) {
    '.png'  { 'image/png' }
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.webp' { 'image/webp' }
    default { 'application/octet-stream' }
  }
  $enc    = [System.Text.Encoding]::UTF8
  $header = "--$boundary$crlf" +
            "Content-Disposition: form-data; name=`"$FieldName`"; filename=`"$fileName`"$crlf" +
            "Content-Type: $ctype$crlf$crlf"
  $footer = "$crlf--$boundary--$crlf"
  $ms = New-Object System.IO.MemoryStream
  try {
    $hb = $enc.GetBytes($header); $ms.Write($hb, 0, $hb.Length)
    $ms.Write($fileBytes, 0, $fileBytes.Length)
    $fb = $enc.GetBytes($footer); $ms.Write($fb, 0, $fb.Length)
    $bodyBytes = $ms.ToArray()
  } finally {
    $ms.Dispose()
  }
  try {
    return (Invoke-WebRequest -Uri $Uri -Headers $auth -Method Post `
      -ContentType "multipart/form-data; boundary=$boundary" `
      -Body $bodyBytes -TimeoutSec 60).Content | ConvertFrom-Json
  } catch {
    $msg = $_.Exception.Message
    if ($_.ErrorDetails.Message) { $msg += " :: " + $_.ErrorDetails.Message }
    throw "API call failed ($Uri): $msg"
  }
}

# --- quota: print and exit ---
if ($Action -eq 'quota') {
  Invoke-Json "$Base/quota" | ConvertTo-Json -Depth 6
  return
}

# --- create the task ---
if ($Action -eq 'generate') {
  if (-not $Prompt) { throw '-Prompt is required for generate.' }
  $payload = @{ prompt = $Prompt; options = @{ aspect_ratio = $Aspect } }
  if ($NoTranslate) { $payload.translate = $false }
  $bodyJson = $payload | ConvertTo-Json -Depth 6 -Compress
  Write-Host "Generating (aspect $Aspect)..." -ForegroundColor Cyan
  $job = Invoke-Json "$Base/generate" 'Post' $bodyJson 'application/json'
}
else {
  if (-not $Image)              { throw "-Image is required for '$Action'." }
  if (-not (Test-Path $Image))  { throw "Input image not found: $Image" }
  $endpoint = switch ($Action) {
    'upscale'   { "$Base/upscale" }
    'remove-bg' { "$Base/background/remove" }
    'enhance'   { "$Base/enhance" }
    'avatar'    { "$Base/avatar" }
    default     { throw "Unknown action: $Action" }
  }
  Write-Host "Processing ($Action) $Image ..." -ForegroundColor Cyan
  $job = Invoke-Multipart $endpoint $Image 'image'
}

$uid = $job.task_uid
if (-not $uid) { throw "No task_uid in response: $($job | ConvertTo-Json -Depth 6)" }
$pollUrl   = if ($job.poll)   { "https://api.neuraldeep.ru$($job.poll)" }   else { "$Base/tasks/$uid" }
$resultUrl = if ($job.result) { "https://api.neuraldeep.ru$($job.result)" } else { "$Base/tasks/$uid/result" }
if ($job.translated) { Write-Host "Prompt auto-translated -> $($job.prompt_used)" -ForegroundColor DarkGray }
Write-Host "task_uid: $uid" -ForegroundColor DarkGray

# --- poll ---
$deadline = (Get-Date).AddSeconds($TimeoutSec)
$status = $null
while ((Get-Date) -lt $deadline) {
  $st = Invoke-Json $pollUrl
  $status = $st.status
  if ($status -eq 'finished') { break }
  if ($status -in @('failed','error')) { throw "Task $uid $status :: $($st.error)" }
  Start-Sleep -Seconds 2
}
if ($status -ne 'finished') { throw "Timed out after ${TimeoutSec}s (last status: $status). Task $uid may still finish — re-poll $pollUrl." }

# --- download ---
$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
Invoke-WebRequest -Uri $resultUrl -Headers $auth -OutFile $Out -TimeoutSec 60
$fi = Get-Item $Out
Write-Host "Saved $([math]::Round($fi.Length/1KB,1)) KB -> $($fi.FullName)" -ForegroundColor Green
