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
  'core-only'     = Join-Path $MockRoot 'registrar-mock-core-only'
  update          = Join-Path $MockRoot 'registrar-mock-update'
}

# Scratch space for deliberately-broken copies. Never build them inside an arm.
$ScratchRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'governance-layer-a'

# ---------------------------------------------------------------------------
# The optional-module set
#
# The package installs in modules: core-rules.md and client-profiles.md always,
# the five below only if the install selected them. There is no manifest - the
# directory IS the record - so every check derives the installed set from disk
# rather than hardcoding a list. A hardcoded list here would reintroduce the
# exact staleness this harness exists to catch, and would make a legitimately
# declined module read as a missing file.
#
# Dot-sourced from scripts/module-lines.ps1 rather than restated here, for the
# same reason govern-update.md reads its anchors out of build.ps1: a second copy
# of the module list is drift waiting to happen, and a harness asserting against
# a stale copy of the contract is worse than no harness. This also means the
# checks exercise the very Remove-ModuleLines the procedures tell an agent to
# reproduce - $OptionalModules, $ModuleParents, the module-list anchors, and
# Remove-ModuleLines all arrive from there.
# ---------------------------------------------------------------------------

. (Join-Path $RepoRoot 'scripts\module-lines.ps1')

# Always present in any install, whatever modules were chosen.
$AlwaysInstalled = @('core-rules.md', 'client-profiles.md')

# The optional modules actually present in an install root. Returns them in
# $OptionalModules order so messages and comparisons are stable.
function Get-InstalledModules([string]$Root) {
    $dir = Join-Path $Root 'ai-governance'
    @($OptionalModules | Where-Object { Test-Path -LiteralPath (Join-Path $dir $_) })
}

# The optional modules an install root does NOT carry - declined, not missing.
function Get-DeclinedModules([string]$Root) {
    $installed = Get-InstalledModules $Root
    @($OptionalModules | Where-Object { $installed -notcontains $_ })
}

# Every rule file an install root should hold: the always-present pair plus
# whichever modules it selected.
function Get-ExpectedRuleFiles([string]$Root) {
    @($AlwaysInstalled) + @(Get-InstalledModules $Root)
}

# Tier A - the files govern-update replaces wholesale, and the only ones that
# stay byte-identical to ai-docs/. Deliberately excludes client-profiles.md,
# which is tier D: it is merged at install to carry the active client, so
# comparing it against the source would fail on every configured repo.
function Get-TierAFiles([string]$Root) {
    @('core-rules.md') + @(Get-InstalledModules $Root)
}

# What each arm was BUILT to contain, per testing/mock-app-setup.md. Derivation
# alone cannot check A2.2 - "every module on disk is on disk" is vacuous - so the
# fixture's intent is declared here and compared against what govern-init
# actually produced. This is a statement about the mock, not about the package:
# adding a module to ai-docs/ does not belong in this table, but adding an arm
# does.
$ArmModules = @{
  governed          = $OptionalModules   # full install
  unconfigured      = $OptionalModules   # full install, interview never run
  update            = $OptionalModules   # full install, aged source
  'core-only'       = @()                # core-rules.md + client-profiles only
  'entryfiles-only' = @()                # ai-governance/*.md deleted outright
}

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
