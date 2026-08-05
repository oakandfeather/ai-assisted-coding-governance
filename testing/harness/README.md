# Layer A harness

*The scripted half of [`../Governance-Test-Plan.md`](../Governance-Test-Plan.md). Layer A is mechanical and belongs in the verification contract, so it has to be fast enough that people actually run it.*

**Version:** 1.3 · **Last reviewed:** 2026-08-05 · **Review cycle:** Alongside any substantive change to `ai-docs/`.

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

## Refreshing the arms when `ai-docs/` moves ahead

The arms hold a governance copy installed at a point in time. Once this repo's rule files move past it, **A2.8 / A2.8b / A2.8e go red on staleness rather than on a defect** — the arms are behind, not wrong. Clear that by running the updater against them:

```powershell
.\govern-update-run.ps1 -Arm governed -Apply
.\govern-update-run.ps1 -Arm unconfigured -Apply
```

Then re-sync `…-entryfiles-only/`'s three entry files from `…-governed/` (that arm holds no `ai-governance/`, so the updater can't run there, and B-T only discriminates while its entry files match the governed arm's). Finally commit each refreshed arm and move its tag — the hygiene check asserts `tag=pristine, tree clean`:

```powershell
git add -A; git commit -m "Refresh installed governance to upstream (govern-update)"; git tag -f pristine
```

**Never refresh `…-update/`.** It is deliberately aged, and A3 has nothing to pull once it matches the source. `-Arm` defaults to `update` precisely so the A3 invocations above stay untouched; the maintenance values are opt-in, and only the `update` arm writes the tier-E snapshot `assert-a3.ps1` reads.

Distinguishing the two cases matters: a check that was **green before your edit and red after** is never staleness. A2.8e in particular oracles the tier-C mandatory-rules block that `govern-update` merges, so an edit inside `AGENTS.template.md`'s mandatory-rules block turns it red until the arms are refreshed — expected, but only alongside a deliberate refresh, never worked around.

### When you have *added* a rule file, not just edited one

A new file in `ai-docs/` fails **louder and differently**, so it reads as a defect when it is the same staleness: A2.2 fails outright on the item count and `check-layer-a.ps1` throws mid-run, before you reach the refresh step. Same fix — run the updater against the `governed` and `unconfigured` arms — but two things are specific to the add case:

- **The tier-A file list is hardcoded in three scripts**, not derived: `check-layer-a.ps1`'s count, `assert-a3.ps1`, and `govern-update-run.ps1`. All three need the new file, or A3.1a silently asserts against a short list.
- **Model the new file's line endings on an already-installed sibling** (`core-rules.md`) rather than the OS default, or it lands as the odd one out and A2.9c records the mismatch.

The runner handles an added file as of the `writing-patterns.md` change — it prints `ADDED` in the plan and writes the file on `-Apply`. Before that it threw on `Read-Doc` of a file the target didn't have.

## Two traps these scripts exist to avoid

**PowerShell 5.1 decodes UTF-8-without-BOM as ANSI.** That mangles every em dash, middot, and the `⚠` in the mandatory-rules heading — which the structural checks index on. Read through `Read-Doc` / `Read-DocRaw` in `harness-common.ps1`, never bare `Get-Content`. The same applies to the scripts themselves: **keep them pure ASCII** and write non-ASCII as `\u` escapes in regexes, because PowerShell decodes `.ps1` source the same way.

**Preserve the target's line endings when writing.** `Write-DocLike` matches the file it is replacing. Normalizing them rewrites every line of every governance file, turning a small content change into an unreviewable diff — and the update procedure's last step asks the user to review exactly that diff as the audit trail.

## What is not scripted, and cannot be

Recorded so nobody reads a green run as more than it is:

- **A2.10 / A2.11** — that `govern-init` step 1 refuses, and that step 7 *offered* the README signpost, are transcript facts. The file tree only shows that nothing was written.
- **A3.8's "not even read"** — the hashes prove the tier-E files are unchanged; only the runner's tool log shows they were never opened.
- **A3.9–A3.12** test the **detection predicate** and that nothing is written. Whether an agent following the prose actually stops is Layer B.

Results go in [`../coverage-matrix.md`](../coverage-matrix.md), not here.
