param([Parameter(Mandatory)][string]$Place, [Parameter(Mandatory)][string]$LogDirectory,
    [ValidateSet('homes','server','ui','returning','retail','custody','life','encounters','access')]
    [string[]]$Suites = @('homes','server','ui','returning','retail','custody','life','encounters','access'))
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$candidate = (Resolve-Path $Place).Path
$lune = (Resolve-Path 'tools/lune.exe').Path
$studio = Get-ChildItem "$env:LOCALAPPDATA/Roblox/Versions/*/RobloxStudioBeta.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (!$studio) { throw 'Roblox Studio installation required' }
New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
$digest = (Get-FileHash -LiteralPath $candidate).Hash
$results = @()
foreach ($suite in $Suites) {
    $attempt = Join-Path $LogDirectory ($suite + '-' + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $attempt | Out-Null
    $copy = Join-Path $attempt 'candidate.rbxl'
    $output = Join-Path $attempt 'studio.log'
    Copy-Item -LiteralPath $candidate -Destination $copy
    if ($suite -in @('ui','returning')) {
        $probe = (Resolve-Path "tests/$suite-probe.luau").Path
    } else {
        $probe = Join-Path $attempt 'probe.luau'
        & $lune run tests/prepare.luau "tests/$suite-probe.luau" $probe
        if ($LASTEXITCODE -ne 0) { throw "Could not prepare $suite" }
    }
    Write-Host "Playing $suite in Studio. $output"
    $proc = Start-Process -FilePath $studio.FullName -ArgumentList @('--task','RunScript','--localPlaceFile',('"' + $copy + '"'),'--runScriptFile',('"' + $probe + '"'),'--outputFile',('"' + $output + '"'),'--quitAfterExecution') -WindowStyle Hidden -PassThru
    $deadline = (Get-Date).AddMinutes(10)
    while (!$proc.HasExited -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 2 }
    if (!$proc.HasExited) { $proc.Kill(); throw "$suite timed out" }
    if ($proc.ExitCode -ne 0) { throw "$suite Studio exit $($proc.ExitCode)" }
    if (!(Test-Path -LiteralPath $output)) { throw "$suite launched without a result log. Studio may have updated; retry with its installed version. $attempt" }
    $records = @(Get-Content -LiteralPath $output | Where-Object { $_ -match '^SQUISHY_TEST_RESULT\s+\{' })
    if ($records.Count -ne 1) { throw "$suite produced no unique test result. $output" }
    $result = ($records[0] -replace '^SQUISHY_TEST_RESULT\s+', '') | ConvertFrom-Json
    if ($result.ok -isnot [bool] -or !$result.ok) { throw "$suite failed. $($records[0])" }
    if ((Get-FileHash -LiteralPath $copy).Hash -ne $digest) { throw "$suite modified its candidate file" }
    $results += @{suite=$suite;ok=$true;log=$output;result=$result}
    @{sha256=$digest;studioVersion=$studio.VersionInfo.FileVersion;suites=$results} | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath (Join-Path $LogDirectory 'playtest.receipt.json')
    Write-Host "Passed $suite"
}
