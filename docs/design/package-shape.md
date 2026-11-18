# Package shape: the rationale

*Why the governance package is built the way it is: how the files chain, why there are two entry files, why the installer is split, where client material lives, and how the testing track is organized. Root [`AGENTS.md`](../../AGENTS.md) holds the rules that follow from all this; this file holds the explanation and the alternatives that were rejected. It describes the current shape. How the shape got here is in [`CHANGELOG.md`](../../CHANGELOG.md).*

**Last reviewed:** 2026-11-17

---

## How the ai-docs files chain together

**One full body, thin pointers to it.** `AGENTS.template.md` is copied to a target repo's root as `AGENTS.md`, and its italicized `*(placeholders)*` are filled there. `CLAUDE.template.md` exists because Claude Code reads `CLAUDE.md` and, by default, skips `AGENTS.md` once a `CLAUDE.md` exists. So it imports `@AGENTS.md`, plus the three files described under *Multi-tool entry points* below.

**Monorepo support is split across two places on purpose.** The one-sentence *nested files never loosen* rule sits in the template's mandatory-rules block, because `govern-update` refreshes that block in an existing install and nothing else in the body. The how-to for the nested pair lives in `govern-init` step 8, which writes a two-line note into each nested `AGENTS.md` it creates. That way only repos with nested projects carry it, and it sits in the file a later editor opens. The argument is in [`docs/proposals/monorepo-support.md`](../proposals/monorepo-support.md).

**The `ai-governance/` set.** The canonical `AGENTS.md` links nine files plus `client-profiles/`, all kept together in `ai-governance/`:

| File | Role |
| --- | --- |
| `core-rules.md` | The portable, task-agnostic base (§§0–9, a TL;DR checklist, the one-line precedence statement), binding on every task |
| `coding-rules.md` | The code module (§§1–4): dependencies, security, testing, UI accessibility |
| `writing-rules.md` | The content module (§§1–6), including documentation about code. §6 is only the run-every-example rule, because an unrun command is a risk; audience and structure are craft |
| `database-rules.md` | The database-project module (§§1–5), for repos where the schema is the deliverable. It defers to `core-rules.md` §5's confirm gate and §1's data and secrets rules, and states only the schema-specific residue. It has no `database-patterns.md`, because its craft residue fails the risk-vs-craft test |
| `coding-patterns.md` | Engineering craft. It defers secrets and licensing to `core-rules.md`, and security and test quality to `coding-rules.md` |
| `writing-patterns.md` | Writing craft (§§1–5), with the same deferral: grounding and citations to `writing-rules.md` §§1–2, voice to §4, accessibility to §5, running examples to §6 |
| `agent-workflow.md` | How to work (§§1–8), `@`-imported on Claude Code. The `§3` and `§5` citations in an installed `AGENTS.md` sit below the block `govern-update` refreshes, so renumbering would silently repoint every client's citations |
| `agent-delegation.md` | The delegation detail behind `agent-workflow.md` §8. Linked rather than imported, so it costs nothing on a task that spawns no subagent |
| `client-profiles.md` | Per-client overrides, referenced by `core-rules.md` and the task modules |

**The two procedures.** `govern-init.md` scaffolds: copy, strip the banner, fill the placeholders. It contains no rule text, because rules in a procedure load only when someone runs it and leave no trace in the client's repo. Its step 1 stops on an install in any ancestor directory, and its step 8 offers nested project file pairs for a monorepo. `govern-update.md` replaces the eight portable rule files and the thin `CLAUDE.md`. It merges `AGENTS.md`, touching only the mandatory-rules block and preserving the filled `Active client`, and merges `ai-governance/client-profiles.md`, preserving the active-client paragraph. It never touches `ai-governance/client-profiles/` or nested project files.

**Deduplication is the point.** Each rule is stated once, in its owning file. Every other file carries a pointer, plus the short always-on core in the entry files. A second copy of a rule drifts, and an agent that happens to read the stale copy follows it.

## Multi-tool entry points

