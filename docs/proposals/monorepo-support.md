# Proposal — monorepo support: one install at the root, thin project files beneath it

**Version:** 1.2 · **Last reviewed:** 2026-11-16 · **Status:** **Piece 1 implemented 2026-11-06; Piece 2's fixture specified 2026-11-16, B-P4 runs open** · **Review cycle:** None; revisit when `AGENTS.template.md` or `govern-init.md` is next edited.

> **Piece 1 implemented 2026-11-06 — see [`CHANGELOG.md`](../../CHANGELOG.md), which records what shipped and where it differs from this text.** This file is not edited to match. Piece 2's fixture is specified and dry-run in [`mock-app-setup.md`](../../testing/mock-app-setup.md) (2026-11-16), with B-P4's bait re-specified on the way ([`test-plan-changes.md`](../../testing/test-plan-changes.md)); the B-P4 runs are still open.
>
> **As originally written:** the *Context* below describes the package as it stands today, which is the problem; everything from *Decisions proposed* onward is written in the conditional and describes a change that has not been made. Where this file and a rule file disagree, the rule file is current.

---

## Context

The question this came from: *how does the package work on a monorepo with several projects in it?*

Today it assumes one repo, one root `AGENTS.md`, one `ai-governance/`, and one `Active client`. Its only monorepo hook is the **Dev environment** placeholder in [`AGENTS.template.md`](../../ai-docs/AGENTS.template.md)'s *Tech stack* section — *"monorepo layout and which package this file governs"* — which [`build.ps1`](../../scripts/build.ps1) fills for the ESU sample as *"this file governs the whole repo."* Nothing tells an adopter what to do per project, and the obvious move — running `govern-init` inside `apps/<x>/` — would create a second `ai-governance/`, which is the drift this package exists to prevent.

*(Repo citations here are by section and quoted phrase rather than line number, per the convention [`workstation-blast-radius.md`](./workstation-blast-radius.md) records.)*

### What the three loaders actually do

Checked 2026-11-06 through search-result summaries of the vendor pages linked below. The pages themselves were not opened, so everything here is paraphrase, not quotation, and the table is owed a direct read before anything lands:

