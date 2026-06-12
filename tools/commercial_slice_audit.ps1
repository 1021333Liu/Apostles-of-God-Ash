param(
    [string]$GodotExe = "E:\Godot\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe",
    [switch]$SkipGodot
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Errors = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]

function Add-Problem {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
}

function Add-Warning {
    param([string]$Message)
    $Warnings.Add($Message) | Out-Null
}

function Require-Text {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )
    if ($Text -notmatch [regex]::Escape($Pattern)) {
        Add-Problem $Message
    }
}

Write-Host "Commercial slice audit"
Write-Host "Root: $Root"

$MainPath = Join-Path $Root "scripts\main.gd"
$RegistryPath = Join-Path $Root "scripts\systems\art_asset_registry.gd"
$AttackPath = Join-Path $Root "scripts\systems\attack_runtime.gd"

foreach ($Path in @($MainPath, $RegistryPath, $AttackPath)) {
    if (-not (Test-Path $Path)) {
        Add-Problem "Missing required file: $Path"
    }
}

if (Test-Path $MainPath) {
    $Main = Get-Content -Path $MainPath -Raw -Encoding UTF8
    Require-Text $Main "clip_contents = true" "Texture previews must clip contents to prevent art overflow."
    Require-Text $Main "STRETCH_KEEP_ASPECT_CENTERED" "Texture previews must keep aspect centered instead of stretching/cropping unpredictably."
    Require-Text $Main "_safe_ui_rect" "UI image placement must pass through a safe screen rectangle helper."
    Require-Text $Main "_fit_texture_rect" "Drawn concept and character textures must preserve aspect ratio inside target bounds."
    Require-Text $Main "_spawn_hit_burst" "Combat should include hit burst feedback."
    Require-Text $Main "_trigger_miss_feedback" "Combat should include miss feedback."
    Require-Text $Main "_draw_boss_weakpoint_reticle" "Boss weakpoint windows should have a clear target reticle."
}

if (Test-Path $AttackPath) {
    $Attack = Get-Content -Path $AttackPath -Raw -Encoding UTF8
    foreach ($Step in @("1:", "2:", "_:")) {
        if ($Attack -notmatch [regex]::Escape($Step)) {
            Add-Warning "Combo profile branch may be missing: $Step"
        }
    }
}

$ConceptDir = Join-Path $Root "assets\concepts"
if (Test-Path $ConceptDir) {
    $ConceptPngs = Get-ChildItem -Path $ConceptDir -Recurse -Filter *.png
    foreach ($Png in $ConceptPngs) {
        $ImportPath = "$($Png.FullName).import"
        if (-not (Test-Path $ImportPath)) {
            Add-Warning "Missing Godot import sidecar: $ImportPath"
        }
    }
}

if (-not $SkipGodot) {
    if (-not (Test-Path $GodotExe)) {
        Add-Warning "Godot executable not found: $GodotExe"
    } else {
        $GodotLogDir = Join-Path $Root ".godot"
        $GodotLogPath = Join-Path $GodotLogDir "commercial_slice_audit.log"
        New-Item -ItemType Directory -Force -Path $GodotLogDir | Out-Null
        Write-Host "Running Godot headless validation..."
        & $GodotExe --headless --log-file $GodotLogPath --path $Root "res://scenes/main.tscn" --quit-after 2
        if ($LASTEXITCODE -ne 0) {
            Add-Problem "Godot headless validation failed with exit code $LASTEXITCODE."
        }
    }
}

Write-Host ""
Write-Host "Warnings: $($Warnings.Count)"
foreach ($Warning in $Warnings) {
    Write-Host "  WARN: $Warning"
}

Write-Host "Errors: $($Errors.Count)"
foreach ($Problem in $Errors) {
    Write-Host "  ERROR: $Problem"
}

if ($Errors.Count -gt 0) {
    exit 1
}

Write-Host "Audit passed."
