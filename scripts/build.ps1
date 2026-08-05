<#
Regenerates build/ - a gitignored, fully assembled snapshot of the governance
package (as it would land in a target repo) filled in for the sample client
(Example State University / ESU).

Run after materially editing anything under ai-docs/. See AGENTS.md.

Note on encoding: every literal string in this script is deliberately
ASCII-only. The source ai-docs/*.md files contain typographic punctuation
(em dashes, middle dots, etc.) - this script never retypes that text; it only
locates ASCII-safe anchors and slices/replaces around them, so the file's
own Unicode content passes through untouched regardless of how Windows
PowerShell decides to read this .ps1 file's encoding.
#>

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$aiDocs   = Join-Path $repoRoot 'ai-docs'
$buildDir = Join-Path $repoRoot 'build'

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

# Replace a *(...)* placeholder token. $prefix must be an ASCII-only string
# starting exactly at the token's opening "*(" (it need not include the
# whole token - just enough to be unique and stop before any non-ASCII
# character inside it). The token's true end is the next ")*" found at or
# after $prefix.
function Replace-Placeholder([string]$content, [string]$prefix, [string]$newValue, [string]$label) {
    $start = $content.IndexOf($prefix)
    if ($start -lt 0) {
        throw "Source shape changed - placeholder not found for $label : '$prefix'"
    }
    $closeIdx = $content.IndexOf(')*', $start)
    if ($closeIdx -lt 0) {
        throw "Source shape changed - no closing ')*' found for $label"
    }
    $end = $closeIdx + 2
    return $content.Substring(0, $start) + $newValue + $content.Substring($end)
}

# Replace the paragraph starting at $startAnchor (through the next blank
# line, or end of content if it's the last paragraph) with $newText.
function Replace-Paragraph([string]$content, [string]$startAnchor, [string]$newText, [string]$label) {
    $start = $content.IndexOf($startAnchor)
    if ($start -lt 0) {
        throw "Source shape changed - anchor not found for $label : '$startAnchor'"
    }
    $end = $content.IndexOf("`n`n", $start)
    if ($end -lt 0) { $end = $content.Length }
    return $content.Substring(0, $start) + $newText + $content.Substring($end)
}

function Assert-NoPlaceholders([string]$content, [string]$label) {
    if ($content -match '\*\([^)]*\)\*') {
        throw "Unfilled placeholder remains in $label : '$($Matches[0])'"
    }
}

Write-Host "Rebuilding build/ from ai-docs/ ..."

# ---------- clean slate ----------
if (Test-Path -LiteralPath $buildDir) {
    Remove-Item -LiteralPath $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $buildDir '.github') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $buildDir 'ai-governance\client-profiles') -Force | Out-Null

# ---------- AGENTS.md ----------
$agents = Read-Text (Join-Path $aiDocs 'AGENTS.template.md')
$agents = Slice-From $agents '**Version:**' 'AGENTS.md banner'

$footerMarker = "`n---`n*Fill in the italicized placeholders for this repository."
$footerIdx = $agents.IndexOf($footerMarker)
if ($footerIdx -lt 0) { throw "Source shape changed - AGENTS.md closing footnote not found" }
$agents = $agents.Substring(0, $footerIdx).TrimEnd() + "`n"
$agents = "# AGENTS.md`n`n" + $agents

$agents = Replace-Placeholder $agents '*(date)*' '2026-07-17' 'AGENTS.md last reviewed'
$agents = Replace-Placeholder $agents '*(client name)*' 'Example State University (ESU)' 'AGENTS.md active client (header)'
$agents = Replace-Placeholder $agents '*(fill in)*' 'Example State University (ESU)' 'AGENTS.md active client (body)'
$agents = Replace-Placeholder $agents '*(1' 'The ESU Student Portal is a web application for course registration and academic records access, built for Example State University (ESU). This engagement is a worked example showing the governance package fully assembled and filled in for a fictional public-university client.' 'AGENTS.md project overview'

$agents = Replace-Placeholder $agents '*(e.g., TypeScript, Python)*' 'TypeScript, Python' 'AGENTS.md language'
$agents = Replace-Placeholder $agents '*(e.g., React, FastAPI)*' 'React (frontend), FastAPI (backend)' 'AGENTS.md framework'
$agents = Replace-Placeholder $agents '*(e.g., pnpm, uv)*' 'pnpm (frontend), uv (backend)' 'AGENTS.md package manager'
$agents = Replace-Placeholder $agents '*(e.g., PostgreSQL, Docker)*' 'PostgreSQL, Docker' 'AGENTS.md database/infra'
$agents = Replace-Placeholder $agents '*(e.g., Node 22, Python 3.12' 'Node 22, Python 3.12' 'AGENTS.md runtime versions'
$agents = Replace-Placeholder $agents '*(e.g., OS assumptions, devcontainer, monorepo layout and which package this file governs)*' 'monorepo (apps/web, apps/api), devcontainer-based; this file governs the whole repo' 'AGENTS.md dev environment'

$agents = Replace-Placeholder $agents '*(e.g., pnpm install)*' 'pnpm install' 'AGENTS.md install command'
$agents = Replace-Placeholder $agents '*(e.g., pnpm dev)*' 'pnpm dev' 'AGENTS.md run command'
$agents = Replace-Placeholder $agents '*(e.g., pnpm test)*' 'pnpm test' 'AGENTS.md test-all command'
$agents = Replace-Placeholder $agents '*(e.g., pnpm test path/to/file.test.ts' 'pnpm test path/to/file.test.ts -t "test name"' 'AGENTS.md single-test command'
$agents = Replace-Placeholder $agents '*(e.g., pnpm lint && pnpm format)*' 'pnpm lint && pnpm format' 'AGENTS.md lint command'
$agents = Replace-Placeholder $agents '*(e.g., pnpm build)*' 'pnpm build' 'AGENTS.md build command'

$agents = Replace-Placeholder $agents '*(the full gate: e.g., `pnpm test && pnpm lint && pnpm build` exits 0 with no new warnings)*' 'The full gate: `pnpm test && pnpm lint && pnpm build` exits 0 with no new warnings.' 'AGENTS.md verification gate'
$agents = Replace-Placeholder $agents '*(what a clean run looks like: e.g., "N tests passed, 0 skipped"' 'What a clean run looks like: "N tests passed, 0 skipped." There are no known-flaky tests to ignore in this example engagement.' 'AGENTS.md clean-run description'
$agents = Replace-Placeholder $agents '*(how to exercise the change beyond tests: e.g., "hit `GET /health` on the dev server", "run the CLI against `fixtures/sample.csv`")*' 'How to exercise the change beyond tests: hit `GET /health` on the dev server, or run the CLI against `fixtures/sample.csv` for data-import changes.' 'AGENTS.md manual exercise'

$agents = Replace-Placeholder $agents '*(where the main modules / entry points live' '`apps/web` (React frontend, entry at `apps/web/src/main.tsx`) and `apps/api` (FastAPI backend, entry at `apps/api/main.py`).' 'AGENTS.md structure'
$agents = Replace-Placeholder $agents '*(naming, error handling, state management, API patterns' 'feature-folder structure, standard REST API patterns; match existing code for naming, error handling, and state management.' 'AGENTS.md conventions'
$agents = Replace-Placeholder $agents '*(generated files, vendored code, migrations, etc.)*' '`apps/api/migrations/`, generated OpenAPI client code.' 'AGENTS.md do-not-touch'
$agents = Replace-Placeholder $agents '*(framework, where tests live, coverage expectations)*' 'Vitest for the frontend, pytest for the backend; tests colocated with the source they cover.' 'AGENTS.md testing approach'

$agents = Replace-Placeholder $agents '*(e.g., FERPA, HIPAA, GLBA, PCI-DSS, GDPR' 'FERPA, HIPAA (ESU Medical Center integration), GLBA, PCI-DSS, GDPR (as applicable), and the state Open Records Act, per client profile.' 'AGENTS.md regulatory regimes'
$agents = Replace-Placeholder $agents '*(mandatory for public-sector clients per their profile)*' '(mandatory for public-sector clients per their profile; ESU is public-sector)' 'AGENTS.md accessibility target'
$agents = Replace-Placeholder $agents '*(e.g., public-sector clients may be subject to open-records laws' 'ESU is subject to the state Open Records Act; assume prompts and records may be disclosable. Treat student records as FERPA-protected by default.' 'AGENTS.md records/privacy notes'

$agents = Replace-Placeholder $agents '*(per client profile' '(per client profile: ESU IT Security)' 'AGENTS.md escalation contact'

Assert-NoPlaceholders $agents 'build/AGENTS.md'
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
Copy-Verbatim (Join-Path $aiDocs 'core-rules.md')      (Join-Path $buildDir 'ai-governance\core-rules.md')
Copy-Verbatim (Join-Path $aiDocs 'coding-rules.md')    (Join-Path $buildDir 'ai-governance\coding-rules.md')
Copy-Verbatim (Join-Path $aiDocs 'writing-rules.md')   (Join-Path $buildDir 'ai-governance\writing-rules.md')
Copy-Verbatim (Join-Path $aiDocs 'coding-patterns.md') (Join-Path $buildDir 'ai-governance\coding-patterns.md')
Copy-Verbatim (Join-Path $aiDocs 'writing-patterns.md') (Join-Path $buildDir 'ai-governance\writing-patterns.md')
Copy-Verbatim (Join-Path $aiDocs 'agent-workflow.md')  (Join-Path $buildDir 'ai-governance\agent-workflow.md')
Copy-Verbatim (Join-Path $aiDocs 'client-profiles\example-university.md') (Join-Path $buildDir 'ai-governance\client-profiles\example-university.md')

# ---------- ai-governance/client-profiles.md ----------
$profiles = Read-Text (Join-Path $aiDocs 'client-profiles.md')
$profiles = Replace-Paragraph $profiles '*(none yet)*' '- **Example State University (ESU)**: see [`client-profiles/example-university.md`](./client-profiles/example-university.md).' 'client-profiles.md active section'

$sampleIdx = $profiles.IndexOf('## Sample profile')
if ($sampleIdx -lt 0) { throw "Source shape changed - '## Sample profile' section not found in client-profiles.md" }
$profiles = $profiles.Substring(0, $sampleIdx).TrimEnd() + "`n"

Write-Text (Join-Path $buildDir 'ai-governance\client-profiles.md') $profiles

Write-Host "build/ regenerated (11 files)."
Write-Host "build/ is gitignored and generated - do not hand-edit it; edit ai-docs/ and rerun this script."
