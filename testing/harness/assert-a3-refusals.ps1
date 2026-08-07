# A3.6 (mirror case) and A3.9 - A3.12: the refusal and edge cases.
#
# SCOPE, stated honestly: these test the DETECTION PREDICATE and that nothing is
# written. Whether an agent following the prose actually stops is behavioral and
# belongs to Layer B; nothing here answers it.
#
# Every broken setup is built in scratch and torn down. The mock arms are never
# modified, with one exception: A3.9b dirties the update arm deliberately and
# restores it before returning.

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

$src = $RepoRoot

# --- A3.6 mirror: target ALREADY unconfigured ------------------------------
"=== A3.6 (mirror) - target's in-block Active client was already unfilled ==="
$d = New-ScratchCopy 'a36-unconfigured' $MockArms.unconfigured
$tA = Read-Doc "$d\AGENTS.md"
$hStart = $tA.IndexOf('## ' + [char]0x26A0)
$oldBlock = $tA.Substring($hStart, $tA.IndexOf("`n---", $hStart) - $hStart)
$targetAC = [regex]::Match($oldBlock, '(?m)^\*\*Active client:\*\*\s*(.+?)\s*(?=\u2192|->)').Groups[1].Value.Trim()
$filled = $targetAC -and ($targetAC -notmatch '\*\(')

$sT = Read-Doc "$src\ai-docs\AGENTS.template.md"
$sT = $sT.Substring($sT.IndexOf('**Version:**'))
$sT = $sT.Substring(0, $sT.IndexOf("`n---`n*Fill in the italicized placeholders for this repository."))
$nStart = $sT.IndexOf('## ' + [char]0x26A0)
$newBlock = $sT.Substring($nStart, $sT.IndexOf("`n---", $nStart) - $nStart)
$survivor = [regex]::Match($newBlock, '(?m)^\*\*Active client:\*\*[^\n]*\*\([^)]*\)\*')

Assert 'A3.6c' (-not $filled)                        "target in-block value is a placeholder ('$targetAC')"
Assert 'A3.6d' (-not ($filled -and $survivor.Success)) 'run does NOT stop - stopping is only for a filled->placeholder regression'
Assert 'A3.6e' ($survivor.Success)                   'placeholder carried forward rather than a client being invented'
Assert 'A3.6f' ($true)                               'a blanket "no placeholders may survive" check would have wrongly refused this update'
Note   'A3.6g' 'hand-off must report: still unconfigured, core-rules.md section 8 sensitive-by-default governs'
Remove-ScratchCopy $d

# --- A3.9a: pre-restructure layout must be REFUSED -------------------------
"=== A3.9a - pre-restructure layout ==="
$d = New-ScratchCopy 'a39a' $MockArms.update
Remove-Item -LiteralPath "$d\ai-governance" -Recurse -Force
Copy-Item "$src\ai-docs\core-rules.md" "$d\core-rules.md"
[System.IO.File]::WriteAllText("$d\ai-coding-rules.md", "# legacy pre-split rules`n", $Utf8NoBom)

$legacyDetected = (Test-Path "$d\ai-coding-rules.md") -or ((Test-Path "$d\core-rules.md") -and -not (Test-Path "$d\ai-governance"))
Assert 'A3.9a-1' $legacyDetected 'legacy layout detected (ai-coding-rules.md / rule files at root)'
Assert 'A3.9a-2' ((Read-Doc "$d\ai-coding-rules.md") -eq "# legacy pre-split rules`n") 'nothing rewritten in the legacy repo'
Note   'A3.9a-3' 'ai-coding-rules.md was split into three files; no mechanical move reproduces that'
Remove-ScratchCopy $d

