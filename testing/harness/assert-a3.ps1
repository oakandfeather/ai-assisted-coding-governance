# A3.1 - A3.8 assertions. Run AFTER govern-update-run.ps1 -Apply.

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

$src = $RepoRoot
$tgt = $MockArms.update
$tierA = 'core-rules.md','coding-rules.md','writing-rules.md','coding-patterns.md','writing-patterns.md','agent-workflow.md'

"=== A3.1 - tier A replaced wholesale ==="
$drift = @()
foreach ($f in $tierA) {
  if ((Read-Doc "$src\ai-docs\$f") -ne (Read-Doc "$tgt\ai-governance\$f")) { $drift += $f }
}
Assert 'A3.1a' ($drift.Count -eq 0) "all 6 rule files match new upstream ($($drift -join ', '))"

"=== A3.2 - tier B re-derived, and the diff stayed reviewable ==="
$cl = Read-Doc "$tgt\CLAUDE.md"
Assert 'A3.2a' ($cl -match '@AGENTS\.md')                        'CLAUDE.md still the @AGENTS.md import'
# The three imports are the whole point of the tier-B replace: they are how
# core-rules.md, agent-workflow.md, and the client-profile index reach an agent
# at all, since AGENTS.md only links them. A tier B that dropped them would
# leave a file that still looks right and silently governs nothing.
Assert 'A3.2a2' (($cl -match '(?m)^@ai-governance/core-rules\.md\s*$') -and
                 ($cl -match '(?m)^@ai-governance/agent-workflow\.md\s*$') -and
                 ($cl -match '(?m)^@ai-governance/client-profiles\.md\s*$')) `
                                                                 'all three ai-governance imports survived the tier B replace'
Assert 'A3.2b' ($cl -notmatch '\(template\)')                    'CLAUDE.md banner stripped'

# GEMINI.md joined tier B on 2026-08-21, and it is the one tier-B file a real
# target usually does NOT have: every install predating that date lacks it, so
# for them the update ADDS the file rather than re-deriving it. That is the
# path govern-update.md calls "the one addition you will actually meet", and
# the aged update arm is its fixture - so assert the file is there afterwards,
# not merely that it was replaced.
$gm = Read-Doc "$tgt\GEMINI.md"
Assert 'A3.2f' ($gm -match '(?m)^@\./AGENTS\.md\s*$')            'GEMINI.md present after update, carrying the @./AGENTS.md import'
# The './' prefix is the whole reason this is a separate file rather than a
# copy of CLAUDE.md. A bare '@AGENTS.md' is not the form Antigravity's docs
# demonstrate and could fail silently, so a tier B that "normalized" the
# syntax must not pass.
Assert 'A3.2g' (($gm -match '(?m)^@\./ai-governance/core-rules\.md\s*$') -and
                ($gm -match '(?m)^@\./ai-governance/agent-workflow\.md\s*$') -and
                ($gm -match '(?m)^@\./ai-governance/client-profiles\.md\s*$')) `
                                                                 'all three ai-governance imports present, with the ./ prefix Antigravity documents'
Assert 'A3.2h' ($gm -notmatch '\(template\)')                    'GEMINI.md banner stripped'
# Tier B lost its second file on 2026-08-21 (CLI-only scope). The old A3.2c/d
# asserted the Copilot file's heading and its ai-governance/ links; both are
# gone with the file. What replaces them is the never-auto-delete rule: if the
# target still carries a pre-2026-08-21 Copilot file, govern-update must leave
# it on disk and raise it, not silently remove it.
$cpStale = "$tgt\.github\copilot-instructions.md"
if (Test-Path $cpStale) {
  Assert 'A3.2c' $true 'pre-2026-08-21 Copilot file left in place (removal is ask-only, never automatic)'
} else {
  Note   'A3.2c' 'no legacy .github/copilot-instructions.md in this target - never-auto-delete not exercised'
}

# The diff-hygiene half of A3.2: a file the plan called identical must not come
# back with a diff. Line-ending churn slips past a content-only local-content
# guard and rewrites every line, destroying the audit trail step 7 asks for.
Push-Location $tgt
$churn = @()
foreach ($f in 'CLAUDE.md', 'AGENTS.md',
               'ai-governance/core-rules.md', 'ai-governance/coding-rules.md',
               'ai-governance/writing-rules.md', 'ai-governance/coding-patterns.md',
               'ai-governance/writing-patterns.md',
               'ai-governance/agent-workflow.md', 'ai-governance/client-profiles.md') {
  $rawDiff  = (git diff --numstat pristine -- $f) -split "`t"
  $normDiff = (git diff --numstat --ignore-cr-at-eol pristine -- $f) -split "`t"
  $rawLines  = if ($rawDiff.Count  -ge 2) { [int]$rawDiff[0]  + [int]$rawDiff[1]  } else { 0 }
  $normLines = if ($normDiff.Count -ge 2) { [int]$normDiff[0] + [int]$normDiff[1] } else { 0 }
  if ($rawLines -gt 0 -and $normLines -eq 0) { $churn += "$f ($rawLines lines, 0 real)" }
}
Pop-Location
Assert 'A3.2e' ($churn.Count -eq 0) "no file rewritten by line-ending churn alone ($($churn -join '; '))"

