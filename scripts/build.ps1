<#
.SYNOPSIS
  Bundles src/lisp/*.lsp into the single distributable file dist/polyline-tools.lsp.

.PARAMETER Check
  Do not write anything; exit with code 1 if dist/polyline-tools.lsp is not up to date.
#>
[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
$sources = Get-ChildItem -Path (Join-Path $Root 'src/lisp') -Filter '*.lsp' | Sort-Object Name
$target = Join-Path $Root 'dist/polyline-tools.lsp'

$core = [IO.File]::ReadAllText(($sources | Where-Object Name -eq '00-core.lsp').FullName)
if ($core -notmatch '\(setq \*plx-version\* "([^"]+)"\)') { throw 'Version string not found in 00-core.lsp' }
$version = $Matches[1]

$sb = New-Object System.Text.StringBuilder
[void]$sb.Append(";;; polyline-tools.lsp - PolylineTools $version`n")
[void]$sb.Append(";;; GENERATED FILE - do not edit. Edit src/lisp/*.lsp and run scripts/build.ps1.`n")
[void]$sb.Append(";;; https://github.com/ahmetcemkaraca/autocadlisp  (GPL-3.0)`n")

foreach ($file in $sources) {
    $text = [IO.File]::ReadAllText($file.FullName).Replace("`r`n", "`n").TrimEnd("`n")
    [void]$sb.Append("`n;;; ===== $($file.Name) =====`n`n")
    [void]$sb.Append($text)
    [void]$sb.Append("`n")
}
$output = $sb.ToString()

if ($Check) {
    $current = if (Test-Path $target) { [IO.File]::ReadAllText($target).Replace("`r`n", "`n") } else { '' }
    if ($current -ne $output) {
        Write-Host 'build: dist/polyline-tools.lsp is out of date. Run scripts/build.ps1 and commit the result.' -ForegroundColor Red
        exit 1
    }
    Write-Host 'build: dist/polyline-tools.lsp is up to date.' -ForegroundColor Green
    return
}

New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
[IO.File]::WriteAllText($target, $output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "build: wrote dist/polyline-tools.lsp ($version, $($sources.Count) modules)" -ForegroundColor Green
