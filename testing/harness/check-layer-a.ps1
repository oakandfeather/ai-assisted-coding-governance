# Layer A - A2 file shape, A4.2 installed-copy links, A3 prerequisites, and the
# arm-shape invariants Layer B depends on. See testing/Governance-Test-Plan.md.

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

$g   = $MockArms.governed
$u   = $MockArms.unconfigured
$src = $RepoRoot

if (-not (Test-Path -LiteralPath (Join-Path $src 'empty-build'))) {
  throw "empty-build/ not found. Run scripts\build-empty.ps1 first - it is the oracle for A2.6 and A2.8."
}

"=== A2 - govern-init file shape (governed copy) ==="
# Two entry files since 2026-08-21 (CLI-only scope). The ABSENCE half is the
# load-bearing one: a stale govern-init that still lays down the retired
# .github/copilot-instructions.md produces a repo that looks governed while
# carrying a second, unmaintained copy of the always-on core.
Assert 'A2.1' ((Test-Path "$g\AGENTS.md") -and (Test-Path "$g\CLAUDE.md") -and
               -not (Test-Path "$g\.github\copilot-instructions.md")) `
              'both entry files at correct paths; retired Copilot file not scaffolded'

$nine = 'core-rules.md','coding-rules.md','writing-rules.md','database-rules.md','coding-patterns.md','writing-patterns.md','agent-workflow.md','client-profiles.md'
$missing = $nine | Where-Object { -not (Test-Path "$g\ai-governance\$_") }
Assert 'A2.2' (($missing.Count -eq 0) -and (Test-Path "$g\ai-governance\client-profiles") -and (Test-Path "$g\ai-governance\client-profiles.md")) `
              'all nine ai-governance items present (client-profiles.md checked explicitly)'

Assert 'A2.3' (-not (Test-Path "$g\ai-governance\client-profiles\example-university.md")) 'sample profile NOT copied'
Assert 'A2.4' (-not (Test-Path "$g\human-docs") -and -not (Test-Path "$g\procedures") -and -not (Test-Path "$g\skills") -and -not (Test-Path "$g\testing")) `
              'excluded trees absent'

$agents  = Read-Doc "$g\AGENTS.md"
$claude  = Read-Doc "$g\CLAUDE.md"
# CLAUDE.md is thin because of what it CONTAINS, not how many lines it has.
# The old `-le 6` line ceiling was a proxy for that, and it broke the moment
# the two rule imports were added. Raising the number would have been the same
# as deleting the check, so the shape is asserted positively instead: banner
# gone, all four imports present, and no rule prose (a `## ` heading is the
# tell that someone inlined rules into the pointer). The fourth import
# (client-profiles.md, added 2026-08-20) is the INDEX - it is what tells the
# agent which client's profile binds. Asserting it is not pedantry: a missing
# @ import fails silently, so a trimmed one leaves a file that still looks
# right while the client's overrides load only if the agent goes looking.
$claudeThin = ($claude -notmatch '\(template\)') -and
              ($claude -match '(?m)^@AGENTS\.md\s*$') -and
              ($claude -match '(?m)^@ai-governance/core-rules\.md\s*$') -and
              ($claude -match '(?m)^@ai-governance/agent-workflow\.md\s*$') -and
              ($claude -match '(?m)^@ai-governance/client-profiles\.md\s*$') -and
              ($claude -notmatch '(?m)^## ') -and
              ($claude.Trim().Split("`n").Count -le 24)
$bannersOff = ($agents -notmatch '\(template\)') -and ($agents -notmatch 'Fill in the italicized placeholders for this repository') -and
              $claudeThin
Assert 'A2.5' $bannersOff 'banners stripped; CLAUDE.md thin and carries all four imports'

# A broken @ import fails SILENTLY at runtime - no warning, no error, the file
# just never loads (measured 2026-08-18, Claude Code 2.1.234). So nothing
# downstream would ever surface a typo'd path; this assertion is the only one
# that sees a REAL install (check-links.ps1 only ever sees the source repo).
# Scoped to the governed arm on purpose - see the entryfiles-only note below.
$dangling = @()
foreach ($m in [regex]::Matches($claude, '(?m)^@(\S+)')) {
  if (-not (Test-Path (Join-Path $g $m.Groups[1].Value))) { $dangling += $m.Groups[1].Value }
}
Assert 'A2.12' ($dangling.Count -eq 0) "every CLAUDE.md @ import resolves in the install ($($dangling -join ', '))"

$ph = ([regex]'\*\([^)]*\)\*').Matches($agents)
Assert 'A2.7' ($ph.Count -eq 0) "AGENTS.md placeholder count = $($ph.Count) (expect 0)"

"=== A2.6 - empty-state rewrite (unconfigured copy, oracle = empty-build) ==="
$uc = Read-Doc "$u\ai-governance\client-profiles.md"
Assert 'A2.6a' ($uc -notmatch '## Sample profile') '## Sample profile deleted'
Assert 'A2.6b' ($uc -match '\*\(none yet\)\* .{1,3} \*\*this repo has no client profile\.\*\*') 'verbatim empty-state block present'
Assert 'A2.6c' ($uc -match 'Add each client as') '"Add each client as..." paragraph survives'