"=== A3.3 - tier C replaced ONLY the mandatory-rules block ==="
$a = Read-Doc "$tgt\AGENTS.md"
$sections = 'Project overview','Tech stack','Common commands','Verification contract',
            'Security & CI expectations','Architecture & conventions','Compliance & accessibility',
            'Escalation','Keeping this file accurate','For the humans on this project'
$lost = $sections | Where-Object { $a -notmatch [regex]::Escape($_) }
Assert 'A3.3a' ($lost.Count -eq 0) "all target sections after the seam survived ($($lost -join ', '))"
Assert 'A3.3b' ($a -match '(?i)registrar')                      'target-specific project prose intact'

"=== A3.4 - THE DOUBLE-Active client TRAP ==="
$hdr   = [regex]::Match($a, '(?m)^.*\*\*Version:\*\*.*$').Value
$inBlk = [regex]::Match($a, '(?m)^\*\*Active client:\*\*[^\n]*$').Value
Assert 'A3.4a' ($hdr   -match 'Active client:\*\* Example State University \(ESU\)')   'header Active client survived filled'
Assert 'A3.4b' ($inBlk -match '^\*\*Active client:\*\* Example State University \(ESU\)') 'in-block Active client survived filled'
Assert 'A3.4c' ($inBlk -notmatch '\*\(')                                                'in-block Active client is NOT a placeholder'

"=== A3.5 - header metadata ==="
$today = Get-Date -Format 'yyyy-MM-dd'
Assert 'A3.5a' ($hdr -match "Last reviewed:\*\* $today")        "Last reviewed set to today ($today)"
Assert 'A3.5b' ($hdr -match '\*\*Version:\*\* 1\.1')            'Version bumped a minor step (1.0 -> 1.1)'

"=== A3.6 - the assertion is the RIGHT one ==="
# The target was filled, so the run must not have stopped and must not have
# reintroduced a placeholder. The mirror case - target already unfilled, so the
# placeholder is carried forward and reported - is covered by assert-a3-refusals.
$anyPh = ([regex]::Matches($a, '\*\([^)]*\)\*')).Count
Assert 'A3.6a' ($inBlk -notmatch '\*\(') 'no placeholder reintroduced where the target had a real value'
Note   'A3.6b' "$anyPh other *(...)* token(s) remain elsewhere in AGENTS.md"

"=== A3.7 - tier D merge ==="
$c = Read-Doc "$tgt\ai-governance\client-profiles.md"
Assert 'A3.7a' ($c -match 'Example State University \(ESU\)\*\* .{1,3} the active client') "target's first client entry preserved"
Assert 'A3.7b' ($c -match 'Northfield Community College \(NCC\)') 'MULTI-CLIENT LIST NOT TRUNCATED - second client survived'
Assert 'A3.7c' ($c -match 'Add each client as')                   'package paragraph present'
Assert 'A3.7d' ($c -notmatch '## Sample profile')                 'sample section absent'
Assert 'A3.7e' ($c -notmatch '\*\(none yet\)\*')                  'configured repo not reverted to the empty state'

"=== A3.8 - tier E untouched ==="
$snapPath = Join-Path $PSScriptRoot '.tier-e-snapshot.json'
if (-not (Test-Path -LiteralPath $snapPath)) {
  No 'A3.8' "no tier-E snapshot at $snapPath - run govern-update-run.ps1 -Apply first"
} else {
  $snap = Get-Content -LiteralPath $snapPath -Raw | ConvertFrom-Json
  $bad = @()
  foreach ($p in $snap.PSObject.Properties) {
    $f = Join-Path "$tgt\ai-governance\client-profiles" $p.Name
    if (-not (Test-Path -LiteralPath $f)) { $bad += "$($p.Name) MISSING"; continue }
    if ((Get-FileHash $f -Algorithm SHA256).Hash -ne $p.Value) { $bad += $p.Name }
  }
  Assert 'A3.8' ($bad.Count -eq 0) "client-profiles/ byte-identical to pre-update ($($bad -join ', '))"
}
Note 'A3.8b' "'not even read' is observable only from the runner's own tool log - self-reported"

Exit-Harness
