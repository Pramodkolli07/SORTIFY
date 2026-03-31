param(
  [string]$InputPath = "c:\Users\Dell\OneDrive\Desktop\sortify\assets\logo.png",
  [string]$OutputPath = "c:\Users\Dell\OneDrive\Desktop\sortify\assets\logo-transparent.png",
  [int]$WhiteThreshold = 245
)

Add-Type -AssemblyName System.Drawing

$bmp = New-Object System.Drawing.Bitmap $InputPath
$w = $bmp.Width
$h = $bmp.Height
$thr = $WhiteThreshold

$minX = $w
$minY = $h
$maxX = -1
$maxY = -1

# Find non-white pixels bounding box (so we can tightly crop).
for ($y = 0; $y -lt $h; $y++) {
  for ($x = 0; $x -lt $w; $x++) {
    $c = $bmp.GetPixel($x, $y)
    if (!($c.R -ge $thr -and $c.G -ge $thr -and $c.B -ge $thr)) {
      if ($x -lt $minX) { $minX = $x }
      if ($y -lt $minY) { $minY = $y }
      if ($x -gt $maxX) { $maxX = $x }
      if ($y -gt $maxY) { $maxY = $y }
    }
  }
}

if ($maxX -lt 0 -or $maxY -lt 0) {
  throw "Logo appears fully white; cannot trim."
}

$cropW = $maxX - $minX + 1
$cropH = $maxY - $minY + 1

# Create transparent-cropped logo.
# Use parentheses to force enum evaluation correctly.
$new = New-Object System.Drawing.Bitmap $cropW, $cropH, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = $minY; $y -le $maxY; $y++) {
  for ($x = $minX; $x -le $maxX; $x++) {
    $c = $bmp.GetPixel($x, $y)
    $isWhite = ($c.R -ge $thr -and $c.G -ge $thr -and $c.B -ge $thr)
    if ($isWhite) {
      $new.SetPixel($x - $minX, $y - $minY, [System.Drawing.Color]::FromArgb(0, $c.R, $c.G, $c.B))
    } else {
      $new.SetPixel($x - $minX, $y - $minY, [System.Drawing.Color]::FromArgb(255, $c.R, $c.G, $c.B))
    }
  }
}

$new.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$bmp.Dispose()
$new.Dispose()

Write-Host "Wrote: $OutputPath"