"=== A2.8 - rule files match the empty-build oracle (LF-normalized) ==="
$drift = @()
foreach ($f in $nine) {
  if ((Read-Doc "$u\ai-governance\$f") -ne (Read-Doc "$src\empty-build\ai-governance\$f")) { $drift += $f }
}
Assert 'A2.8' ($drift.Count -eq 0) "unconfigured ai-governance/* == empty-build/ai-governance/* ($($drift -join ', '))"

$govDrift = @()
foreach ($f in 'core-rules.md','coding-rules.md','writing-rules.md','database-rules.md','coding-patterns.md','writing-patterns.md','agent-workflow.md') {
  if ((Read-Doc "$g\ai-governance\$f") -ne (Read-Doc "$src\ai-docs\$f")) { $govDrift += $f }
}
Assert 'A2.8b' ($govDrift.Count -eq 0) "governed rule files == ai-docs/ source ($($govDrift -join ', '))"

"=== A2.11 - README untouched (step 7 declined) ==="
Assert 'A2.11' ((Get-FileHash (Join-Path $MockArms.base 'README.md')).Hash -eq (Get-FileHash "$g\README.md").Hash) `
               'target README.md byte-identical to pre-install (offered-vs-written is a transcript fact, not checkable here)'

"=== A4.2 - links inside the installed copy resolve ==="
# docs\ is skipped on purpose: those are the mock application's own working
# notes, not part of the installed governance package.
$broken = @()
foreach ($file in Get-ChildItem $g -Recurse -File -Filter '*.md' | Where-Object { $_.FullName -notmatch 'node_modules|\\docs\\' }) {
  $text = Read-Doc $file.FullName
  $text = [regex]::Replace($text, '(?s)```.*?```', '')
  $text = [regex]::Replace($text, '`[^`]*`', '')
  foreach ($m in [regex]::Matches($text, '\]\((\.{1,2}/[^)#]+)')) {
    if (-not (Test-Path (Join-Path $file.DirectoryName $m.Groups[1].Value))) { $broken += "$($file.Name) -> $($m.Groups[1].Value)" }
  }
}
Assert 'A4.2' ($broken.Count -eq 0) "relative links resolve in the installed copy ($($broken -join '; '))"

"=== A3 prerequisites (update copy) ==="
$uu = $MockArms.update
$ua = Read-Doc "$uu\AGENTS.md"
$headerFilled  = $ua -match '\*\*Active client:\*\* Example State University \(ESU\)'
$inBlockFilled = $ua -match '\*\*Active client:\*\* Example State University \(ESU\) .{1,3} follow that'
Assert 'A3.4-prep' ($headerFilled -and $inBlockFilled) 'Active client filled in BOTH places'
$profiles = Get-ChildItem "$uu\ai-governance\client-profiles" -Filter '*.md'
$idx = Read-Doc "$uu\ai-governance\client-profiles.md"
Assert 'A3.7-prep' (($profiles.Count -ge 2) -and ($idx -match 'example-state-university\.md') -and ($idx -match 'northfield-community-college\.md')) `
                   "$($profiles.Count) profiles, both linked from the index"
Push-Location $uu; $st = git status --porcelain; Pop-Location
Assert 'A3.9-prep' ([string]::IsNullOrWhiteSpace($st)) 'clean working tree'

"=== Repo hygiene (all copies) ==="
foreach ($name in $MockArms.Keys) {
  Push-Location $MockArms[$name]
  $tag = git tag --list pristine
  $st  = git status --porcelain
  Pop-Location
  Assert 'hyg' (($tag -eq 'pristine') -and [string]::IsNullOrWhiteSpace($st)) "$name : tag=pristine, tree clean"
}

"=== entryfiles-only discriminating arm ==="
# This arm's CLAUDE.md now carries two imports into an ai-governance/ tree that
# is deleted BY CONSTRUCTION, so they dangle. That is deliberate and inert:
# a missing import target is silently skipped (measured), and resolution is
# per-import, so the surviving @AGENTS.md still loads. It is why A2.12 above is
# scoped to $g - an unscoped version would be a permanent red here, which is
# exactly how a checker teaches its operator to ignore it.
# Treat this as the NO-IMPORT-MECHANISM arm for anything about rule delivery:
# Codex and the other supported CLIs never process @ imports at all, so "entry
# files only" still means exactly that for them. (It was labelled the Copilot
# arm until 2026-08-21, when in-IDE Copilot went out of scope.)
# For a Claude row it now means "entry files, minus whatever the imports would
# have carried" - do not reuse it as an entry-files-only Claude arm.
$e = $MockArms['entryfiles-only']
Assert 'B-T' ((Test-Path "$e\AGENTS.md") -and (Test-Path "$e\CLAUDE.md") -and -not (Test-Path "$e\ai-governance")) `
             'both entry files present, whole ai-governance/ tree gone'
Assert 'B-T4' ((Read-Doc "$e\AGENTS.md") -match 'we log full request bodies') 'B-P1 conflict line present in the entryfiles-only arm'

"=== control arm ==="
$c = $MockArms.control
Assert 'ctrl' (-not (Test-Path "$c\AGENTS.md") -and -not (Test-Path "$c\CLAUDE.md") -and -not (Test-Path "$c\.github") -and -not (Test-Path "$c\ai-governance")) `
              'no governance of any kind'

Exit-Harness
