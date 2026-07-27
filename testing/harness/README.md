# Layer A harness

*The scripted half of [`../Governance-Test-Plan.md`](../Governance-Test-Plan.md). Layer A is mechanical and belongs in the verification contract, so it has to be fast enough that people actually run it.*

**Owner:** *(your company)* — Engineering · **Version:** 1.0 · **Last reviewed:** 2026-07-27 · **Review cycle:** Alongside any substantive change to `ai-docs/`.

---

## Where the mock lives

**Outside this repository**, per [`../mock-app-setup.md`](../mock-app-setup.md) — `govern-init` creates an `ai-governance/` directory, and [`../../AGENTS.md`](../../AGENTS.md) forbids that directory existing here.

`harness-common.ps1` derives the repo root from its own location and defaults the mock root to this repo's **parent** directory, expecting the six arms as `registrar-mock`, `-governed`, `-control`, `-unconfigured`, `-entryfiles-only`, `-update`. Override with:

```powershell
$env:GOVERNANCE_MOCK_ROOT = 'D:\somewhere\else'
```

The scripts stop with a clear message if the arms are not found. They never write inside an arm except where noted below.

## Running it

Run `scripts\build.ps1` and `scripts\build-empty.ps1` from the repo root first — `build/` and `empty-build/` are the oracles, and two of these scripts refuse to run without them.

```powershell
cd testing\harness
.\check-identity.ps1        # arms byte-identical outside the governance files
.\check-fixtures.ps1        # Layer B fixture presence + synthetic-data audit
.\check-layer-a.ps1         # A2 file shape, A4.2, A3 prerequisites, arm shape
.\check-layer-a-extra.ps1   # A2.8c-e, A2.9 encoding, A4.4 placeholder invariant
```

Each exits 0 on success and non-zero on any failure, so they work as gates.

**A3 is stateful and needs an upstream delta to pull.** Age the source on a scratch branch first — one change per tier, or tiers B, C and D pass vacuously:

| Tier | File to change | Exercises |
| --- | --- | --- |
| A | `ai-docs/coding-rules.md` | A3.1 |
| B | `ai-docs/copilot-instructions.template.md` | A3.2 |
| C | `ai-docs/AGENTS.template.md`, **inside** the mandatory-rules block | A3.3–A3.6 |
| D | `ai-docs/client-profiles.md`, the **"Add each client as…"** paragraph | A3.7 |

Then rebuild the oracles and run:

```powershell
.\govern-update-run.ps1              # plan only - writes nothing
.\govern-update-run.ps1 -Apply       # applies, and snapshots tier E
.\assert-a3.ps1                      # A3.1-A3.8
.\assert-a3-refusals.ps1             # A3.6 mirror, A3.9-A3.12
```

Afterwards, reset the arms and discard the scratch branch:

```powershell
git reset --hard pristine; git clean -fd      # -fd, NOT -fdx: node_modules is untracked
```

## Two traps these scripts exist to avoid

**PowerShell 5.1 decodes UTF-8-without-BOM as ANSI.** That mangles every em dash, middot, and the `⚠` in the mandatory-rules heading — which the structural checks index on. Read through `Read-Doc` / `Read-DocRaw` in `harness-common.ps1`, never bare `Get-Content`. The same applies to the scripts themselves: **keep them pure ASCII** and write non-ASCII as `\u` escapes in regexes, because PowerShell decodes `.ps1` source the same way.

**Preserve the target's line endings when writing.** `Write-DocLike` matches the file it is replacing. Normalizing them rewrites every line of every governance file, turning a small content change into an unreviewable diff — and the update procedure's last step asks the user to review exactly that diff as the audit trail.

## What is not scripted, and cannot be

Recorded so nobody reads a green run as more than it is:

- **A2.10 / A2.11** — that `govern-init` step 1 refuses, and that step 7 *offered* the README signpost, are transcript facts. The file tree only shows that nothing was written.
- **A3.8's "not even read"** — the hashes prove the tier-E files are unchanged; only the runner's tool log shows they were never opened.
- **A3.9–A3.12** test the **detection predicate** and that nothing is written. Whether an agent following the prose actually stops is Layer B.

Results go in [`../coverage-matrix.md`](../coverage-matrix.md), not here.
