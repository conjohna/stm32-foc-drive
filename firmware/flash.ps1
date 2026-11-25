<#
.SYNOPSIS
    Build the firmware (Debug preset) and flash it to the NUCLEO-G474RE.

.DESCRIPTION
    Uses the CMake, Ninja, GNU Arm and STM32CubeProgrammer bundles installed
    by the STM32 VS Code extension, so nothing needs to be on PATH.
    Stops before flashing if the build fails, so a stale .elf is never
    programmed.

.EXAMPLE
    .\flash.ps1
#>

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$bundles = Join-Path $env:LOCALAPPDATA 'stm32cube\bundles'

# Newest installed version of a bundle's bin folder.
function Get-BundleBin([string]$name) {
    $dir = Get-ChildItem (Join-Path $bundles $name) -Directory |
        Sort-Object Name -Descending | Select-Object -First 1
    if (-not $dir) { throw "STM32 bundle '$name' not found under $bundles" }
    Join-Path $dir.FullName 'bin'
}

$toolDirs = @(
    (Get-BundleBin 'cmake'),
    (Get-BundleBin 'ninja'),
    (Get-BundleBin 'gnu-tools-for-stm32')
)
$env:PATH = ($toolDirs -join ';') + ';' + $env:PATH

$programmer = Join-Path (Get-BundleBin 'programmer') 'STM32_Programmer_CLI.exe'
$elf = 'build\Debug\firmware.elf'

Write-Host '=== Build ===' -ForegroundColor Cyan
if (-not (Test-Path 'build\Debug\CMakeCache.txt')) {
    cmake --preset Debug
    if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed' }
}
cmake --build --preset Debug
if ($LASTEXITCODE -ne 0) { throw 'Build failed - not flashing' }

Write-Host '=== Flash ===' -ForegroundColor Cyan
& $programmer -c port=SWD mode=UR -w $elf -v -rst
if ($LASTEXITCODE -ne 0) { throw 'Flash failed' }

Write-Host '=== Done: build + flash OK ===' -ForegroundColor Green
