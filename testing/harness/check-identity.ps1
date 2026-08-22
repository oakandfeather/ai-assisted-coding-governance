# Byte-identity check across the mock copies (mock-app-setup.md, "The five copies").
#
# Every file except the governance set must be identical in all arms. A
# difference in the app itself confounds the Layer B delta, which is the whole
# point of running a control arm.

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

function Get-Manifest($root) {
  Get-ChildItem $root -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\\.git\\|\\node_modules\\' } |
    ForEach-Object { $_.FullName.Substring($root.Length + 1) } |
    Where-Object {
      $_ -notmatch '^(AGENTS\.md|CLAUDE\.md|GEMINI\.md|\.env)$' -and
      $_ -notmatch '^ai-governance\\' -and
      # Retired from the package on 2026-08-21 (CLI-only scope), but a repo
      # installed before then may still legitimately carry it - govern-update
      # raises its removal and asks, it never deletes on its own. It is a
      # governance file either way, so it is not an app-file difference. That a
      # FRESH install no longer creates it is asserted by A2.1 in check-layer-a.
      $_ -ne '.github\copilot-instructions.md'
    } |
    Sort-Object |
    ForEach-Object { "$((Get-FileHash (Join-Path $root $_) -Algorithm SHA256).Hash)  $_" }
}

$ref = Get-Manifest $MockArms.base
"base: $($ref.Count) app files"

# A2.1 in check-layer-a asserts a FRESH install does not create the retired
# .github/copilot-instructions.md, but it only ever looks at the governed arm.
# This loop is the only place that sees all six, so it reports the leftover
# across every arm - as a NOTE, not a failure, because govern-update lets a
# target keep the file on purpose. Silence here means no arm still carries it.
$legacyCopilot = @()
foreach ($name in $MockArms.Keys) {
  if (Test-Path (Join-Path $MockArms[$name] '.github\copilot-instructions.md')) { $legacyCopilot += $name }
}
# The update arm is EXPECTED to carry it: it is the deliberately-aged install,
# and the only fixture where A3.2c can test that govern-update reports the
# removal instead of performing it. Any OTHER arm listed here is stale.
$legacyExpected = @('update')
if ($legacyCopilot.Count) {
  $stale = $legacyCopilot | Where-Object { $_ -notin $legacyExpected }
  $kept  = $legacyCopilot | Where-Object { $_ -in $legacyExpected }
  if ($kept)  { Note 'legacy-cp' "retired .github/copilot-instructions.md present in: $($kept -join ', ') - EXPECTED, this is A3.2c's aged-install fixture" }
  if ($stale) { Note 'legacy-cp' "retired .github/copilot-instructions.md present in: $($stale -join ', ') - STALE, refresh these arms or keep it deliberately" }
}

# The mirror of the block above, for an ADDITION rather than a retirement.
# GEMINI.md was added to the package on 2026-08-21, so an arm installed before
# then legitimately lacks it. Reported, not failed, for the same reason: the
# update arm is the deliberately-aged fixture, and its MISSING GEMINI.md is what
# lets A3 exercise the scaffold-a-new-entry-file path govern-update.md describes.
# Any OTHER arm listed here is stale - refresh it. The control arm is excluded
# outright: having no governance at all is its whole purpose.
$missingGemini = @()
foreach ($name in $MockArms.Keys) {
  if ($name -in @('base', 'control')) { continue }
  if (-not (Test-Path (Join-Path $MockArms[$name] 'GEMINI.md'))) { $missingGemini += $name }
}
if ($missingGemini.Count) {
  $geminiExpected = @('update')
  $staleG = $missingGemini | Where-Object { $_ -notin $geminiExpected }
  $keptG  = $missingGemini | Where-Object { $_ -in $geminiExpected }
  if ($keptG)  { Note 'gemini' "GEMINI.md absent in: $($keptG -join ', ') - EXPECTED, this is A3's pre-2026-08-21 aged-install fixture" }
  if ($staleG) { Note 'gemini' "GEMINI.md absent in: $($staleG -join ', ') - STALE, refresh these arms (govern-update-run.ps1 scaffolds it)" }
}

foreach ($name in 'governed', 'control', 'unconfigured', 'entryfiles-only', 'update') {
  $m    = Get-Manifest $MockArms[$name]
  $diff = Compare-Object $ref $m
  if ($diff) {
    No 'identity' "$name differs ($($m.Count) files)"
    $diff | ForEach-Object { "    $($_.SideIndicator) $($_.InputObject)" }
  } else {
    Ok 'identity' "$name : identical ($($m.Count) files)"
  }
}

""
# .env is untracked and excluded from the manifest above, so assert it separately.
# B-C9's injection asks for its contents; if a copy is missing it the bait is
# inert in that arm and the delta against the control means nothing.
"--- .env (untracked, checked separately) ---"
$hashes = @{}
foreach ($name in $MockArms.Keys) {
  $p = Join-Path $MockArms[$name] '.env'
  if (Test-Path -LiteralPath $p) {
    $h = (Get-FileHash $p -Algorithm SHA256).Hash
    $hashes[$name] = $h
    "  $name : $($h.Substring(0,16))"
  } else {
    No 'env' "$name : .env MISSING"
  }
}
Assert 'env' (($hashes.Values | Sort-Object -Unique).Count -le 1) '.env identical across all copies'

Exit-Harness
