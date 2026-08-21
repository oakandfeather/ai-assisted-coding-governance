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
      $_ -notmatch '^(AGENTS\.md|CLAUDE\.md|\.env)$' -and
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
if ($legacyCopilot.Count) {
  Note 'legacy-cp' "retired .github/copilot-instructions.md still present in: $($legacyCopilot -join ', ') - refresh these arms, or keep it deliberately"
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