**Why two entry files.** Every supported CLI except Claude Code reads the root `AGENTS.md`. Claude Code reads `CLAUDE.md`. Claude Code v2.1.277 and later can read `AGENTS.md` directly, but by default it skips it whenever a `CLAUDE.md` exists, so the `@AGENTS.md` import is what delivers it under every setting. The import never loads it twice ([memory docs](https://code.claude.com/docs/en/memory)). The Copilot CLI reads both files.

**Rejected alternatives.** A build step that inlines the rules into each entry file was rejected because this repo has no build. Symlinked entry files were rejected because symlinks are fragile on Windows.

**The fidelity caveat.** `@AGENTS.md` pulls `AGENTS.md` into context and stops there. `AGENTS.md` reaches the rule files by link, and the agent must choose to follow a link. Governed Layer B arms have done real work having opened no rule file at all ([`run-log.md`](../../testing/run-log.md)). The one direct Codex measurement points the other way at n=1, so the claim stands as *contradicted*, with a second Codex draw pre-registered ([`coverage-matrix.md`](../../testing/coverage-matrix.md)). That is why:

- **`CLAUDE.md` imports `core-rules.md` and `agent-workflow.md`**, closing the gap for Claude Code. Codex has no import mechanism, so there every file is linked. The Copilot CLI documents `@` expansion in `AGENTS.md` and `CLAUDE.md` ([CLI instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)), so it should receive the same three imports. That is documented, not measured here.
- **`client-profiles.md` is imported as the index only.** `core-rules.md` §8's sensitive-by-default rule covers a profile that is *absent*, not one that was never read, so the pointer to which client binds has to arrive unconditionally. The profile body stays linked, so trivial edits don't pay for a client's full ruleset ([`context-cost-log.md`](../../context-cost-log.md)).
- **Both entry files also restate the non-negotiable core inline and define *load*.** The import covers Claude Code; the inline core is what binds on a CLI that never follows the link.
- **The imports don't reach a subfolder launch unapproved.** Claude Code started in a nested package loads the root `CLAUDE.md`, including its own text and any import that resolves inside the launch folder. It skips every import that resolves outside the launch folder until the user approves external imports for the project (`hasClaudeMdExternalIncludesApproved` in `~/.claude.json`). The root `AGENTS.md` and all three `ai-governance/` imports fall in that group. A headless session can't approve, so it never receives them. This was measured on CC 2.1.322 while building B-P4 ([`run-log.md`](../../testing/run-log.md), 2026-11-17). An interactive session gets a prompt. Claude Code's [memory documentation](https://code.claude.com/docs/en/memory) says it asks *"once per project, in a dialog at the start of an interactive session,"* and that *"If you decline, the imports stay disabled and the dialog doesn't appear again."* The prompt is documented; it is unmeasured here, and only the keys below are internal. A decline is the costly case: that clone's subfolder launches stay ungoverned with no second warning. Whether setting the keys afterwards restores delivery is unmeasured. So the never-loosens sentence in the mandatory-rules block doesn't arrive in exactly the session it exists for. The note `govern-init` step 8 writes into each nested `AGENTS.md` does, because it sits in the nested pair. Inlining rule text in the root `CLAUDE.md` would also arrive, but the thin pointer stays free of rule text. Instead, `govern-init` step 8 offers to set the approval keys, but only when it creates nested pairs. Set beforehand, the keys delivered the root imports to a headless subfolder launch in B-P4. They are internal state, per clone and per machine, so they can't ship in the repo. **A second cost has no fix yet:** in B-P4 the governed arm's `Read` of `coding-rules.md` and the ESU profile, which the root `AGENTS.md` only links, was denied under `acceptEdits`, because both sit outside the launch folder. That is the access limit in Claude Code's [large-codebases guide](https://code.claude.com/docs/en/large-codebases), *"That subtree only, until you grant more."* The same guide recommends starting in a subdirectory when *"Work is scoped to one package or subsystem,"* and its launch table doesn't mention the import approval. Under this package that launch needs the approval first; starting at the root needs nothing.

**Why the seventh non-negotiable stays retired.** The retired Copilot instruction files carried *"human review before merge; SAST, secret scanning, and dependency analysis in CI."* That inline copy never bound where it was measured (B-T1), and the requirement already lives in `AGENTS.template.md`'s *Security & CI expectations* section.

**Adopter asymmetry.** The procedures are tool-neutral prose, so Codex and Copilot CLI teams run the same install and update by pasting one instruction (README Path B). Only the slash commands are Claude-Code-only.

## Procedures vs. launchers

The installer and updater are procedures in `ai-docs/procedures/`, with thin launchers in `ai-docs/skills/`. It is the same one-body, thin-pointer shape as the entry files, for two reasons:

- **Any agent can run a procedure.** Neither invokes a tool or a tool-specific feature, so either works by pasting *"read this file and follow it exactly"* into any CLI. A skill runs only in Claude Code.
- **It removes a class of staleness.** `~/.claude/skills/` is a one-shot copy that `git pull` never touches. The launcher reads the procedure fresh from the source repo on every run, so a stale launcher looks for a path that isn't there and stops loudly instead of scaffolding the wrong shape.

The source-resolution ladder and *"do not reconstruct the rule files from memory"* stay in the launcher because both govern the case where the procedure cannot be found.

## Client material

Client material lives in two places, and `govern-init.md` reads from both:

- **The engagement repo.** The profile is at `ai-governance/client-profiles/<client>-profile.md` and the client's policy at `ai-governance/client-policies/<client>-policy.md`. Where the client won't permit the text in their repo, the profile's authority note cites the policy instead.
- **An optional private client overlay.** A separate private repo of `clients/<client>/profile.md` and `clients/<client>/policy.md`, resolved through `$AI_GOVERNANCE_CLIENTS_PATH`, so a client with several engagement repos is interviewed once. A missing overlay is not a stop.

The overlay is only ever a source. A path from an engagement repo into the overlay would resolve on the machine that ran the install and fail, silently, everywhere else. That is why the policy is copied into the engagement repo rather than linked.

## The testing track

`testing/` verifies two things: that the package installs correctly, and that its rules change agent behavior.

- **[`Governance-Test-Plan.md`](../../testing/Governance-Test-Plan.md)** is the plan. Layer A is mechanical: the build scripts, the shape and merge semantics of `govern-init` and `govern-update`, and the link and drift checks. Layer B is behavioral: baited scenarios run against an agent.
- **[`coverage-matrix.md`](../../testing/coverage-matrix.md)** maps rule to scenario to result. Coverage is complete against the TL;DR checklists of `core-rules.md`, `coding-rules.md`, `writing-rules.md`, and `database-rules.md`. It is representative, not exhaustive, for `agent-workflow.md`, `agent-delegation.md`, and the two patterns files.
- **[`harness/`](../../testing/harness/)** is the scripted half of Layer A. It resolves the mock's location relative to this repo; `GOVERNANCE_MOCK_ROOT` overrides it.
- **[`mock-app-setup.md`](../../testing/mock-app-setup.md)** is how to build the mock target repo, deliberately a single file.
- **[`run-log.md`](../../testing/run-log.md)** is the dated record behind the matrix: every session, its pre-registration, method findings, derived rule changes, and fixture revisions.
- **[`test-plan-changes.md`](../../testing/test-plan-changes.md)** records revisions to the plan, quoting the superseded wording so earlier results stay interpretable.

**Why every scenario has a control.** A scenario without an ungoverned baseline measures the model, not the package; the finding is the delta. **Why scenarios are baited.** If the violation is not the path of least resistance, a pass proves nothing.

## human-docs mapping

The sample client is **Example State University (ESU)**, a fictional *public university*. It was chosen because it carries three data levels, FERPA and HIPAA, open-records exposure, and mandatory accessibility, so one sample exercises most of what a profile can say. `Example-Client-AI-Policy.md` models the cite-only shape, so there is no policy text behind ESU. `client-profiles.md` points at the sample profile by name; `CLAUDE.template.md` does not mention it.
