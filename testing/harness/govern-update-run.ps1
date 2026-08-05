# A3 - executes ai-docs/procedures/govern-update.md against a mock arm.
#
# -Arm selects the target and defaults to 'update', the A3 arm. The other two
# values exist for FIXTURE MAINTENANCE, not for A3: when this repo's ai-docs/
# move ahead of the arms, A2.8/A2.8b/A2.8e go red on staleness rather than on a
# real defect, and refreshing is how you clear that. Never refresh the update
# arm this way - it is deliberately aged, and A3 has nothing to pull once it
# matches the source.
#
# Anchors are READ OUT OF scripts/build.ps1 (procedure step 2), never restated
# here: a third copy alongside the two build scripts is exactly the drift this
# package exists to prevent.
#
# Writes go through Write-DocLike, which preserves the target's existing line
# endings. Normalizing them rewrites every line of every governance file and
# destroys the diff that step 7 asks the reviewer to read.
#
# Plan-only by default. Pass -Apply to write.

param(
  [switch]$Apply,
  [ValidateSet('update','governed','unconfigured')][string]$Arm = 'update'
)

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

$src = $RepoRoot
$tgt = $MockArms[$Arm]
"TARGET ARM: $Arm  ($tgt)"
""

# ---- step 2: learn the anchors from build.ps1 ------------------------------
$bp = Read-Doc "$src\scripts\build.ps1"
function Anchor([string]$pattern, [string]$label) {
  $m = [regex]::Match($bp, $pattern)
  if (-not $m.Success) { throw "Anchor learning failed - build.ps1 no longer matches for $label" }
  $m.Groups[1].Value
}
$aAgentsBanner = Anchor "Slice-From \`$agents '([^']+)' 'AGENTS\.md banner'"              'AGENTS banner'
$aClaudeBody   = Anchor "Slice-From \`$claude '([^']+)' 'CLAUDE\.md body'"                'CLAUDE body'
$aCopilotBody  = Anchor "Slice-From \`$copilot '([^']+)' 'copilot-instructions\.md body'" 'copilot body'
$aFootnote     = "`n---`n*Fill in the italicized placeholders for this repository."

"ANCHORS LEARNED FROM build.ps1:"
"  AGENTS banner  : $aAgentsBanner"
"  CLAUDE body    : $aClaudeBody"
"  copilot body   : $aCopilotBody"
""

$tierA = 'core-rules.md','coding-rules.md','writing-rules.md','coding-patterns.md','writing-patterns.md','agent-workflow.md'

function Get-Header($t) {
  $m = [regex]::Match($t, '(?m)^\*\*Owner:\*\*[^\n]*$')
  if ($m.Success) { $m.Value } else { '' }
}
function Get-Field($h, $f) {
  $m = [regex]::Match($h, "\*\*$f\:\*\*\s*([^\u00B7\n]+)")
  if ($m.Success) { $m.Groups[1].Value.Trim() } else { '' }
}

# ---- step 4: the plan ------------------------------------------------------
"=== PLAN (step 4) ==="
"--- Tier A: replace wholesale, preserve locally-filled Owner ---"
foreach ($f in $tierA) {
  $s = Read-Doc "$src\ai-docs\$f"
  $sv = Get-Field (Get-Header $s) 'Version'
  $so = Get-Field (Get-Header $s) 'Owner'
  # Added upstream: the procedure says copy it in and report it (never the
  # reverse of A3.10's never-auto-delete). There is no target Owner to preserve.
  if (-not (Test-Path -LiteralPath "$tgt\ai-governance\$f")) {
    "  {0,-20} {1,-10} (absent) -> v{2}  [new upstream file - will be added]" -f $f, 'ADDED', $sv
    continue
  }
  $t = Read-Doc "$tgt\ai-governance\$f"
  $tv = Get-Field (Get-Header $t) 'Version'
  $to = Get-Field (Get-Header $t) 'Owner'
  $state = if ($s -eq $t) { 'identical' } else { 'UPDATED' }
  $ownerNote = if ($so -ne $to) { "  [preserve target Owner: '$to']" } else { '' }
  "  {0,-20} {1,-10} v{2} -> v{3}{4}" -f $f, $state, $tv, $sv, $ownerNote
}

