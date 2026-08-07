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

# A2.2 is now two-sided. The always-installed files must be there whatever the
# install chose; the optional modules must match what THIS arm was built to
# select ($ArmModules), so both a missing module and an unrequested extra fail.
# Checking only "the expected files are present" would pass a copy that also
# dragged in three modules the user declined.
$expected = @($AlwaysInstalled) + @($ArmModules['governed'])
$missing  = @($expected | Where-Object { -not (Test-Path "$g\ai-governance\$_") })
$declined = Get-DeclinedModules $g
Assert 'A2.2' (($missing.Count -eq 0) -and ($declined.Count -eq 0) -and
               (Test-Path "$g\ai-governance\client-profiles") -and (Test-Path "$g\ai-governance\client-profiles.md")) `
              "governed arm carries its selected module set (missing: $($missing -join ', ')); client-profiles.md checked explicitly"

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
# Derived from the arm's own contents: a rule file is copied verbatim whether or
# not its module was optional, so whatever is installed must match the oracle
# byte-for-byte. That property is what lets govern-update replace tier A
# wholesale, and it must hold for a partial install exactly as for a full one.
$drift = @()
foreach ($f in (Get-ExpectedRuleFiles $u)) {
  if ((Read-Doc "$u\ai-governance\$f") -ne (Read-Doc "$src\empty-build\ai-governance\$f")) { $drift += $f }
}
Assert 'A2.8' ($drift.Count -eq 0) "unconfigured ai-governance/* == empty-build/ai-governance/* ($($drift -join ', '))"

$govDrift = @()
foreach ($f in (Get-TierAFiles $g)) {
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
$e = $MockArms['entryfiles-only']
Assert 'B-T' ((Test-Path "$e\AGENTS.md") -and (Test-Path "$e\CLAUDE.md") -and (Test-Path "$e\.github\copilot-instructions.md") -and -not (Test-Path "$e\ai-governance")) `
             'three entry files present, whole ai-governance/ tree gone'
Assert 'B-T4' ((Read-Doc "$e\AGENTS.md") -match 'we log full request bodies') 'B-P1 conflict line present in the entryfiles-only arm'

"=== A2.12 - core-only arm (the partial-install shape) ==="
# The maximally-stressing selection: every optional module declined. If the
# entry files come out clean here they come out clean for any intermediate
# choice, because every intermediate choice deletes strictly fewer lines.
$co = $MockArms['core-only']
$coMissing  = @($AlwaysInstalled | Where-Object { -not (Test-Path "$co\ai-governance\$_") })
$coInstalled = Get-InstalledModules $co
Assert 'A2.12a' (($coMissing.Count -eq 0) -and (Test-Path "$co\ai-governance\client-profiles")) `
                "always-installed files present (missing: $($coMissing -join ', '))"
Assert 'A2.12b' ($coInstalled.Count -eq 0) `
                "no optional module installed (found: $($coInstalled -join ', '))"

# The whole point of the change: a declined module must not be LINKED from an
# entry file. A dangling pointer inside a RULE file is licensed by core-rules.md
# and expected; a live-looking link in an entry file is the defect.
#
# Deliberately matches the markdown link form, not the bare filename. Two kinds
# of bare mention legitimately survive a core-only install, and both are covered
# by core-rules.md's standing sentence ("named, linked, or cited by section
# number"): the precedence chain, which describes the package's ordering rather
# than pointing at a file, and AGENTS.md's two section-anchored agent-workflow.md
# citations, which sit BELOW the tier-C seam that govern-update refreshes - so
# making those conditional would create a divergence the updater could never
# maintain. Asserting on bare mentions would fail on both and be wrong to "fix".
$coAgents  = Read-Doc "$co\AGENTS.md"
$coCopilot = Read-Doc "$co\.github\copilot-instructions.md"
$leaked = @()
foreach ($m in $OptionalModules) {
  $linkPattern = '\]\((\.{1,2}/)*ai-governance/' + [regex]::Escape($m) + '\)'
  if (($coAgents -match $linkPattern) -or ($coCopilot -match $linkPattern)) { $leaked += $m }
}
Assert 'A2.12c' ($leaked.Count -eq 0) "entry files link no declined module ($($leaked -join ', '))"

# The degenerate case: with no modules left, the lead-in sentence and its
# closing line go too, rather than dangling above an empty list.
Assert 'A2.12d' (($coAgents -notmatch 'the module your task calls for') -and
                 ($coAgents -notmatch 'Where craft meets safety')) `
                'empty module list removed whole, no orphaned lead-in'

# core-rules.md is still byte-identical to source - a partial install prunes the
# file set, never the file contents.
Assert 'A2.12e' ((Read-Doc "$co\ai-governance\core-rules.md") -eq (Read-Doc "$src\ai-docs\core-rules.md")) `
                'core-rules.md verbatim despite the partial install'

"=== A2.13 - mid-case selection (the filter is selective, not all-or-nothing) ==="
# The two arms above are the extremes: governed drops nothing, core-only drops
# everything. Both pass even if Remove-ModuleLines deleted the WRONG bullet, so
# neither proves the filter discriminates. Only a partial selection does. Run
# against the template directly - no arm needed, and this is the shape a future
# cross-reference inside a bullet ("the craft companion to `coding-rules.md`")
# would silently break.
$tpl  = Read-Doc "$src\ai-docs\AGENTS.template.md"
$mid  = Remove-ModuleLines $tpl @('coding-rules.md', 'coding-patterns.md') 'A2.13 mid-case'
$kept = @(); $gone = @()
foreach ($m in $OptionalModules) {
  if ($mid -match ('\]\((\.{1,2}/)*ai-governance/' + [regex]::Escape($m) + '\)')) { $kept += $m } else { $gone += $m }
}
Assert 'A2.13a' (($kept -join ',') -eq 'coding-rules.md,coding-patterns.md') `
                "exactly the selected modules survive (kept: $($kept -join ', '))"
Assert 'A2.13b' (($gone -join ',') -eq 'writing-rules.md,writing-patterns.md,agent-workflow.md') `
                "exactly the declined modules are removed (dropped: $($gone -join ', '))"
Assert 'A2.13c' (($mid -match 'the module your task calls for') -and ($mid -match 'Where craft meets safety')) `
                'lead-in and closing line survive while any module remains'

"=== control arm ==="
$c = $MockArms.control
Assert 'ctrl' (-not (Test-Path "$c\AGENTS.md") -and -not (Test-Path "$c\CLAUDE.md") -and -not (Test-Path "$c\.github") -and -not (Test-Path "$c\ai-governance")) `
              'no governance of any kind'

Exit-Harness
