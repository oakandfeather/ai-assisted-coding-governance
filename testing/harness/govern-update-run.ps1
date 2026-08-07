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
# package exists to prevent. The optional-module transformation comes from
# scripts/module-lines.ps1 the same way (via harness-common.ps1), so the tier-B
# and tier-C rebuilds below use the very code govern-init used at install - which
# is what makes the byte-reproducibility check meaningful rather than circular.
#
# 'core-only' is a valid -Arm for exactly that check: run it against an
# unchanged source and the tier-C block must come back byte-identical.
#
# Writes go through Write-DocLike, which preserves the target's existing line
# endings. Normalizing them rewrites every line of every governance file and
# destroys the diff that step 7 asks the reviewer to read.
#
# Plan-only by default. Pass -Apply to write.

param(
  [switch]$Apply,
  [ValidateSet('update','governed','unconfigured','core-only')][string]$Arm = 'update'
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

# Derived from the target, not hardcoded. The package installs in modules and
# there is no manifest, so what is in ai-governance/ IS the record of what this
# repo chose. A hardcoded list here would make a declined module look like a
# missing file and pull it back in on every update.
$tierA    = Get-TierAFiles $tgt
$declined = Get-DeclinedModules $tgt

function Get-Header($t) {
  # Match the whole line that carries **Version:**, wherever it falls on the
  # line - an already-installed target may still lead with a field the current
  # template no longer has (e.g. a pre-existing Owner:), and govern-update never
  # rewrites header field structure, only the specific values it targets.
  $m = [regex]::Match($t, '(?m)^.*\*\*Version:\*\*.*$')
  if ($m.Success) { $m.Value } else { '' }
}
function Get-Field($h, $f) {
  $m = [regex]::Match($h, "\*\*$f\:\*\*\s*([^\u00B7\n]+)")
  if ($m.Success) { $m.Groups[1].Value.Trim() } else { '' }
}

# ---- step 4: the plan ------------------------------------------------------
"=== PLAN (step 4) ==="
"--- Tier A: replace wholesale ---"
foreach ($f in $tierA) {
  $s = Read-Doc "$src\ai-docs\$f"
  $sv = Get-Field (Get-Header $s) 'Version'
  $t = Read-Doc "$tgt\ai-governance\$f"
  $tv = Get-Field (Get-Header $t) 'Version'
  $state = if ($s -eq $t) { 'identical' } else { 'UPDATED' }
  "  {0,-20} {1,-10} v{2} -> v{3}" -f $f, $state, $tv, $sv
}

# Absent means declined, not stale. This is the exact mirror of A3.10's
# never-auto-delete: a module the install chose not to take is reported as
# available and left alone. Adding it back would silently undo the user's
# decision and re-inflate the context cost they were avoiding. We cannot tell a
# declined module from one added upstream since the install, and we do not need
# to - the answer to both is "offer it, don't take it".
if ($declined.Count -gt 0) {
  "--- Not installed here (available on request, NEVER auto-added) ---"
  foreach ($f in $declined) {
    $sv = Get-Field (Get-Header (Read-Doc "$src\ai-docs\$f")) 'Version'
    "  {0,-20} {1,-10} (absent) -> v{2}  [declined at install - offer, do not add]" -f $f, 'AVAILABLE', $sv
  }
}

"--- Tier B: re-derive from template, own gate ---"
$claudeNew = Read-Doc "$src\ai-docs\CLAUDE.template.md"
$ci = $claudeNew.IndexOf($aClaudeBody); if ($ci -lt 0) { throw "Anchor not found in CLAUDE template" }
$claudeNew = "# CLAUDE.md`n`n" + $claudeNew.Substring($ci)

$copilotNew = Read-Doc "$src\ai-docs\copilot-instructions.template.md"
$pi = $copilotNew.IndexOf($aCopilotBody); if ($pi -lt 0) { throw "Anchor not found in copilot template" }
$copilotNew = $copilotNew.Substring($pi)
# The template lists every module; this target may have declined some. Filter to
# the installed set or the refresh silently re-links files that are not there.
$copilotNew = Remove-ModuleLines $copilotNew (Get-InstalledModules $tgt) 'tier B copilot-instructions.md'

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
# An optional module absent from the target is reported above as declined, not
# here as "added upstream" - otherwise every partial install would read as
# behind. What is left here is a genuinely new file the package grew.
$added   = $srcSet | Where-Object { $_ -notin $tgtSet -and $_ -notin $OptionalModules }
$removed = $tgtSet | Where-Object { $_ -notin $srcSet }
if ($added)   { $added   | ForEach-Object { "    ADDED upstream  : $_  -> REPORT and offer, never auto-add" } } else { '    (none added)' }
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
  # $tierA is derived from what the target already has, so every entry here
  # exists. A module that is absent was declined and is never written - it was
  # reported as available in the plan above and that is where it stops.
  $path = "$tgt\ai-governance\$f"
  $s = Read-Doc "$src\ai-docs\$f"
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
# Filter to the installed module set BEFORE slicing the block out, so the
# lead-in/list/closing unit is removed as a whole when nothing is installed
# (procedure step 5). Doing it after the slice would work too, but this keeps the
# transformation applied to the same shape build.ps1 applies it to.
$sT = Remove-ModuleLines $sT (Get-InstalledModules $tgt) 'tier C AGENTS.md block'
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
# header: Version bumped a minor step; the header's own Active client left
# exactly as it was. Last reviewed -> today, EXCEPT when it is still the
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
Write-DocLike $cpPath $merged $cpPath
"  client-profiles.md : merged (target's client list preserved verbatim)"

"--- Tier E ---"
"  ai-governance/client-profiles/ : UNTOUCHED (listed only, contents not read)"
""
if ($Arm -eq 'update') { "APPLY COMPLETE. Tier-E snapshot written to $snapPath" }
else { "APPLY COMPLETE (arm '$Arm' refreshed; no tier-E snapshot written)." }
