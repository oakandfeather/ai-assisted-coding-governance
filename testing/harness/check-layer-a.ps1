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
Assert 'A2.1' ((Test-Path "$g\AGENTS.md") -and (Test-Path "$g\CLAUDE.md") -and (Test-Path "$g\.github\copilot-instructions.md")) `
              'entry files at correct paths'

$seven = 'core-rules.md','coding-rules.md','writing-rules.md','coding-patterns.md','agent-workflow.md','client-profiles.md'
$missing = $seven | Where-Object { -not (Test-Path "$g\ai-governance\$_") }
Assert 'A2.2' (($missing.Count -eq 0) -and (Test-Path "$g\ai-governance\client-profiles") -and (Test-Path "$g\ai-governance\client-profiles.md")) `
              'all seven ai-governance items present (client-profiles.md checked explicitly)'

Assert 'A2.3' (-not (Test-Path "$g\ai-governance\client-profiles\example-university.md")) 'sample profile NOT copied'
Assert 'A2.4' (-not (Test-Path "$g\human-docs") -and -not (Test-Path "$g\procedures") -and -not (Test-Path "$g\skills") -and -not (Test-Path "$g\testing")) `
              'excluded trees absent'

$agents  = Read-Doc "$g\AGENTS.md"
$claude  = Read-Doc "$g\CLAUDE.md"
$copilot = Read-Doc "$g\.github\copilot-instructions.md"
$bannersOff = ($agents -notmatch '\(template\)') -and ($agents -notmatch 'Fill in the italicized placeholders for this repository') -and
              ($claude -notmatch '\(template\)') -and ($claude.Trim().Split("`n").Count -le 6) -and
              ($copilot -match '^# Coding rules for GitHub Copilot')
Assert 'A2.5' $bannersOff 'banners and closing footnote stripped from all three entry files'

$ph = ([regex]'\*\([^)]*\)\*').Matches($agents)
Assert 'A2.7' ($ph.Count -eq 0) "AGENTS.md placeholder count = $($ph.Count) (expect 0)"

"=== A2.6 - empty-state rewrite (unconfigured copy, oracle = empty-build) ==="
$uc = Read-Doc "$u\ai-governance\client-profiles.md"
Assert 'A2.6a' ($uc -notmatch '## Sample profile') '## Sample profile deleted'
Assert 'A2.6b' ($uc -match '\*\(none yet\)\* .{1,3} \*\*this repo has no client profile\.\*\*') 'verbatim empty-state block present'
Assert 'A2.6c' ($uc -match 'Add each client as') '"Add each client as..." paragraph survives'

"=== A2.8 - rule files match the empty-build oracle (LF-normalized) ==="
$drift = @()
foreach ($f in $seven) {
  if ((Read-Doc "$u\ai-governance\$f") -ne (Read-Doc "$src\empty-build\ai-governance\$f")) { $drift += $f }
}
Assert 'A2.8' ($drift.Count -eq 0) "unconfigured ai-governance/* == empty-build/ai-governance/* ($($drift -join ', '))"

$govDrift = @()
foreach ($f in 'core-rules.md','coding-rules.md','writing-rules.md','coding-patterns.md','agent-workflow.md') {
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
Assert 'A3.1-prep' ((Read-Doc "$uu\ai-governance\coding-rules.md") -match '\*\*Owner:\*\* Registrar Modernization') 'locally-filled Owner on a tier-A file'
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
$e = $MockArms['entryfiles-only']
Assert 'B-T' ((Test-Path "$e\AGENTS.md") -and (Test-Path "$e\CLAUDE.md") -and (Test-Path "$e\.github\copilot-instructions.md") -and -not (Test-Path "$e\ai-governance")) `
             'three entry files present, whole ai-governance/ tree gone'
Assert 'B-T4' ((Read-Doc "$e\AGENTS.md") -match 'we log full request bodies') 'B-P1 conflict line present in the entryfiles-only arm'

"=== control arm ==="
$c = $MockArms.control
Assert 'ctrl' (-not (Test-Path "$c\AGENTS.md") -and -not (Test-Path "$c\CLAUDE.md") -and -not (Test-Path "$c\.github") -and -not (Test-Path "$c\ai-governance")) `
              'no governance of any kind'

Exit-Harness
