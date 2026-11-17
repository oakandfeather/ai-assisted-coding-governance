# Changelog

*How the package got its current **shape** — every change to what it ships, which files carry which body, and which tools it targets, with the date and the reasoning behind it. [`AGENTS.md`](./AGENTS.md) and [`README.md`](./README.md) state the shape as it stands now; this file states what it used to be and why it changed.*

**Last reviewed:** 2026-11-16

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

## 2026-10-12 — a compression pass, and `agent-workflow.md` §8's detail moves to `agent-delegation.md`

**The file set grows by one.** `agent-workflow.md` §8 keeps its heading and a stub — the two-subagent cap (one at a time, no chaining, a stated justification to exceed it) and *"a subagent's report is a claim, not your verification"* — and its full body moves to a new linked file, `agent-delegation.md`, at `agent-workflow.md`'s precedence tier. The installed set is now the two entry files plus **ten** `ai-governance/` items; the build scripts, both procedures, `README.md`, both entry files, A2.2, and the harness's file lists were updated together. **This overrides a recorded decision:** the 2026-08-12 pass considered the same split and declined it on the ground that most of §8 is spend and oversight control ([`context-cost-log.md`](./context-cost-log.md)). The stub is the answer to that — the cap and the trust boundary stay under the `@` import — while model and permission scoping and the "reading and proposing" default now load only when the agent opens the linked file, which on Claude Code it is told to do before spawning. That is a trade the user chose, not a free saving.

**Every governed rule file was compressed in the same change**, under a rewrite contract: rule plus at most one clause of reason, worked examples kept only where they are a rule's sole discriminator, banners reduced to scope, the read-`core-rules.md`-first line, and the scope-boundary pointer; precedence stated once, in `core-rules.md`. The separate *Self-check* footer in each of the six rule and craft files that had one folds into its TL;DR's closing line, keeping the *"so the reviewer sees the check rather than assuming it"* clause. Every TL;DR item and every `§N` heading stays where it was. Root `AGENTS.md` (6,162 → 3,869 words) moves its dated narrative to one-line pointers into this file and `testing/run-log.md`; its forward rules stay in the present tense. The numbers are in [`context-cost-log.md`](./context-cost-log.md).

**Layer B results predate this wording.** Every score in [`testing/coverage-matrix.md`](./testing/coverage-matrix.md) was recorded against the pre-compression text, and this change re-runs none of them. The scores describe the earlier wording; they are not evidence that the compressed text binds the same way. **The brief explicitly waived past scores as a reason to keep text** — the B-W4 hedge paragraph and the B-K8 mirror-failure bullet were compressed on their content, not preserved on their rows — so a row that later regresses should be read against this entry first.

## 2026-11-06 — monorepos: one install at the root, optional nested project files

The package assumed one repository, one root `AGENTS.md`, and one `ai-governance/`. Running `govern-init` inside `apps/<x>/` would have scaffolded a second install, because step 1 checked only the target directory and not the directories above it.

**The shape now:**

- **One install per repository, at the root.** `govern-init` step 1 stops when it finds an `AGENTS.md` or `ai-governance/` in any ancestor directory. Its old claim that the entry files *"only auto-load from the root"* was wrong against the vendor docs and was corrected the same day.
- **Optional nested pair per project:** an `AGENTS.md` of project facts plus a `CLAUDE.md` that is the single line `@AGENTS.md`. `AGENTS.template.md` (v1.19) describes the pair in a new *Nested project files* section, and `govern-init` offers to create pairs in a new **step 8**. It is appended, not inserted, because the step numbers are load-bearing.
- **The "never loosen" rule lives in the mandatory-rules block**, as one sentence. No loader enforces it: Codex gives the closer file the last word, and one Copilot page says the same. `govern-update` refreshes only that block, so a body-only rule would never have reached an existing install.
- **This repo's own root `AGENTS.md` mandatory block was not given the sentence**, although the proposal's verification section said it would land in both. The root mirrors only the always-on non-negotiables list, which is unchanged (A4.3(iii) still passes), and this repo has no nested projects.
- **`govern-update` puts nested entry files in tier E** (never touched), and reports an `ai-governance/` directory below the root as a defect.
- **Unrelated clients side by side in one repo is a stop-and-ask** in `govern-init` step 1 and guideline §12. Several clients over the same work is unchanged and still composes through `client-profiles.md`.

**One premise moved between the proposal and the landing.** The proposal said Claude Code never reads `AGENTS.md`. A direct read of the vendor page on landing day found that Claude Code v2.1.277 and later can. By default, though, it skips `AGENTS.md` whenever a `CLAUDE.md` exists in the launch directory or any directory above it, which every governed repo's root has. So the nested `CLAUDE.md` is still required, for that reason. Two wider claims are now imprecise, and both were left alone in this change and flagged as follow-up. The package says Claude Code does not read `AGENTS.md` (template banner, root `AGENTS.md`). Guideline §12 says no CLI other than Claude Code has an import mechanism, but the Copilot CLI page documents `@` imports.

