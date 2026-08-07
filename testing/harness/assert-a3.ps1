# A3.1 - A3.8 assertions. Run AFTER govern-update-run.ps1 -Apply.

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

$src = $RepoRoot
$tgt = $MockArms.update
# Derived, not hardcoded: tier A is whichever modules this arm actually carries.
# A hardcoded list would assert against files a partial install legitimately
# lacks, and would quietly stop covering a module the package later adds.
$tierA    = Get-TierAFiles $tgt
$declined = Get-DeclinedModules $tgt

"=== A3.1 - tier A replaced wholesale ==="
$drift = @()
foreach ($f in $tierA) {
  if ((Read-Doc "$src\ai-docs\$f") -ne (Read-Doc "$tgt\ai-governance\$f")) { $drift += $f }
}
Assert 'A3.1a' ($drift.Count -eq 0) "all $($tierA.Count) installed rule files match new upstream ($($drift -join ', '))"

# A3.1b - the mirror of A3.10's never-auto-delete. A module absent before the
# update must still be absent after it: absence is an install-time choice, and
# an updater that "helpfully" restores it overrides the user silently.
#
# Asked of git, not of the current directory. $declined is read AFTER the update
# ran, so a module the updater wrongly added no longer looks declined and the
# check would pass vacuously - the pristine tag is the only honest baseline.
Push-Location $tgt
$addedFiles = @(git diff --name-only --diff-filter=A pristine -- 'ai-governance')
Pop-Location
Assert 'A3.1b' ($addedFiles.Count -eq 0) "no ai-governance/ file was added by the update ($($addedFiles -join ', '))"

"=== A3.2 - tier B re-derived, and the diff stayed reviewable ==="
$cl = Read-Doc "$tgt\CLAUDE.md"
$cp = Read-Doc "$tgt\.github\copilot-instructions.md"
Assert 'A3.2a' ($cl -match '@AGENTS\.md')                        'CLAUDE.md still the @AGENTS.md import'
Assert 'A3.2b' ($cl -notmatch '\(template\)')                    'CLAUDE.md banner stripped'
Assert 'A3.2c' ($cp -match '^# Coding rules for GitHub Copilot') 'copilot file starts at the right heading'
Assert 'A3.2d' ($cp -match 'ai-governance/core-rules\.md')       'copilot links point at ai-governance/, not ai-docs/'

# The diff-hygiene half of A3.2: a file the plan called identical must not come
# back with a diff. Line-ending churn slips past a content-only local-content
# guard and rewrites every line, destroying the audit trail step 7 asks for.
Push-Location $tgt
$churn = @()
# Entry files plus every rule file this arm actually installed - derived, so a
# partial install checks exactly what it carries and no more.
$churnPaths = @('CLAUDE.md', '.github/copilot-instructions.md', 'AGENTS.md') +
              @(Get-ExpectedRuleFiles $tgt | ForEach-Object { "ai-governance/$_" })
foreach ($f in $churnPaths) {
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