"--- Tier B: re-derive from template, own gate ---"
$claudeNew = Read-Doc "$src\ai-docs\CLAUDE.template.md"
$ci = $claudeNew.IndexOf($aClaudeBody); if ($ci -lt 0) { throw "Anchor not found in CLAUDE template" }
$claudeNew = "# CLAUDE.md`n`n" + $claudeNew.Substring($ci)

$copilotNew = Read-Doc "$src\ai-docs\copilot-instructions.template.md"
$pi = $copilotNew.IndexOf($aCopilotBody); if ($pi -lt 0) { throw "Anchor not found in copilot template" }
$copilotNew = $copilotNew.Substring($pi)

$tierB = @(
  @{ Label = 'CLAUDE.md';                       Path = "$tgt\CLAUDE.md";                       New = $claudeNew  },
  @{ Label = '.github/copilot-instructions.md'; Path = "$tgt\.github\copilot-instructions.md"; New = $copilotNew }
)
foreach ($b in $tierB) {
  # Compare LF-normalized. A line-ending-only difference is not local content,
  # and treating it as such would put a meaningless gate in front of every run.
  $cur = Read-Doc $b.Path
  "  {0,-32} {1}" -f $b.Label, $(if ($cur -eq $b.New) { 'identical' } else { 'UPDATED' })
  $extra = ($cur -split "`n") | Where-Object { $_.Trim() -and ($b.New -notmatch [regex]::Escape($_.Trim())) }
  if ($extra) {
    "      LOCAL CONTENT in target not in template ($($extra.Count) line(s)) - ask before replacing:"
    $extra | ForEach-Object { "        > $_" }
  }
}

"--- Tier C: merge AGENTS.md (mandatory-rules block only) ---"
"--- Tier D: merge ai-governance/client-profiles.md ---"
"--- Tier E: NEVER TOUCH (listed, not read) ---"
$tierEDir = "$tgt\ai-governance\client-profiles"
# The unconfigured arm has no client-profiles/ directory - the interview that
# authors a profile was never run there. Absent is correct, not a failure.
if (Test-Path -LiteralPath $tierEDir) {
  Get-ChildItem $tierEDir -File | ForEach-Object { "    $($_.Name)" }
} else {
  "    (no client-profiles/ directory in this arm)"
}

"--- added / removed upstream ---"
$srcSet = (Get-ChildItem "$src\ai-docs" -File -Filter '*.md' | ForEach-Object { $_.Name }) | Where-Object { $_ -notmatch '\.template\.md$' }
$tgtSet = Get-ChildItem "$tgt\ai-governance" -File -Filter '*.md' | ForEach-Object { $_.Name }
$added   = $srcSet | Where-Object { $_ -notin $tgtSet }
$removed = $tgtSet | Where-Object { $_ -notin $srcSet }
if ($added)   { $added   | ForEach-Object { "    ADDED upstream  : $_" } }   else { '    (none added)' }
if ($removed) { $removed | ForEach-Object { "    REMOVED upstream: $_  -> REPORT, never auto-delete" } } else { '    (none removed)' }

if (-not $Apply) { ""; "PLAN ONLY - nothing written. Re-run with -Apply."; exit 0 }

