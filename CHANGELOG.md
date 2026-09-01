# Changelog

*How the package got its current **shape** — every change to what it ships, which files carry which body, and which tools it targets, with the date and the reasoning behind it. [`AGENTS.md`](./AGENTS.md) and [`README.md`](./README.md) state the shape as it stands now; this file states what it used to be and why it changed.*

**Last reviewed:** 2026-09-01

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

## 2026-08-28 — client material has a home, and it is the engagement repo

`govern-init` step 6 told the agent the client's own AI policy was the upstream authority and to *"work from the document"* — without ever saying where that document came from. The only location the package named for a client policy was `human-docs/Example-Client-AI-Policy.md`, a single file inside this repo, which is public. So a fresh clone described a repo that talked as though it held your client's documents, had one slot for N clients, and could never legitimately hold any of them.

**The shape now:**

- **The policy is reproduced into the engagement repo**, at `ai-governance/client-policies/<client>.md`, beside the profile that summarizes it — created by `govern-init` step 6 out of the client's own document, **not** copied from source. The copied-from-source set is unchanged at nine `ai-governance/` items; a count that moved would be a bug.
- **`govern-init` asks where the document is** — a path, a URL, or a paste — and derives the profile from it before interviewing for what it doesn't cover, citing the section each field came from and pinning the policy's version. A field the policy is silent on is marked *not addressed*, never filled from general knowledge; a URL that won't fetch is treated as no document at all.
- **A cite-only fallback**, for a client who permits citation but not copying: no policy file, and the profile's authority note carries title, version, and canonical URL. The ESU sample models this shape.
- **`client-profiles.md` says where a policy lives and how two profiles compose** — the stricter governs rule by rule, and two rules that are *not comparable* (different disclosure formats, different escalation contacts, different data vocabularies) are a `core-rules.md` §7 stop-and-ask rather than a coin flip. Multi-client is supported by construction; `AGENTS.md`'s **Active client** may name more than one.
- **`govern-update` extends tier E over `client-policies/`** — never touched, never read — and must **report** a target that has profiles but no such directory. Every repo installed before this change is in that state, and nothing will create the directory for it; a silent update would leave `client-profiles.md` pointing at nothing, which is the original defect on fresh ground.

**The invariant behind all of it:** anything the engagement repo references must resolve for someone holding only that repo plus their normal client access. That is why the policy is copied rather than linked — a cross-repo path resolves only on the machines that happen to have it, and fails *silently* while the authority note still reads authoritative.

**An optional private client overlay was added as a second source.** A separate private repo of `clients/<client>/profile.md` and `clients/<client>/policy.md` — and never a rule file — so a client appearing in several engagement repos is interviewed once rather than re-derived and drifting. `govern-init` resolves it via `$AI_GOVERNANCE_CLIENTS_PATH`, treats a missing one as *not* a stop (unlike a missing source package), and **offers** rather than assumes the write-back of a newly authored profile. `govern-update` needs none: it never touches client files.

**`human-docs/Example-Client-AI-Policy.md` is now a shape template, not a slot.** No client policy is ever reproduced into this repository: it is public and gets copied into other clients' repos. `README.md`, root `AGENTS.md`, and the developer guideline's Appendix A were re-pointed at the engagement repo to match.

The proposal this came from, with the argument and the alternatives, is [`docs/proposals/client-material-topology.md`](./docs/proposals/client-material-topology.md) — now marked superseded rather than edited to match. Why no new Layer B scenario is owed, and the three Layer A rows added instead (A2.13, A3.13, A3.14), are in [`testing/run-log.md`](./testing/run-log.md), *Package change of 2026-08-28*.

## 2026-08-31 — `govern-init` installs; it no longer runs the target repo's commands

Step 5 of the installer required the agent to **execute** every command it wrote into the new `AGENTS.md` — install, run, test-all, single-test, lint, build, and the verification gate — before writing it in. So copying eleven Markdown files into a repo also ran that repo's dependency install, test suite, and build, on a toolchain the installer has no reason to assume is there, and fired seed- and migrate-class side effects nobody had asked for. That is the confirm-before-acting gate in `core-rules.md` §5 being spent by a procedure step rather than by the human.

**What the installer does now:** it sources each command from the repo's own configuration — `package.json` scripts, the CI workflow, the `Makefile` — writes it in **marked `unverified`**, and then offers **once**, opt-in and defaulting to no, to run them. A declined or unanswered offer is a normal install. `ai-docs/AGENTS.template.md` (v1.17) carries the same convention from the other side, for whoever fills the file later.

**The finding that put the run requirement there is still carried — by the marker, not by the run.** A 2026-08-15 Layer B attempt found the governed mock's own scaffolded `AGENTS.md` carrying an unverified worked invocation, and an agent trusting it over re-verifying; the measurement is in [`testing/run-log.md`](./testing/run-log.md) (*Attempt of 2026-08-15 — B-W6*) and is not restated here. The harm there is an unverified command **presented as verified**, which the marker fixes at lower cost — and the marker goes in the installed file rather than in the install hand-off, because the next agent reads `AGENTS.md` and never sees the transcript.

**`writing-rules.md` §6 is unchanged.** Its pass band already reads *run it **or** label the unrun parts unverified*, so this uses the second branch rather than weakening the first. No rule file moved, so no Layer B scenario is owed and no row is invalidated.

## 2026-09-01 — client profiles and policies get self-describing, paired filenames

`govern-init` authored the profile at `ai-governance/client-profiles/<client>.md` and the client's own policy at `ai-governance/client-policies/<client>.md`. Two files, the same name, distinguished only by which directory they sat in — so an editor tab, a search hit, a PR file list, or a hand-off line naming `esu.md` did not say which of the two it meant, and the pair that is supposed to read as profile-and-its-upstream-authority read as a duplicate.

**The convention now is `<client>-profile.md` beside `<client>-policy.md`**, with `<client>` a single lowercase kebab-case slug reused identically in both. The naming is stated in `ai-governance/client-profiles.md` (v1.7) — the file that ships into every engagement repo, so the copied index and the procedure agree — and `govern-init` follows it rather than owning it.

Two deliberate non-changes:

- **The private overlay keeps `clients/<client>/profile.md` and `clients/<client>/policy.md`.** The directory already carries the client name there, so the bare names are unambiguous; only `govern-init`'s copy *destinations* changed.
- **`ai-docs/client-profiles/example-university.md` was not renamed.** Its filename models nothing a derived profile copies — `govern-init` step 6 reads it for *shape*, step 2 never copies it, and step 4 deletes the sample link from the copied index — while `testing/mock-app-setup.md` pins that exact name in a Layer B fixture built outside this repo. Its body changed: the cite-only note now names `client-policies/example-university-policy.md`.

**Existing installs are grandfathered, and `govern-update` says so rather than fixing it.** Tier E matches `client-profiles/*.md` by glob, not by name pattern, so nothing breaks — but after an update an older install's refreshed index describes a shape its `esu.md` does not match. The procedure now states that this is cosmetic, that the convention governs newly authored profiles only, and that tier E still forbids renaming them.
