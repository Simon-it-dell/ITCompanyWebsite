Param(
    [int]$Port = 8000
)

$root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$prefix = "http://localhost:$Port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
    $listener.Start()
} catch {
    Write-Error "Failed to start listener on $prefix. Try running PowerShell as admin. $_"
    exit 1
}
Write-Host "Serving $root at $prefix (press Ctrl+C to stop)"

function Get-MimeType {
    param([string]$file)
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    switch ($ext) {
        '.html' { 'text/html' }
        '.htm' { 'text/html' }
        '.css' { 'text/css' }
        '.js' { 'application/javascript' }
        '.json' { 'application/json' }
        '.png' { 'image/png' }
        '.jpg' { 'image/jpeg' }
        '.jpeg' { 'image/jpeg' }
        '.gif' { 'image/gif' }
        '.svg' { 'image/svg+xml' }
        '.woff' { 'font/woff' }
        '.woff2' { 'font/woff2' }
        '.ttf' { 'font/ttf' }
        '.eot' { 'application/vnd.ms-fontobject' }
        '.xml' { 'application/xml' }
        default { 'application/octet-stream' }
    }
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $req = $context.Request
    $res = $context.Response
    $path = $req.Url.AbsolutePath.TrimStart('/')
    if ($path -eq '') { $path = 'index.html' }
    $filePath = Join-Path $root $path
    if (-not (Test-Path $filePath)) {
        $res.StatusCode = 404
        $data = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $res.ContentType = 'text/plain'
        $res.ContentLength64 = $data.Length
        $res.OutputStream.Write($data,0,$data.Length)
        $res.OutputStream.Close()
        continue
    }
    try {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $res.ContentType = Get-MimeType $filePath
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes,0,$bytes.Length)
    } catch {
        $res.StatusCode = 500
        $data = [System.Text.Encoding]::UTF8.GetBytes("500 Internal Server Error")
        $res.ContentType = 'text/plain'
        $res.ContentLength64 = $data.Length
        $res.OutputStream.Write($data,0,$data.Length)
    } finally {
        $res.OutputStream.Close()
    }
}