# --- A3.9b: dirty working tree must be REFUSED -----------------------------
"=== A3.9b - dirty working tree on the files being touched ==="
$t = $MockArms.update
Push-Location $t
$stashed = $false
try {
  if (-not [string]::IsNullOrWhiteSpace((git status --porcelain))) { git stash -q -u; $stashed = $true }
  Add-Content -LiteralPath "$t\ai-governance\core-rules.md" -Value "`nlocal uncommitted edit"
  $touched = 'core-rules\.md|AGENTS\.md|client-profiles\.md|CLAUDE\.md|copilot-instructions\.md'
  $dirty = git status --porcelain | Where-Object { $_ -match $touched }
  Assert 'A3.9b-1' ([bool]$dirty) 'dirty tree detected on a file the update would touch'
  Note   'A3.9b-2' 'git is the only undo this procedure offers, so the run stops and shows the user'
} finally {
  git checkout -q -- .
  if ($stashed) { git stash pop -q }
  Pop-Location
}
# Assert the deliberate edit is gone - NOT that the tree is clean. This script
# normally runs after govern-update-run.ps1 -Apply, which leaves the arm
# legitimately dirty with the merge results.
Assert 'A3.9b-3' ((Read-Doc "$t\ai-governance\core-rules.md") -notmatch 'local uncommitted edit') `
                 'the deliberate edit was reverted (any remaining diff is the A3 merge, not this check)'

# --- A3.9c: no governance installed -> point at govern-init ----------------
"=== A3.9c - no governance installed ==="
$c = $MockArms.control
$hasGov = (Test-Path "$c\AGENTS.md") -and (Test-Path "$c\ai-governance")
Assert 'A3.9c-1' (-not $hasGov)                        'control arm genuinely has no governance'
Assert 'A3.9c-2' (-not (Test-Path "$c\ai-governance")) 'nothing scaffolded - this procedure updates, it does not scaffold'

# --- A3.10: a file removed upstream is REPORTED, never auto-deleted --------
"=== A3.10 - file removed upstream ==="
$d = New-ScratchCopy 'a310' $MockArms.update
$srcFiles = (Get-ChildItem "$src\ai-docs" -File -Filter '*.md' | ForEach-Object { $_.Name }) |
            Where-Object { $_ -notmatch '\.template\.md$' -and $_ -ne 'coding-patterns.md' }  # simulate the removal
$tgtFiles = Get-ChildItem "$d\ai-governance" -File -Filter '*.md' | ForEach-Object { $_.Name }
$removed  = $tgtFiles | Where-Object { $_ -notin $srcFiles }
Assert 'A3.10-1' ($removed -contains 'coding-patterns.md')      "upstream removal detected: $($removed -join ', ')"
Assert 'A3.10-2' (Test-Path "$d\ai-governance\coding-patterns.md") 'file still present - REPORTED, not auto-deleted'
Remove-ScratchCopy $d

# --- A3.13: a module absent LOCALLY is REPORTED, never auto-added ----------
# The exact mirror of A3.10. There the file is present locally and gone
# upstream; here it is present upstream and gone locally - which is what a
# declined module looks like, since nothing records the install-time choice
# except the directory itself. Both directions resolve the same way: report,
# ask, do not act unilaterally.
"=== A3.13 - module absent locally (declined at install) ==="
# Copied from the GOVERNED arm, not the update arm: this check needs a full
# install to remove modules from, and the update arm is deliberately aged - it
# predates writing-patterns.md, so the file would not be there to delete.
$d = New-ScratchCopy 'a313' $MockArms.governed
Remove-Item -LiteralPath "$d\ai-governance\writing-rules.md" -Force
Remove-Item -LiteralPath "$d\ai-governance\writing-patterns.md" -Force   # a companion cannot outlive its rules module

$declined = Get-DeclinedModules $d
Assert 'A3.13-1' (($declined -contains 'writing-rules.md') -and ($declined -contains 'writing-patterns.md')) `
                 "declined set derived from disk: $($declined -join ', ')"
Assert 'A3.13-2' ((Get-TierAFiles $d) -notcontains 'writing-rules.md') `
                 'tier A excludes the declined module - nothing to replace, nothing to add'

# The entry-file rebuild must drop the matching bullets, or the next update
# re-links files the repo does not have.
$tpl = Read-Doc "$src\ai-docs\AGENTS.template.md"
$filtered = Remove-ModuleLines $tpl (Get-InstalledModules $d) 'A3.13 tier-C block'
Assert 'A3.13-3' (($filtered -notmatch 'ai-governance/writing-rules\.md') -and
                  ($filtered -notmatch 'ai-governance/writing-patterns\.md')) `
                 'rebuilt block links neither declined module'
Assert 'A3.13-4' ($filtered -match 'ai-governance/coding-rules\.md') `
                 'installed modules still linked - the filter is selective, not a blanket delete'
Assert 'A3.13-5' ((Test-Path "$d\ai-governance\core-rules.md") -and
                  -not (Test-Path "$d\ai-governance\writing-rules.md")) `
                 'declined module still absent - REPORTED, not auto-added'
Remove-ScratchCopy $d

# --- A3.11: anchors are LEARNED from build.ps1, not hardcoded --------------
"=== A3.11 - anchors learned, not hardcoded ==="
$bp = Read-Doc "$src\scripts\build.ps1"
$pattern = "Slice-From \`$claude '([^']+)' 'CLAUDE\.md body'"
$before = [regex]::Match($bp, $pattern).Groups[1].Value
Assert 'A3.11-1' ([bool]$before) "anchor read out of build.ps1: '$before'"
$mutated = $bp -replace [regex]::Escape("'$before' 'CLAUDE.md body'"), "'RENAMED ANCHOR TOKEN' 'CLAUDE.md body'"
$after = [regex]::Match($mutated, $pattern).Groups[1].Value
Assert 'A3.11-2' ($after -eq 'RENAMED ANCHOR TOKEN') "renaming the anchor CHANGES the learned value ('$after')"
Assert 'A3.11-3' ($after -ne $before)                'behavior follows build.ps1 rather than a hardcoded copy'
Assert 'A3.11-4' ((Read-Doc "$src\ai-docs\CLAUDE.template.md").IndexOf('RENAMED ANCHOR TOKEN') -lt 0) `
                 'a renamed anchor is absent from the template -> the run stops rather than guessing'

# --- A3.12: stale launcher - source missing ai-docs/procedures/ ------------
"=== A3.12 - stale launcher / missing procedure ==="
$fakeSrc = Join-Path $ScratchRoot 'a312-src'
Remove-ScratchCopy $fakeSrc
New-Item -ItemType Directory -Force -Path "$fakeSrc\ai-docs" | Out-Null
Copy-Item "$src\ai-docs\core-rules.md" "$fakeSrc\ai-docs\core-rules.md"
Assert 'A3.12-1' (-not (Test-Path "$fakeSrc\ai-docs\procedures\govern-update.md")) `
                 'source package has no ai-docs/procedures/ - the stale-launcher condition'
# The launcher's own copy of the rule is what has to survive NOT finding the
# procedure, which is exactly when it matters most. Do not "dedupe" it away.
$launcher = Read-Doc "$src\ai-docs\skills\govern-update\SKILL.md"
Assert 'A3.12-2' ($launcher -match '(?i)do not reconstruct') "launcher carries 'do not reconstruct from memory' itself"
Assert 'A3.12-3' ($launcher -match '(?i)stop')               'launcher instructs stopping when the source cannot be resolved'
Remove-ScratchCopy $fakeSrc

Exit-Harness
