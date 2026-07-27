# Shared setup for the Layer A harness. Dot-source it: . "$PSScriptRoot\harness-common.ps1"
#
# Two things live here because getting either wrong silently corrupts results:
# path resolution (the mock is deliberately outside this repo) and UTF-8 IO.

Set-StrictMode -Off
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Paths
#
# The repo root is derived from this file's location, so the harness runs from
# anywhere. The mock lives OUTSIDE this repo on purpose - see mock-app-setup.md:
# govern-init creates an ai-governance/ directory, which AGENTS.md forbids here.
# Override the location with the GOVERNANCE_MOCK_ROOT environment variable.
# ---------------------------------------------------------------------------

$RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$MockRoot = if ($env:GOVERNANCE_MOCK_ROOT) { $env:GOVERNANCE_MOCK_ROOT } else { Split-Path $RepoRoot -Parent }

$MockArms = [ordered]@{
  base            = Join-Path $MockRoot 'registrar-mock'
  governed        = Join-Path $MockRoot 'registrar-mock-governed'
  control         = Join-Path $MockRoot 'registrar-mock-control'
  unconfigured    = Join-Path $MockRoot 'registrar-mock-unconfigured'
  'entryfiles-only' = Join-Path $MockRoot 'registrar-mock-entryfiles-only'
  update          = Join-Path $MockRoot 'registrar-mock-update'
}

# Scratch space for deliberately-broken copies. Never build them inside an arm.
$ScratchRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'governance-layer-a'

function Assert-MockPresent {
    $missing = $MockArms.GetEnumerator() | Where-Object { -not (Test-Path -LiteralPath $_.Value) }
    if ($missing) {
        throw ("Mock arms not found under '$MockRoot': " + (($missing | ForEach-Object { $_.Key }) -join ', ') +
               ". Build them per testing/mock-app-setup.md, or set GOVERNANCE_MOCK_ROOT.")
    }
}

# ---------------------------------------------------------------------------
# UTF-8 IO
#
# PowerShell 5.1's Get-Content decodes UTF-8-without-BOM as ANSI, which mangles
# every em dash, middot and the warning sign in the mandatory-rules heading.
# The structural checks index on exactly those characters, so this is not
# cosmetic: reproducing A2.8c/A2.8e over Get-Content gives a different answer.
# ---------------------------------------------------------------------------

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Read as UTF-8 and normalize newlines, for content comparison.
function Read-Doc([string]$Path) {
    ([System.IO.File]::ReadAllText($Path, $Utf8NoBom)) -replace "`r`n", "`n"
}

# Read as UTF-8 with line endings intact, for anything that inspects them.
function Read-DocRaw([string]$Path) {
    [System.IO.File]::ReadAllText($Path, $Utf8NoBom)
}

# Write UTF-8 without BOM, matching the line endings already in $LikePath.
# Governance files are reviewed as diffs; rewriting every line to change the
# endings destroys the audit trail the update procedure asks reviewers to read.
function Write-DocLike([string]$Path, [string]$Text, [string]$LikePath) {
    $eol = "`n"
    if ($LikePath -and (Test-Path -LiteralPath $LikePath)) {
        $existing = [System.IO.File]::ReadAllText($LikePath, $Utf8NoBom)
        if ([regex]::Matches($existing, "`r`n").Count -gt 0) { $eol = "`r`n" }
    }
    $normalized = $Text -replace "`r`n", "`n"
    if ($eol -eq "`r`n") { $normalized = $normalized -replace "`n", "`r`n" }
    [System.IO.File]::WriteAllText($Path, $normalized, $Utf8NoBom)
}

# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------

function Reset-Harness { $Global:HarnessFailCount = 0 }

function Ok   ([string]$Id, [string]$Message) { "  PASS $Id  $Message" }
function No   ([string]$Id, [string]$Message) { "  FAIL $Id  $Message"; $Global:HarnessFailCount++ }
function Note ([string]$Id, [string]$Message) { "  NOTE $Id  $Message" }

function Assert([string]$Id, $Condition, [string]$Message) {
    if ($Condition) { Ok $Id $Message } else { No $Id $Message }
}

function Exit-Harness {
    ""
    if ($Global:HarnessFailCount -eq 0) { 'RESULT: all checks passed'; exit 0 }
    else { "RESULT: $Global:HarnessFailCount check(s) failed"; exit 1 }
}

# Copy an arm to scratch, excluding .git and node_modules. Returns the path.
function New-ScratchCopy([string]$Name, [string]$From) {
    $dest = Join-Path $ScratchRoot $Name
    if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    robocopy $From $dest /E /XD '.git' 'node_modules' /NFL /NDL /NJH /NJS /NC /NS | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE) copying $From" }
    $dest
}

function Remove-ScratchCopy([string]$Path) {
    if ($Path -and (Test-Path -LiteralPath $Path)) { Remove-Item -LiteralPath $Path -Recurse -Force }
}
