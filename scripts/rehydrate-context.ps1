Write-Host "[rehydrate-context] Starting context rehydration..."
$date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$identJson = Get-Content "docs\registry\identifiers.json" -Raw
$endpJson = Get-Content "docs\registry\endpoints.json" -Raw
$schemJson = Get-Content "docs\registry\schemas.json" -Raw

$content = "# Current Context`n`nTarih: $date`n`n## Registry Snapshots`n### identifiers.json`n``````json`n$identJson`n``````n`n### endpoints.json`n``````json`n$endpJson`n``````n`n### schemas.json`n``````json`n$schemJson`n``````"

$content | Out-File ".mds\context\current-context.md" -Encoding UTF8
Write-Host "[rehydrate-context] Wrote .mds\context\current-context.md"
