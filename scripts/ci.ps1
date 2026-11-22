$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$lune = Join-Path (Get-Location) 'tools/lune.exe'
if (!(Test-Path $lune)) {
    $zip = Join-Path ([IO.Path]::GetTempPath()) ("lune-" + [guid]::NewGuid() + ".zip")
    Invoke-WebRequest 'https://github.com/lune-org/lune/releases/download/v0.11.1/lune-0.11.1-windows-x86_64.zip' -OutFile $zip
    if ((Get-FileHash $zip).Hash -ne '83f1dc29d9e35c494907521f2ca6561f6c204fdf6f1b06525d2e9fdd1e6b4301') { throw 'Lune archive checksum mismatch' }
    Expand-Archive $zip -DestinationPath 'tools' -Force
    Remove-Item -LiteralPath $zip
}
if ((Get-FileHash $lune).Hash -ne '95F4A457317237516C347745BF363AA63DD30C97105C9595E6B8914B29267FDB') { throw 'Lune binary checksum mismatch' }
foreach ($suite in 'tests/hair-materials','tests/appearance-migration','tests/creator-layout','tests/item-images','tests/npc-tactics','tests/npc-reactions','tests/npc-ground','tests/npc-sight','tests/brand-identity') {
    & $lune run $suite
    if ($LASTEXITCODE -ne 0) { throw "$suite failed" }
}
foreach ($suite in 'tests/runtime-errors-unit','tests/save-files','tests/resident-names','tests/resident-models','tests/portrait-visibility','tests/server-directory','tests/retail-unit','tests/custody-unit','tests/home-access','tests/responder-brain','tests/npc-navigation','tests/npc-combat','tests/npc-awareness','build','validate','tests/work-contracts','tests/job-navigation','tests/station-access','tests/map-placement','tests/residential-windows','tests/home-security','tests/home-furnishings','tests/shop-fittings','tests/retail-merchandising','tests/interior-coverage','tests/handling','tests/traffic-phases','tests/map-compass','tests/heritage') {
    & $lune run $suite
    if ($LASTEXITCODE -ne 0) { throw "$suite failed" }
}
$file = 'Northside Baltimore - Heritage Harbor.rbxl'
$commit = git rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot identify release commit' }
@{file=$file;sha256=(Get-FileHash $file).Hash;commit=$commit} | ConvertTo-Json | Set-Content release-hash.json
