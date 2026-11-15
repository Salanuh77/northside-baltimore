param([Parameter(Mandatory)][long]$RunId, [Parameter(Mandatory)][int]$ExpectedVersion)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$repo = 'Salanuh77/northside-baltimore'
$run = gh run view $RunId -R $repo --json headSha,headBranch,event,conclusion,workflowName | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $run.workflowName -ne 'Northside CI' -or $run.event -ne 'push' -or $run.headBranch -ne 'main' -or $run.conclusion -ne 'success') { throw 'A successful main CI run is required' }
$head = git rev-parse HEAD
$tip = gh api "repos/$repo/commits/main" --jq .sha
$dirty = git status --porcelain --untracked-files=no
if ($head -ne $run.headSha -or $tip -ne $head -or $dirty) { throw 'Release scripts and candidate must match the clean current main revision' }
$staging = Join-Path ([IO.Path]::GetTempPath()) ("Northside-release-" + $RunId + "-" + [guid]::NewGuid())
gh run download $RunId -R $repo --name northside-place --dir $staging
if ($LASTEXITCODE -ne 0) { throw 'Artifact download failed' }
$manifest = Get-Content (Join-Path $staging 'release-hash.json') -Raw | ConvertFrom-Json
if ($manifest.file -ne 'Northside Baltimore - Heritage Harbor.rbxl' -or $manifest.commit -ne $head) { throw 'Wrong artifact manifest' }
$place = Join-Path $staging $manifest.file
if ((Get-FileHash $place).Hash -ne $manifest.sha256) { throw 'Artifact checksum mismatch' }
& "$PSScriptRoot/studio-gates.ps1" -Place $place -LogDirectory (Join-Path $staging 'tests')
if ((Get-FileHash $place).Hash -ne $manifest.sha256) { throw 'Tested artifact changed' }
$latest = gh api "repos/$repo/commits/main" --jq .sha
if ($LASTEXITCODE -ne 0 -or $latest -ne $head -or (git status --porcelain --untracked-files=no)) { throw 'Release changed during playtesting' }
& ./tools/lune.exe run publish-api.luau $ExpectedVersion $place $manifest.sha256
if ($LASTEXITCODE -ne 0) { throw 'Publication unconfirmed. Inspect publish receipt before retrying.' }
Copy-Item -LiteralPath $place -Destination $manifest.file -Force
Write-Host "Published $($manifest.file). Evidence in $staging"
