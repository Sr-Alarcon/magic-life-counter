$root = "D:\Claude test 1\GuilleWeb"
$port = 8123
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"
$mime = @{
  ".html"="text/html; charset=utf-8"; ".js"="application/javascript"; ".css"="text/css";
  ".json"="application/json"; ".webmanifest"="application/manifest+json"; ".png"="image/png";
  ".ttf"="font/ttf"; ".svg"="image/svg+xml"; ".ico"="image/x-icon"
}
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $ctx.Response.KeepAlive = $false
    $ctx.Response.Headers.Add("Cache-Control","no-store")
    $path = [System.Uri]::UnescapeDataString($ctx.Request.Url.LocalPath)
    if ($path -eq "/") { $path = "/index.html" }
    $file = Join-Path $root ($path.TrimStart("/").Replace("/","\"))
    if (Test-Path $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
  } catch {}
}