# ---- snapshot tier E so assert-a3.ps1 can prove it was untouched -----------
# Only for the update arm: assert-a3.ps1 reads this one path, so writing it
# during a maintenance refresh of another arm would silently swap the baseline
# out from under the next A3 run.
$snapPath = Join-Path $PSScriptRoot '.tier-e-snapshot.json'
if ($Arm -eq 'update') {
  $snapshot = @{}
  Get-ChildItem $tierEDir -File | ForEach-Object { $snapshot[$_.Name] = (Get-FileHash $_.FullName -Algorithm SHA256).Hash }
  $snapshot | ConvertTo-Json | Set-Content -LiteralPath $snapPath -Encoding utf8
} else {
  "  (tier-E snapshot skipped - only the update arm feeds assert-a3.ps1)"
}

# ---- apply -----------------------------------------------------------------
""
"=== APPLY ==="

"--- Tier A ---"
foreach ($f in $tierA) {
  $path = "$tgt\ai-governance\$f"
  $s = Read-Doc "$src\ai-docs\$f"
  $so = Get-Field (Get-Header $s) 'Owner'
  if (-not (Test-Path -LiteralPath $path)) {
    # New upstream file. Model its line endings on a sibling that is already
    # installed, so it matches the rest of the copied set rather than the OS.
    Write-DocLike $path $s "$tgt\ai-governance\core-rules.md"
    "  $f : ADDED (new upstream file)"
    continue
  }
  $to = Get-Field (Get-Header (Read-Doc $path)) 'Owner'
  if ($so -ne $to -and $to) {
    $s = $s -replace [regex]::Escape("**Owner:** $so"), "**Owner:** $to"
    "  $f : preserved local Owner '$to'"
  }
  Write-DocLike $path $s $path
  "  $f : replaced"
}

"--- Tier B ---"
foreach ($b in $tierB) { Write-DocLike $b.Path $b.New $b.Path; "  $($b.Label) : re-derived" }

"--- Tier C: AGENTS.md ---"
$agentsPath = "$tgt\AGENTS.md"
$tA = Read-Doc $agentsPath
# target-side anchors (procedure step 5): heading -> the next '---'
$hStart = $tA.IndexOf('## ' + [char]0x26A0)
if ($hStart -lt 0) { $hStart = [regex]::Match($tA, '(?m)^##[^\n]*Mandatory rules').Index }
if ($hStart -lt 0) { throw "Target-side anchor not found: mandatory-rules heading" }
$hEnd = $tA.IndexOf("`n---", $hStart)
if ($hEnd -lt 0) { throw "Target-side anchor not found: seam '---' after the mandatory-rules block" }

# THE TRAP: extract the target's filled in-block Active client BEFORE replacing.
$oldBlock = $tA.Substring($hStart, $hEnd - $hStart)
$acMatch  = [regex]::Match($oldBlock, '(?m)^\*\*Active client:\*\*\s*(.+?)\s*(?=\u2192|->)')
$targetAC = if ($acMatch.Success) { $acMatch.Groups[1].Value.Trim() } else { '' }
$targetACWasFilled = $targetAC -and ($targetAC -notmatch '\*\(')
"  target in-block Active client : '$targetAC'  (filled=$targetACWasFilled)"

$sT = Read-Doc "$src\ai-docs\AGENTS.template.md"
$bi = $sT.IndexOf($aAgentsBanner); if ($bi -lt 0) { throw "Anchor not found: AGENTS banner" }
$sT = $sT.Substring($bi)
$fi = $sT.IndexOf($aFootnote);     if ($fi -lt 0) { throw "Anchor not found: AGENTS closing footnote" }
$sT = $sT.Substring(0, $fi)
$nStart = $sT.IndexOf('## ' + [char]0x26A0)
$nEnd   = $sT.IndexOf("`n---", $nStart)
$newBlock = $sT.Substring($nStart, $nEnd - $nStart)