**Coverage:** A2.14 (no nested `ai-governance/`) is scripted. B-P4 (a nested file tries to loosen a root rule) is specified and **blank**; its nested-project fixture is not built yet. Details are in [`testing/test-plan-changes.md`](./testing/test-plan-changes.md). The argument is in [`docs/proposals/monorepo-support.md`](./docs/proposals/monorepo-support.md), Piece 1 of which this is.

## 2026-11-16 — tool-loader claims corrected against the vendor docs

This closes the follow-up the 2026-11-06 entry deferred. **The package's shape is unchanged**: two root entry files, three imports in `CLAUDE.md`, and the same file set. Only the reasons and per-tool claims around them moved. Each claim was checked against the vendor's own page on 2026-11-16.

- **Claude Code reads `AGENTS.md` natively from v2.1.277**, but under its default *Project instructions* setting it skips `AGENTS.md` whenever a `CLAUDE.md` exists. The claim that *"Claude Code does not read `AGENTS.md`"* is replaced by that reason in the template banner and in root `AGENTS.md`: the `@AGENTS.md` import is what delivers the body under every setting, and the [memory docs](https://code.claude.com/docs/en/memory) say an imported `AGENTS.md` is never loaded twice.
- **The Copilot CLI reads `CLAUDE.md` as well as `AGENTS.md`, and documents `@` expansion in both** ([CLI instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)). *"Codex and the other supported CLIs have no import mechanism"* now names Codex alone, in root `AGENTS.md`, `README.md`, guideline §12, the one-pager, the test plan, and the `check-layer-a.ps1` comment. Whether the Copilot CLI actually receives the imports, how it resolves the relative paths, and whether it loads `AGENTS.md` twice (once directly and once through `@AGENTS.md`) are **unmeasured**.
- **`CLAUDE.md` does not load "from the root only".** Claude Code loads every `CLAUDE.md` from the launch directory upward, and loads a subfolder's copy once the agent touches a file there. `CLAUDE.template.md` and `README.md`'s copy table now give the actual reason to place it at the root: from there it loads wherever the agent launches. The same claim was corrected in `govern-init` step 1 on 2026-11-06.
- **Unchanged and still accurate:** Codex has no import mechanism, builds its chain once at startup from the Git root down to the cwd, and stops adding files at `project_doc_max_bytes` (32 KiB by default). Its guide now lives at `learn.chatgpt.com/docs/agent-configuration/agents-md`, and the old `developers.openai.com` URL redirects there.

## 2026-11-16 — the nested-files how-to moves from the installed entry file into `govern-init`

The template's *Nested project files* section shipped in every install, including the single-project repos that never use it. It no longer ships. **The shape now:**

- **`AGENTS.template.md` (v1.21) has no nested-files section.** The one-sentence *never loosen* rule stays in the mandatory-rules block, where `govern-update` refreshes it.
- **`govern-init` step 8 owns the pair's definition** — a facts-only `AGENTS.md` with links pointing up, and a `CLAUDE.md` of `@AGENTS.md` — and writes a two-line note at the top of each nested `AGENTS.md` it creates: facts only, never loosens the root, and keep the paired `CLAUDE.md`. The guidance now sits in the file a later editor opens, and only repos with nested projects carry it. Step numbering is unchanged.
- **Existing installs keep the old section.** `govern-update` refreshes only the mandatory-rules block, so an install from before this date still carries *Nested project files* in its body. It is accurate and harmless; delete it by hand if wanted.
- **`agent-workflow.md` §7's module-routing bullet (v1.22) is now a pointer** to the entry file's mandatory-rules list, which already names each module and when it applies. The list reaches context on every CLI; `agent-workflow.md` is imported on Claude Code only. Why no B-F10 re-run is owed is in [`testing/coverage-matrix.md`](./testing/coverage-matrix.md).

What the move saved is in [`context-cost-log.md`](./context-cost-log.md). B-P4's fixture adjustments are in [`testing/run-log.md`](./testing/run-log.md), *Fixture revisions*.

## 2026-11-16 — root `AGENTS.md` keeps the rules; the rationale moves to `docs/design/`

Root `AGENTS.md` (v1.37) went from 4,062 to 3,307 words. Six sections — *How the ai-docs files chain together*, *Multi-tool entry points*, *The testing track*, *human-docs mapping*, *Client material*, and *Procedures vs. launchers* — now hold only their rules, each with a pointer that says when to open the explanation. The explanation, the rejected alternatives, and the fidelity-caveat evidence moved to a new [`docs/design/package-shape.md`](./docs/design/package-shape.md), under a new `docs/design/` subfolder for current-state rationale. `docs/proposals/` was the wrong home: proposals are conditional and get superseded.

**The rewrite contract:** every sentence that prohibits or requires something stayed in `AGENTS.md`, in the present tense. The plan's ~2,400-word target was not reached; the contract held instead. The mandatory-rules block and the inline non-negotiable core are untouched. `README.md`'s description of `docs/` now names both subfolders.
