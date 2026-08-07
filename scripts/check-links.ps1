<#
Layer A4.1 of testing/Governance-Test-Plan.md: verifies that every relative
Markdown link in this repository resolves FROM THE FILE IT LIVES IN - not from
the repo root. That distinction is the whole point: a link written `./foo.md`
in ai-docs/ and a link written `./foo.md` at the root mean different targets,
and the AGENTS.md verification contract is specifically about the former.

Run after editing any .md file. Exits 0 when every link resolves, 1 when any
link is broken, so it works as a gate.

Three carve-outs are deliberate, and removing any of them produces guaranteed
false positives on a clean tree - which is how a checker trains everyone to
ignore its output:

  1. The *.template.md files link into `ai-governance/`, a directory that does
     not exist in this repo and must not. Those links resolve only once the
     template has been installed into a target repo, so their targets are
     verified against the corresponding build/ output instead.
  2. Code spans and fenced code blocks that QUOTE link syntax are prose about
     links, not links. They are stripped before matching.
  3. core-build/ is skipped entirely. It is the core-only install oracle, and a
     core-only install has dangling ai-governance/ links inside its rule files
     BY DESIGN - core-rules.md states that an absent module means the pointer
     does not apply. Link-checking it would flag the feature as a defect. Note
     the asymmetry, and its limit: build/ and empty-build/ are full installs and
     ARE checked, so a genuine break still surfaces THERE - but nothing in this
     script validates a link against a PARTIAL install, the template links in
     carve-out 1 included, since those resolve against build/ by construction.
     What core-build/ must not have is a dangling link in an *entry* file, and
     that is asserted by the harness (A2.12c), not here.

Note on encoding: this script only reads files and reports paths, so it never
retypes source content. Paths are compared as text; no output is written.
#>

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

# Templates link into ai-governance/, which exists only after install. Their
# link targets are checked against the build/ snapshot instead (see below).
$templateFiles = @(
    'ai-docs/AGENTS.template.md',
    'ai-docs/copilot-instructions.template.md'
)

# Where an ai-governance/ link from a template should resolve once installed.
$installedRulesDir = Join-Path $repoRoot 'build/ai-governance'

function Read-Text([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Expected file not found: $path"
    }
    return [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n")
}

# Blank out fenced blocks and inline code spans, preserving length and line
# breaks so any offsets reported downstream still line up with the original.
function Remove-CodeSpans([string]$text) {
    $blank = {
        param($m)
        # Keep newlines; replace everything else with spaces.
        return ($m.Value -replace '[^\n]', ' ')
    }
    $noFences = [regex]::Replace($text, '(?s)```.*?```', $blank)
    $noTildes = [regex]::Replace($noFences, '(?s)~~~.*?~~~', $blank)
    return [regex]::Replace($noTildes, '`[^`\n]*`', $blank)
}

# Repo-relative path with forward slashes, for stable comparison and output.
function Get-RelativePath([string]$fullPath) {
    return $fullPath.Substring($repoRoot.Length + 1).Replace('\', '/')
}

$mdFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -Filter *.md -File |
    Where-Object { $_.FullName -notmatch '\\\.git\\' } |
    Where-Object { $_.FullName -notmatch '\\core-build\\' }

$checked  = 0
$skipped  = 0
$breaks   = New-Object System.Collections.Generic.List[string]

foreach ($file in $mdFiles) {
    $relFile  = Get-RelativePath $file.FullName
    $ownDir   = Split-Path -Parent $file.FullName
    $isTemplate = $templateFiles -contains $relFile
    $body     = Remove-CodeSpans (Read-Text $file.FullName)

    foreach ($match in [regex]::Matches($body, '\]\(\s*(\.[^)\s]*)')) {
        $target = $match.Groups[1].Value
        # Drop any #anchor fragment; we verify the file, not the heading.
        $path = ($target -split '#')[0]
        if ([string]::IsNullOrWhiteSpace($path)) { continue }

        # Carve-out 1: a template's ai-governance/ link is verified against the
        # installed shape in build/, since that is where it resolves in real use.
        if ($isTemplate -and $path -match 'ai-governance/') {
            $leaf = $path.Substring($path.IndexOf('ai-governance/') + 'ai-governance/'.Length)
            $resolved = Join-Path $installedRulesDir $leaf
            if (-not (Test-Path -LiteralPath $resolved)) {
                $breaks.Add("$relFile -> $target  (missing from build/ai-governance/ - run scripts/build.ps1, then check the template)")
            }
            $checked++
            continue
        }

        $resolved = Join-Path $ownDir $path
        if (Test-Path -LiteralPath $resolved) {
            $checked++
        } else {
            $checked++
            $breaks.Add("$relFile -> $target")
        }
    }
}

if (-not (Test-Path -LiteralPath $installedRulesDir)) {
    Write-Output "NOTE: build/ is absent, so template links could not be verified against the installed shape."
    Write-Output "      Run scripts/build.ps1 first for full coverage."
    $skipped = $templateFiles.Count
}

Write-Output ""
if ($breaks.Count -gt 0) {
    Write-Output "Broken relative links ($($breaks.Count)):"
    foreach ($b in $breaks) { Write-Output "  $b" }
    Write-Output ""
    Write-Output "Checked $checked relative links across $($mdFiles.Count) Markdown files."
    Write-Output "A link must resolve from the directory of the file it lives in, not from the repo root."
    exit 1
}

Write-Output "All $checked relative links resolve. ($($mdFiles.Count) Markdown files checked.)"
if ($skipped -gt 0) {
    Write-Output "$skipped template file(s) were not verified against build/ - see the note above."
}
exit 0