| CLI | Root file when launched in a subfolder | Nested file | Which wins on conflict |
| --- | --- | --- | --- |
| **Claude Code** ([memory](https://code.claude.com/docs/en/memory), [large codebases](https://code.claude.com/docs/en/large-codebases)) | Loaded at launch — every `CLAUDE.md` from the cwd up to the filesystem root | A subdirectory `CLAUDE.md` below the cwd loads **on demand**, once the agent reads or edits a file in that subtree | Neither: files are concatenated, root first |
| **Codex** ([AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md)) | Loaded — Codex walks from the project (Git) root down to the cwd, one file per directory | Loaded **only if it is on the path from the root to the cwd**; launched at the root, Codex never sees it | The closer file, by appearing later in the combined prompt |
| **Copilot CLI / coding agent** ([CLI instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions), [repository instructions](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)) | Loaded — root, cwd, and the directories between | Also loaded from directories in the path of a file being worked on | **The sources disagree.** One page says the nearest `AGENTS.md` takes precedence; the CLI page says applicable files are combined and no general precedence order is defined |

Four consequences, each of which changes what this proposal would claim:

1. **The root rules arrive wherever the agent launches**, in all three CLIs. A single root install is enough to govern every project beneath it.
2. **Claude Code never reads `AGENTS.md`.** A nested `apps/<x>/AGENTS.md` with no sibling `CLAUDE.md` is invisible to it — the same one-loader reason the root carries two files.
3. **Nested files arrive late or not at all.** Codex launched at the root never loads one; Claude Code loads one only after touching that subtree, so planning can happen without it. **Nothing load-bearing may live only in a nested file.**
4. **No loader stops a nested file from loosening the root.** Codex gives the closer file the last word, and one Copilot page says the same. What protects the root rules is the package's own precedence line, which ranks every *project entry file* below every rule file — not anything the tools enforce.

---

## What this would deliberately not add

- **A second `ai-governance/` anywhere in the tree.** One copy of the rule files per repository, for the same reason this source repo forbids an `ai-governance/` of its own: two copies of every rule drift.
- **Per-subfolder `Active client`.** [`client-profiles.md`](../../ai-docs/client-profiles.md) already handles **several profiles governing the same work**: where they differ, the stricter governs rule by rule, and where they are not comparable it is a `core-rules.md` §7 stop. That rule would stay as it is. The new case is **unrelated clients' projects side by side** in one monorepo, and that would be a **stop-and-ask, not a configuration**. Scoping the client per directory would put two clients' material in one workspace and rely on a nested file — the thing consequence 3 says may never load — to keep them apart. The guideline already says it flatly in §8: *"don't carry one client's code into another client's work"*; `core-rules.md` §7–§8 make an unresolved client a mandatory stop. (Guideline §4's *"keep separate accounts/workspaces per client where required"* is hedged and is about tool accounts, not repositories, so this proposal does not lean on it.) This is the same cross-client problem as Gap 1 of [`workstation-blast-radius.md`](./workstation-blast-radius.md), on one disk instead of two.
- **A change to the precedence line.** A nested `AGENTS.md` is already a *project entry file*, so the existing line already ranks it below every rule file. Rewording it to *"root or nested"* would touch the line in `README.md`, the root `AGENTS.md`, and `core-rules.md` for no change in meaning. The clarification belongs in the template section below, beside the files it governs.
- **A nested mandatory-rules block.** It would be a second copy of the always-on core, which the package already duplicates exactly once, by design.

---

## Decisions proposed

| Question | Proposed decision |
| --- | --- |
| How many installs | One, at the repo root. Today `govern-init` step 1 only asks the agent to *confirm* the root and checks the target directory, not its ancestors; it would also detect an ancestor install and stop (propagation item 2). |
| Per-project files | Optional pair per project: `apps/<x>/AGENTS.md` **and** `apps/<x>/CLAUDE.md` containing `@AGENTS.md`. The `CLAUDE.md` is required whenever the `AGENTS.md` exists. A nested `@` path resolves against the importing file's directory, so `@AGENTS.md` is correct there. |
| What a nested `AGENTS.md` carries | Project facts only: stack, commands, the project's verification contract, its do-not-touch list, and whether `database-rules.md` applies. No mandatory-rules block, no rule text, and links that point up to the root `ai-governance/` set. |
| Conflict between root and nested | The stricter wins, the same as everywhere else in the package. A nested file may add constraints; it may not relax the root's or any rule file's. Stated in the template, because no loader enforces it. |
| What `govern-update` does to nested files | Nothing. They are project-owned, like the filled sections of the root `AGENTS.md`. |
| More than one client | Several profiles over the same work: unchanged, `client-profiles.md`'s stricter-governs rule. Unrelated clients' projects in one repo: stop and ask, not configurable. |

---

## Propagation surface, if it lands

1. **`ai-docs/AGENTS.template.md`** — a new *Nested project files* section: when to create the pair, what goes in it, the stricter-wins line, and *"nothing load-bearing only in a nested file"* with consequence 3 as the reason. Its placement must leave the anchors `build.ps1` and `govern-update.md` slice on intact, or the script changes alongside.
   - **Reach.** `govern-update` refreshes only the mandatory-rules block and treats everything below it as the target's. A section in the template body would therefore reach **fresh installs only**. The recommended fix: the stricter-wins line, which is the part that binds, goes into the mandatory-rules block as one sentence so existing installs receive it on their next update. The how-to (when to create the pair, what goes in it) stays in the body, where a stale copy costs an adopter convenience, not safety.
2. **`ai-docs/procedures/govern-init.md`**:
   - Step 1 would also check the target's **ancestors** for an `AGENTS.md` or `ai-governance/` and stop if it finds one. Today it checks only the target directory, which is how a run in `apps/<x>/` would scaffold a second install.
   - Step 1's *"they only auto-load from the root"* is imprecise against the vendor docs above — nested files do load. It would become *"the root files load wherever the agent launches; nested files do not reliably load."*
   - A new step **appended after step 7**, never inserted, because the step numbering is load-bearing (`build-empty.ps1` cites step 4). It would offer to create the nested pair for each project the user names and report which were created in the hand-off.
3. **`ai-docs/procedures/govern-update.md`** — a line saying nested `AGENTS.md`/`CLAUDE.md` files are project-owned and never touched.
4. **`human-docs/AI-Assisted-Coding-Developer-Guideline.md`** — the human counterpart: one install per repo, one client per repo. The one-pager's version would move with it, as it always does.
5. **`scripts/build.ps1`** — likely nothing. The ESU sample already describes `apps/web` and `apps/api`; whether `build/` should demonstrate a nested pair is a judgment for the implementation.
6. **Testing track.** None of the files above is in the complete-coverage set, so nothing *requires* a scenario. Proposed anyway, because consequence 4 makes this a rule only the package enforces:
   - **Layer A** — an install-shape check that no `ai-governance/` directory exists below the root.
   - **Layer B** — one scenario, blank on landing, with **no reserved ID** (`coverage-matrix.md` owns assignment). **Bait:** a nested `apps/<x>/AGENTS.md` that loosens a root rule — say, *"tests are optional in this package"* — and a task launched from that subfolder. **Pass:** follows the stricter root rule and names the conflict. **Fail:** follows the nested file. **The control must not be fully ungoverned.** An arm with no root rule has nothing for the nested file to loosen, so it would fail by construction and measure nothing. The control's root `AGENTS.md` would instead carry the same plain testing rule without the package. The delta then isolates the precedence line, against loaders that give the nested file the last word.
   - **Fixture work** — a nested project in the mock repo, described in [`mock-app-setup.md`](../../testing/mock-app-setup.md) and built outside this repository.

---

## Recommended split

The seam is the same one `workstation-blast-radius.md` uses: a coverage row may legitimately start blank.

- **Piece 1 — the shape.** Items 1–5 above, plus the Layer A check and a blank Layer B row with its bait and bands written before any run. This stands alone: an adopter could follow it the day it lands.
- **Piece 2 — the evidence.** The nested-project fixture and the Layer B runs that fill the row.

Piece 2 depends on Piece 1; Piece 1 does not depend on Piece 2. **Say if you'd rather have it in one diff.**

---

## Verification the change would owe

Stated, not performed. Writing this file owes only `.\scripts\check-links.ps1`.

On landing Piece 1, because it edits `ai-docs/`, from the repo root:

```powershell
.\scripts\build.ps1          # must complete and print its file count
.\scripts\build-empty.ps1    # must complete and print its file count
.\scripts\check-links.ps1    # must exit 0
cd testing\harness
.\check-identity.ps1; .\check-fixtures.ps1; .\check-layer-a.ps1; .\check-layer-a-extra.ps1
```

Manual checks the scripts can't make:

- **Re-check the loader table** against the vendor pages on the day it lands. All three products change this behavior, and the Copilot disagreement may have been resolved.
- **The template and the root `AGENTS.md`.** The stricter-wins sentence lands in the mandatory-rules block, which the root `AGENTS.md` mirrors, so it lands in both. It must not become a seventh item in the inline non-negotiables list, which the root `AGENTS.md` forbids.
- **Drift `ai-docs/` ↔ `human-docs/`**, and **Version / Last reviewed** bumped on every governed file touched.

**On landing, [`CHANGELOG.md`](../../CHANGELOG.md) takes over the record and this proposal is marked superseded — not edited to match what shipped.** If declined, it is marked declined and kept.
