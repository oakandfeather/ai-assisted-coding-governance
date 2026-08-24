# Changelog

*How the package got its current **shape** — every change to what it ships, which files carry which body, and which tools it targets, with the date and the reasoning behind it. [`AGENTS.md`](./AGENTS.md) and [`README.md`](./README.md) state the shape as it stands now; this file states what it used to be and why it changed.*

**Last reviewed:** 2026-08-23

## What belongs here, and what does not

This file records changes to the **package's shape and scope** — the file set, the entry-file routing, which agents are supported, which body owns which rule. Three neighbours hold the rest, and the split is worth keeping:

- What a **rule change cost the context window**, and every compression or deduplication pass → [`context-cost-log.md`](./context-cost-log.md).
- What a **Layer B run** found, and the rule edits derived from it → [`testing/run-log.md`](./testing/run-log.md).
- What the **test plan** used to say → [`testing/test-plan-changes.md`](./testing/test-plan-changes.md); what a row currently scores → [`testing/coverage-matrix.md`](./testing/coverage-matrix.md).

**A shape change usually has a record in one of those too, and that record is not repeated here.** The routing fix below was motivated by a Layer B finding and the run-log holds the measurement; this file holds what the package now looks like as a result. Point at the neighbour rather than restating it — a second copy of a measurement is the drift this package exists to prevent.

**This file starts on 2026-08-18.** Earlier shape changes are in `git log` and, where a run or a cost pass motivated them, in the three logs above; nothing was reconstructed here that those records don't already hold.

**One thing that deliberately does *not* move here.** A passage that reads as history but carries a forward instruction is a rule, not a record: *"do not add a seventh non-negotiable to 'restore' something"* stays in `AGENTS.md`, in the present tense, with enough of its subject quoted to be self-contained. Summarised into a dated entry here it would invite exactly the regression it prevents. See `AGENTS.md`'s *Editing conventions in this repo*.

---

## 2026-08-18 — `CLAUDE.md` imports the two always-on rule files directly

Before this, an installed `CLAUDE.md` was a single `@AGENTS.md` import, and `AGENTS.md` reached every rule file by plain relative Markdown link. The import delivers `AGENTS.md` and stops there, so the rules arrived only if the agent chose to follow a link — and four consecutive governed Layer B arms did real work having opened no `ai-governance/` file at all.

`CLAUDE.md` now imports `@ai-governance/core-rules.md` and `@ai-governance/agent-workflow.md` alongside `@AGENTS.md`. The other rule files stay linked, and on every non-Claude CLI every rule file stays linked; the fix closes the gap for Claude Code alone. The measurement, the reasoning, and the negative results behind it are in [`testing/run-log.md`](./testing/run-log.md), *Package change of 2026-08-18*.

## 2026-08-20 — the `client-profiles.md` **index** is imported too, and only the index

The profile *body* was considered for import and declined on cost: importing it would charge every trivial edit for a client's full ruleset. Nested `@` imports were measured first and do resolve, so the body could have been imported from inside the index — the shape was rejected on cost, not feasibility. That measurement, including the trap that a nested `@` path resolves against the importing file's directory rather than the repo root, is in [`testing/run-log.md`](./testing/run-log.md), *Package change of 2026-08-20*, and [`context-cost-log.md`](./context-cost-log.md).

## 2026-08-21 — narrowed to coding CLIs; the two Copilot files retired

The package had shipped `.github/copilot-instructions.md` — the repository-wide custom-instructions path for GitHub Copilot Chat and inline suggestions — plus its template. Both were removed, and in-IDE assistants went out of scope. The Copilot **CLI** and coding agent stay supported; they read the root `AGENTS.md` like every other non-Claude tool.

Three consequences worth having on the record:

- **The always-on-core drift surface halved.** `AGENTS.md`'s inline non-negotiables had to be kept in step across four files; they now live in two — `ai-docs/AGENTS.template.md` and this repo's own root `AGENTS.md`. That is the main maintenance win of the change. The superseded wording in `AGENTS.md` read *"two places, not the four it was before 2026-08-21."*
- **The seventh non-negotiable retired with those files, and the evidence says its inline copy was never doing the work.** The two Copilot files carried an extra inline item on human review and CI that the `AGENTS.md` core does not — quoted in full in `AGENTS.md`'s *Drift surface*, which also carries the standing rule not to re-add it. Layer A tracked the asymmetry as finding A4.3(iii), now closed as moot; [`testing/coverage-matrix.md`](./testing/coverage-matrix.md) records the Copilot inline core failing to bind (B-T1, fail in governed *and* entry-files-only) and the Codex inline core failing the same way, with only the linked file carrying the rule. The requirement itself did not go anywhere — `ai-docs/AGENTS.template.md` states it in its project-specific *Security & CI expectations* section.
- **The B-T section became the Codex arm.** The Copilot columns in `coverage-matrix.md` are closed rather than blank; see [`testing/test-plan-changes.md`](./testing/test-plan-changes.md) for the scope change and what it did to the rows.

The same change recorded, alongside the link-following claim rather than in place of it, that the only direct measurement of that claim contradicts it: Codex opened the linked rule files in 4/4 governed B-T runs. The claim itself was left standing at n=1 per cell, pending a second Codex draw — an **open item**, stated as such in `AGENTS.md`'s fidelity caveat and in [`testing/Governance-Test-Plan.md`](./testing/Governance-Test-Plan.md), not retired by being recorded here.

## 2026-08-22 — `database-rules.md` added as a fourth task module

Two task modules read on top of `core-rules.md` — `coding-rules.md` for application code, `writing-rules.md` for written deliverables. Neither covers a repo where **the schema itself is the deliverable**, declarative or migration-based, so a fourth was added (§§1–5: deploy guards as security settings, destructive schema change, reading the generated deploy script, drift and the source of truth, and the data that ships with the schema). It defers hard to `core-rules.md` — the general confirm-before-deploying gate stays in §5, synthetic data and secrets in §1 — and states only the schema-specific residue.

- **The install set went from 10 files to 11** (9 → 10 with no client), which is what `build.ps1` and `build-empty.ps1` now print. A1.1/A1.2 had been red since 2026-08-21 and went green again by coincidence when this change moved the counts back.
- **No `database-patterns.md` sibling, deliberately.** The craft residue fails the risk-vs-craft test — a missing index produces a worse system, not a false one — so `coding-patterns.md` stays its craft companion. `AGENTS.md`'s chain section carries the standing instruction not to add one without re-running that test.
- **Making the module reachable cost roughly twice what compressing it saved.** Routing it into the other files added +131 words across `core-rules.md`, `coding-rules.md`, `coding-patterns.md`, `agent-workflow.md`, and the entry file; the module's own compression pass returned −69. That ledger line, and the five stale word-count rows the same re-measurement caught, are in [`context-cost-log.md`](./context-cost-log.md).

The five B-D scenarios shipped blank and were run the same week, so `coverage-matrix.md`'s complete-coverage claim briefly excluded `database-rules.md` by name; it no longer does. The runs, the fixture, and the 2026-08-23 redesign of four of those rows are in [`testing/run-log.md`](./testing/run-log.md).
