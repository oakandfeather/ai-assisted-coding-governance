<#
Regenerates empty-build/ - a gitignored, fully assembled snapshot of the
governance package (as it would land in a target repo) with NO client filled
in: every *(placeholder)* in AGENTS.template.md is left exactly as-is, and no
client profile is bundled. This is what a fresh `govern-init` copy looks like
before the placeholder interview and profile-authoring steps run - useful as
a generic reference distinct from build/ (filled in for the ESU sample).

Run after materially editing anything under ai-docs/, alongside build.ps1.

Note on encoding: every literal string in this script is deliberately
ASCII-only. The source ai-docs/*.md files contain typographic punctuation
(em dashes, middle dots, etc.) - this script never retypes that text; it only
locates ASCII-safe anchors and slices around them, so the file's own Unicode
content passes through untouched regardless of how Windows PowerShell
decides to read this .ps1 file's encoding.
#>

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$aiDocs   = Join-Path $repoRoot 'ai-docs'
$buildDir = Join-Path $repoRoot 'empty-build'

function Read-Text([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Expected source file not found: $path"
    }
    # Normalize to LF so literal "`n"-based anchors below match regardless of
    # whether the source file on disk uses CRLF or LF line endings.
    return [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n")
}

function Write-Text([string]$path, [string]$content) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function Copy-Verbatim([string]$src, [string]$dst) {
    if (-not (Test-Path -LiteralPath $src)) {
        throw "Expected source file not found: $src"
    }
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::Copy($src, $dst, $true)
}

# Slice content starting at the first occurrence of an ASCII anchor.
function Slice-From([string]$content, [string]$anchor, [string]$label) {
    $idx = $content.IndexOf($anchor)
    if ($idx -lt 0) {
        throw "Source shape changed - anchor not found for $label : '$anchor'"
    }
    return $content.Substring($idx)
}

Write-Host "Rebuilding empty-build/ from ai-docs/ ..."

# ---------- clean slate ----------
if (Test-Path -LiteralPath $buildDir) {
    Remove-Item -LiteralPath $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $buildDir '.github') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $buildDir 'ai-governance\client-profiles') -Force | Out-Null

# ---------- AGENTS.md ----------
# Banner stripped like build.ps1, but no placeholders are filled - this is
# the generic, unconfigured template as a target repo would first receive it.
$agents = Read-Text (Join-Path $aiDocs 'AGENTS.template.md')
$agents = Slice-From $agents '**Owner:** *(repo owner / team)*' 'AGENTS.md banner'

$footerMarker = "`n---`n*Fill in the italicized placeholders for this repository."
$footerIdx = $agents.IndexOf($footerMarker)
if ($footerIdx -lt 0) { throw "Source shape changed - AGENTS.md closing footnote not found" }
$agents = $agents.Substring(0, $footerIdx).TrimEnd() + "`n"
$agents = "# AGENTS.md`n`n" + $agents

Write-Text (Join-Path $buildDir 'AGENTS.md') $agents

# ---------- CLAUDE.md ----------
$claude = Read-Text (Join-Path $aiDocs 'CLAUDE.template.md')
$claude = Slice-From $claude 'Guidance for Claude Code in this repository lives in' 'CLAUDE.md body'
$claude = "# CLAUDE.md`n`n" + $claude.TrimEnd() + "`n"
Write-Text (Join-Path $buildDir 'CLAUDE.md') $claude

# ---------- .github/copilot-instructions.md ----------
$copilot = Read-Text (Join-Path $aiDocs 'copilot-instructions.template.md')
$copilot = Slice-From $copilot '# Coding rules for GitHub Copilot' 'copilot-instructions.md body'
$copilot = $copilot.TrimEnd() + "`n"
Write-Text (Join-Path $buildDir '.github\copilot-instructions.md') $copilot

# ---------- ai-governance verbatim files ----------
# No client-profiles/*.md is bundled - this build has no client, sample or
# otherwise.
Copy-Verbatim (Join-Path $aiDocs 'core-rules.md')      (Join-Path $buildDir 'ai-governance\core-rules.md')
Copy-Verbatim (Join-Path $aiDocs 'coding-rules.md')    (Join-Path $buildDir 'ai-governance\coding-rules.md')
Copy-Verbatim (Join-Path $aiDocs 'writing-rules.md')   (Join-Path $buildDir 'ai-governance\writing-rules.md')
Copy-Verbatim (Join-Path $aiDocs 'coding-patterns.md') (Join-Path $buildDir 'ai-governance\coding-patterns.md')
Copy-Verbatim (Join-Path $aiDocs 'agent-workflow.md')  (Join-Path $buildDir 'ai-governance\agent-workflow.md')

# ---------- ai-governance/client-profiles.md ----------
# Leave "Active client profiles" as its honest *(none yet)* empty state, and
# drop the "Sample profile" section since no sample file is bundled here.
$profiles = Read-Text (Join-Path $aiDocs 'client-profiles.md')

$sampleIdx = $profiles.IndexOf('## Sample profile')
if ($sampleIdx -lt 0) { throw "Source shape changed - '## Sample profile' section not found in client-profiles.md" }
$profiles = $profiles.Substring(0, $sampleIdx).TrimEnd() + "`n"

Write-Text (Join-Path $buildDir 'ai-governance\client-profiles.md') $profiles

Write-Host "empty-build/ regenerated (9 files)."
Write-Host "empty-build/ is gitignored and generated - do not hand-edit it; edit ai-docs/ and rerun this script."
