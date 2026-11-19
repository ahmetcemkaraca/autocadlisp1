<#
.SYNOPSIS
  Static checks for the AutoLISP sources (no AutoCAD required).

.DESCRIPTION
  For every file in src/lisp this verifies:
    * parentheses and string quotes are balanced (comments are ignored)
    * top-level forms start at column 0 and indented lines are inside a form
    (catches a misplaced parenthesis even when the file is still balanced)
    * the file is pure ASCII and contains no tab characters
    * every plx: function that is called is also defined
    * no function is defined twice

  Exit code 0 = clean, 1 = problems found.
#>
[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$files = Get-ChildItem -Path (Join-Path $Root 'src/lisp') -Filter '*.lsp' | Sort-Object Name
$problems = New-Object System.Collections.Generic.List[string]

function Remove-LispNoise {
    # Returns the source with comments and string contents blanked out, and
    # reports unbalanced parentheses / quotes through $problems.
    param([string]$Text, [string]$Name)

    $sb = New-Object System.Text.StringBuilder
    $depth = 0
    $line = 1
    $inString = $false
    $stringLine = 0
    $i = 0
    while ($i -lt $Text.Length) {
        $c = $Text[$i]
        if ($c -eq "`n") { $line++ }

        if ($inString) {
            if ($c -eq '\' -and $i + 1 -lt $Text.Length) { $i += 2; [void]$sb.Append('  '); continue }
            if ($c -eq '"') { $inString = $false; [void]$sb.Append('"'); $i++; continue }
            [void]$sb.Append($(if ($c -eq "`n") { "`n" } else { ' ' }))
            $i++
            continue
        }

        if ($c -eq ';') {
            if ($i + 1 -lt $Text.Length -and $Text[$i + 1] -eq '|') {
                # block comment  ;| ... |;
                $end = $Text.IndexOf('|;', $i + 2)
                if ($end -lt 0) { $problems.Add("${Name}:${line}: unterminated block comment"); break }
                $chunk = $Text.Substring($i, $end + 2 - $i)
                $line += ($chunk.ToCharArray() | Where-Object { $_ -eq "`n" }).Count
                [void]$sb.Append(($chunk -replace '[^\n]', ' '))
                $i = $end + 2
                continue
            }
            while ($i -lt $Text.Length -and $Text[$i] -ne "`n") { $i++ }
            continue
        }

        if ($c -eq '"') { $inString = $true; $stringLine = $line; [void]$sb.Append('"'); $i++; continue }

        if ($c -eq '(') { $depth++ }
        elseif ($c -eq ')') {
            $depth--
            if ($depth -lt 0) { $problems.Add("${Name}:${line}: unmatched ')'"); $depth = 0 }
        }
        [void]$sb.Append($c)
        $i++
    }

    if ($inString) { $problems.Add("${Name}:${stringLine}: unterminated string") }
    if ($depth -ne 0) { $problems.Add("${Name}: $depth unclosed '(' at end of file") }
    return $sb.ToString()
}

function Test-LispStructure {
    # Top-level forms must start at column 0 at depth 0; any indented code line
    # must be inside an open form. Works on the output of Remove-LispNoise.
    param([string]$Clean, [string]$Name)

    $depth = 0
    $n = 0
    foreach ($ln in ($Clean -split "`n")) {
        $n++
        $trim = $ln.TrimStart()
        if ($trim.Length -gt 0) {
            if ($ln[0] -eq '(' -and $depth -ne 0) {
                $problems.Add("${Name}:${n}: top-level form starts inside an unclosed form (missing ')' above)")
                $depth = 0
            }
            elseif ($ln[0] -ne '(' -and $depth -eq 0) {
                $problems.Add("${Name}:${n}: indented code outside any form (extra ')' above)")
            }
        }
        $depth += ([regex]::Matches($ln, '\(')).Count - ([regex]::Matches($ln, '\)')).Count
        if ($depth -lt 0) { $depth = 0 }
    }
}
$defined = @{}
$cleaned = @{}

foreach ($file in $files) {
    $name = $file.Name
    $raw = [IO.File]::ReadAllText($file.FullName)

    if ($raw -cmatch '[^\x00-\x7F]') { $problems.Add("${name}: contains non-ASCII characters (use \U+XXXX escapes)") }
    if ($raw.Contains("`t")) { $problems.Add("${name}: contains tab characters") }
    if ($raw.Contains("`r")) { $problems.Add("${name}: contains CR characters (use LF line endings)") }

    $clean = Remove-LispNoise -Text $raw -Name $name
    $cleaned[$name] = $clean
    Test-LispStructure -Clean $clean -Name $name

    foreach ($m in [regex]::Matches($clean, '\(defun\s+([^\s()]+)')) {
        $fn = $m.Groups[1].Value.ToLowerInvariant()
        if ($defined.ContainsKey($fn)) { $problems.Add("${name}: '$fn' is already defined in $($defined[$fn])") }
        else { $defined[$fn] = $name }
    }
}

foreach ($file in $files) {
    $name = $file.Name
    foreach ($m in [regex]::Matches($cleaned[$name], "[\('\s](plx:[a-z0-9\-\*\?!<>=]+)")) {
        $fn = $m.Groups[1].Value.ToLowerInvariant()
        if (-not $defined.ContainsKey($fn)) { $problems.Add("${name}: call to undefined function '$fn'") }
    }
}

if ($problems.Count -gt 0) {
    $problems | ForEach-Object { Write-Host "lint: $_" -ForegroundColor Red }
    Write-Host "lint: $($problems.Count) problem(s) found." -ForegroundColor Red
    exit 1
}

Write-Host "lint: OK ($($files.Count) files, $($defined.Count) functions)" -ForegroundColor Green