if ($targetACWasFilled) {
  $newBlock = [regex]::Replace($newBlock, '(?m)(^\*\*Active client:\*\*\s*)\*\([^)]*\)\*', "`${1}$targetAC")
}
# step 5's assertion - the RIGHT one, not a blanket no-placeholders check
$survivor = [regex]::Match($newBlock, '(?m)^\*\*Active client:\*\*[^\n]*\*\([^)]*\)\*')
if ($targetACWasFilled -and $survivor.Success) {
  throw "STOP: target had a filled Active client but the merged block still contains a placeholder - substitution failed."
}
if (-not $targetACWasFilled -and $survivor.Success) {
  "  NOTE: target was already unconfigured; placeholder carried forward and reported (correct per step 5)."
}

$tA = $tA.Substring(0, $hStart) + $newBlock + $tA.Substring($hEnd)
# header: Version bumped a minor step; Owner and the header's own Active client
# left exactly as they were. Last reviewed -> today, EXCEPT when it is still the
# unfilled *(date)* placeholder - step 5's carve-out. That repo never completed
# govern-init's interview, so stamping a date asserts a review that did not
# happen. The skip is deliberate and reported; do not fold it back into the
# regex below, where it would read as an accident of the date-shaped pattern.
$hdr = Get-Header $tA
$ver = Get-Field $hdr 'Version'
$newVer = if ($ver -match '^(\d+)\.(\d+)$') { "$($Matches[1]).$([int]$Matches[2] + 1)" } else { $ver }
$newHdr = $hdr -replace [regex]::Escape("**Version:** $ver"), "**Version:** $newVer"
$rev = Get-Field $hdr 'Last reviewed'
if ($rev -and $rev -notmatch '\*\(') {
  $today   = Get-Date -Format 'yyyy-MM-dd'
  $newHdr  = $newHdr -replace '(\*\*Last reviewed:\*\*\s*)[0-9]{4}-[0-9]{2}-[0-9]{2}', "`${1}$today"
  $revNote = "Last reviewed -> $today"
} else {
  $revNote = "Last reviewed left unfilled at '$rev' (carried forward per step 5)"
}
$tA = $tA.Replace($hdr, $newHdr)
Write-DocLike $agentsPath $tA $agentsPath
"  AGENTS.md : merged (Version $ver -> $newVer, $revNote)"

"--- Tier D: client-profiles.md ---"
$cpPath = "$tgt\ai-governance\client-profiles.md"
$tC = Read-Doc $cpPath
$sC = Read-Doc "$src\ai-docs\client-profiles.md"
$sampleIdx = $sC.IndexOf('## Sample profile')
if ($sampleIdx -ge 0) { $sC = $sC.Substring(0, $sampleIdx).TrimEnd() + "`n" }
# Target-side bounded region: the heading through the paragraph beginning
# "Add each client as". build.ps1's '*(none yet)*' anchor is source-side only
# and is correctly absent from a configured target.
function Get-Region($text) {
  $a = $text.IndexOf('## Active client profiles')
  $b = $text.IndexOf('Add each client as', $a)
  if ($a -lt 0 -or $b -lt 0) { throw "Target-side anchors not found in client-profiles.md" }
  @($a, $b)
}
$tr = Get-Region $tC; $sr = Get-Region $sC
$merged = $sC.Substring(0, $sr[0]) + $tC.Substring($tr[0], $tr[1] - $tr[0]) + $sC.Substring($sr[1])
$so = Get-Field (Get-Header $sC) 'Owner'; $to = Get-Field (Get-Header $tC) 'Owner'
if ($so -ne $to -and $to) {
  $merged = $merged -replace [regex]::Escape("**Owner:** $so"), "**Owner:** $to"
  "  preserved local Owner '$to'"
}
Write-DocLike $cpPath $merged $cpPath
"  client-profiles.md : merged (target's client list preserved verbatim)"

"--- Tier E ---"
"  ai-governance/client-profiles/ : UNTOUCHED (listed only, contents not read)"
""
if ($Arm -eq 'update') { "APPLY COMPLETE. Tier-E snapshot written to $snapPath" }
else { "APPLY COMPLETE (arm '$Arm' refreshed; no tier-E snapshot written)." }
