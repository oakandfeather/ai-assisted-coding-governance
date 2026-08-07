# Layer A checks that check-layer-a.ps1 does not cover.
#
#   A2.8c-e - AGENTS.md structurally matches build/AGENTS.md. The sibling script
#             only compares rule files against empty-build/.
#   A2.9    - encoding, asserted deliberately and NOT folded into A2.8: A2.8
#             LF-normalizes both sides, so it normalizes encoding away by design.
#   A4.4    - placeholder-count invariant between AGENTS.template.md and build.ps1.

. "$PSScriptRoot\harness-common.ps1"
Reset-Harness
Assert-MockPresent

$g   = $MockArms.governed
$src = $RepoRoot

if (-not (Test-Path -LiteralPath (Join-Path $src 'build'))) {
  throw "build/ not found. Run scripts\build.ps1 first - it is the oracle for A2.8c-e and A4.4b."
}
if (-not (Test-Path -LiteralPath (Join-Path $src 'core-build'))) {
  throw "core-build/ not found. Run: scripts\build-empty.ps1 -Modules core -OutDir core-build - it is the oracle for the core-only arm."
}

# ---------------------------------------------------------------------------
"=== A2.8c-e - AGENTS.md structurally matches its build oracle ==="
# build/ is the oracle for STRUCTURE only. govern-init interviews for values and
# will never reproduce build.ps1's hardcoded sample-client strings, so compare
# the shape - heading sequence and the package-owned block - not the prose.
#
# Which oracle depends on the arm's module set. The mandatory-rules block varies
# with what was installed, so a core-only arm compared against the full build/
# would fail on the very lines the install was supposed to remove. Each arm is
# checked against the build assembled with the same selection.
$oracleFor = [ordered]@{
  governed    = 'build'        # full install, sample client filled in
  'core-only' = 'core-build'   # every optional module declined
}

function Get-Headings($text) {
  # Blank fenced blocks first. The target's Commands section contains shell
  # comments starting with '#', which are not headings - the same class of false
  # positive check-links.ps1 already guards against for link syntax.
  $t = [regex]::Replace($text, '(?s)```.*?```', '')
  [regex]::Matches($t, '(?m)^#{1,6}\s+(.+?)\s*$') | ForEach-Object { $_.Groups[1].Value }
}

function Get-Block($text) {
  $i = $text.IndexOf('Mandatory rules')
  if ($i -lt 0) { return $null }
  $start = $text.LastIndexOf("`n## ", $i) + 1
  $end   = $text.IndexOf("`n---", $start)
  if ($end -lt 0) { return $null }
  $text.Substring($start, $end - $start)
}

foreach ($armName in $oracleFor.Keys) {
  $oracleDir = Join-Path $src $oracleFor[$armName]
  if (-not (Test-Path -LiteralPath $oracleDir)) {
    throw "$($oracleFor[$armName])/ not found. Run scripts\build.ps1, and scripts\build-empty.ps1 -Modules core -OutDir core-build."
  }
  $targetAgents = Read-Doc (Join-Path $MockArms[$armName] 'AGENTS.md')
  $oracleAgents = Read-Doc (Join-Path $oracleDir 'AGENTS.md')

  $tH = Get-Headings $targetAgents
  $oH = Get-Headings $oracleAgents
  $hDiff = Compare-Object $oH $tH
  Assert 'A2.8c' ($null -eq $hDiff) "$armName : heading sequence identical to $($oracleFor[$armName])/ ($($oH.Count) headings)"
  if ($hDiff) { $hDiff | ForEach-Object { "        $($_.SideIndicator) $($_.InputObject)" } }

  $tB = Get-Block $targetAgents
  $oB = Get-Block $oracleAgents
  Assert 'A2.8d' (($null -ne $tB) -and ($null -ne $oB)) "$armName : mandatory-rules block locatable in both"
  if ($tB -and $oB) {
    # Neutralize the two independently-filled Active client values before comparing.
    $n = { param($s) $s -replace '(?m)(\*\*Active client:\*\*)[^\n]*', '$1 <VALUE>' }
    Assert 'A2.8e' ((& $n $tB) -eq (& $n $oB)) "$armName : mandatory-rules block identical to oracle (Active client neutralized)"
  }
}

# ---------------------------------------------------------------------------
""
"=== A2.9 - encoding (asserted deliberately, not folded into A2.8) ==="
# BOM absence is a HARD failure: a BOM in a Markdown file that Codex or Copilot
# reads is a real defect. Line endings are RECORDED, not failed - govern-init is
# prose an agent follows with ordinary file tools, and CRLF on Windows is the
# expected outcome, not a bug.

$installed = @()
$installed += Get-Item "$g\AGENTS.md", "$g\CLAUDE.md", "$g\.github\copilot-instructions.md"
$installed += Get-ChildItem "$g\ai-governance" -Recurse -File -Filter '*.md'

$bom = @(); $crlf = @(); $lf = @(); $mixed = @()
foreach ($f in $installed) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $bom += $f.Name }
  $text  = Read-DocRaw $f.FullName
  $nCrlf = ([regex]::Matches($text, "`r`n")).Count
  $nLf   = ([regex]::Matches($text, "(?<!`r)`n")).Count
  if     ($nCrlf -gt 0 -and $nLf -gt 0) { $mixed += "$($f.Name) (CRLF=$nCrlf LF=$nLf)" }
  elseif ($nCrlf -gt 0)                 { $crlf  += $f.Name }
  else                                  { $lf    += $f.Name }
}
Assert 'A2.9a' ($bom.Count -eq 0) "no BOM in any of the $($installed.Count) installed .md files ($($bom -join ', '))"
Assert 'A2.9b' ($mixed.Count -eq 0) "no file has mixed line endings ($($mixed -join ', '))"
Note   'A2.9c' "line endings observed: $($crlf.Count) CRLF, $($lf.Count) LF (recorded, not graded)"
if ($lf.Count -gt 0)   { "               LF files  : $($lf -join ', ')" }
if ($crlf.Count -gt 0) { "               CRLF files: $($crlf -join ', ')" }

# ---------------------------------------------------------------------------
""
"=== A4.4 - placeholder-count invariant ==="
# Placeholder tokens in AGENTS.template.md after banner slicing must equal the
# number of Replace-Placeholder calls in build.ps1. A placeholder nobody fills
# ships an unconfigured-looking repo; a call with no placeholder would already
# have thrown in build.ps1.

$tpl = Read-Doc "$src\ai-docs\AGENTS.template.md"
$sliceAnchor = '**Version:**'
$si = $tpl.IndexOf($sliceAnchor)
Assert 'A4.4a' ($si -ge 0) 'slice anchor found in AGENTS.template.md'
$sliced = if ($si -ge 0) { $tpl.Substring($si) } else { $tpl }

# Count placeholder OPENINGS - the regex \*\([^)]*\)\* misses placeholders whose
# body contains a ')', and several of build.ps1's prefixes are truncated for
# exactly that reason.
$tokens = ([regex]::Matches($sliced, '\*\(')).Count

$buildSrc  = Read-Doc "$src\scripts\build.ps1"
$callCount = ([regex]::Matches($buildSrc, '(?m)^\$agents = Replace-Placeholder ')).Count
Assert 'A4.4' ($tokens -eq $callCount) "template placeholders = $tokens, build.ps1 Replace-Placeholder calls = $callCount"

$left = ([regex]::Matches((Read-Doc "$src\build\AGENTS.md"), '\*\(')).Count
Assert 'A4.4b' ($left -eq 0) "build/AGENTS.md has $left unfilled placeholder openings (expect 0)"

Exit-Harness
