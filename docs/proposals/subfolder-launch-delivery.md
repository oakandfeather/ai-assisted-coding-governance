# Proposal — subfolder launches: aligning the monorepo setup with Claude Code's large-codebases guide

**Version:** 1.0 · **Last reviewed:** 2026-11-17 · **Status:** **Proposed, not implemented** · **Review cycle:** None; revisit when `govern-init.md` step 8 or `CLAUDE.template.md` is next edited.

> **Proposed, not implemented.** The *Context* below describes the package as it stands today, which is the problem; everything from *Decisions proposed* onward is written in the conditional and describes a change that has not been made. Where this file and a rule file disagree, the rule file is current. The parent proposal is [`monorepo-support.md`](./monorepo-support.md), implemented in full: its shape shipped 2026-11-06 and B-P4 ran 2026-11-17. This one is a follow-up, not an amendment to it.

---

## Context

The question this came from: *how does our monorepo setup compare with Claude Code's own instructions in [Set up Claude Code in a monorepo or large codebase](https://code.claude.com/docs/en/large-codebases)?*

**Provenance, stated before any claim.** Both vendor pages — that guide and [Memory and project instructions](https://code.claude.com/docs/en/memory) — were read on 2026-11-17 through a fetch subagent that returned quotes and a summary, not by a direct read. The memory page was truncated at roughly 40,000 of 55,000 characters. Quoted lines below are as the subagent returned them; **a direct read of both pages is owed before anything lands**, and anything unquoted is unverified. *(Repo citations are by section and quoted phrase rather than line number, per the convention [`workstation-blast-radius.md`](./workstation-blast-radius.md) records.)*

### Where the package already agrees with the guide

- **Two layers.** The guide recommends a root `CLAUDE.md` for what applies everywhere and one per package for that package's stack. The package installs once at the root and offers a nested `AGENTS.md` / `CLAUDE.md` pair per project (`govern-init.md` step 8).
- **Load order.** The memory page: *"Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from your current working directory and every directory above it,"* and loads a subdirectory's file *"once Claude reads, writes, or edits another file in that subdirectory."* `CLAUDE.template.md`'s banner and `README.md`'s file-set table say the same.
- **`AGENTS.md` beside a `CLAUDE.md`.** The memory page now documents native `AGENTS.md` reading, but *"only when you have no `CLAUDE.md` in your working directory or above it."* Step 8's reason for the one-line nested `CLAUDE.md` still holds. (`monorepo-support.md`'s *"Claude Code never reads `AGENTS.md`"* is stale on this point; that file is not edited.)

### Where the package differs on purpose

- **Nested files carry facts, not rules.** The guide's sample package file holds a rule (*"Never edit a migration after it has merged"*). The package forbids that, because a nested file loads late or not at all. The stricter shape is right for a governance package and is not in question here.
- **One client per repository.** The guide has no counterpart to the guideline's stop-and-ask for unrelated clients' projects in one monorepo.

### The gap — the guide recommends the launch the package is weakest in

The guide's launch table recommends starting in a subdirectory *"when work is scoped to one package or subsystem."* B-P4 ([`run-log.md`](../../testing/run-log.md), 2026-11-17, CC 2.1.322) measured two delivery costs of exactly that launch:

1. **The root imports are skipped.** All four of the root `CLAUDE.md`'s imports resolve outside the launch folder and did not arrive until approval was set. The memory page documents the mechanism: *"An import in a project-level memory file is external when its path resolves outside your working directory,"* and *"The first time Claude Code encounters external imports in a project, it shows an approval dialog listing the files."* The large-codebases guide never links this caveat from its launch table.
2. **The linked rule files can't be opened.** The governed arm's `Read` of `coding-rules.md` and the ESU profile was denied under `acceptEdits`, because the paths sit outside the launch folder. This is the guide's *"that subtree only, until you grant more"*; nothing in the package names it.

Three things follow, and the first two were not known when step 8's approval offer was written:

- **The approval prompt is documented; only the keys are internal.** `docs/design/package-shape.md` (*Multi-tool entry points*) says an interactive prompt *"is expected … that is unmeasured."* It is now documented, though still unmeasured here.
- **A decline is permanent.** The memory page: *"If you decline, the imports stay disabled and the dialog doesn't appear again."* A developer who clicks decline once is ungoverned in every later subfolder launch of that clone, with no further warning. Nothing in step 8, `CLAUDE.template.md`, `README.md`, or the guideline's monorepo paragraph says so.
- **A headless session still has no documented path.** It can't show the dialog; the `~/.claude.json` keys step 8 sets remain the only route B-P4 found.

### Guide features with an unmeasured interaction

The guide's other levers — deny rules for generated code, sparse worktrees, language-server plugins, per-package skills, a `SessionStart` hook — are adopter settings with no bearing on rule delivery. Four do bear on it, and the vendor pages don't settle any of them:

- **`claudeMdExcludes`** skips files *"by path or glob pattern,"* and *"Arrays merge across layers."* Whether a pattern can also suppress an `@` import is not stated. A broad user-scope pattern such as `**/packages/*/CLAUDE.md` would at least drop every nested pair.
- **Root `.claude/rules/`.** *"Rules without [`paths` frontmatter] are loaded at launch."* Whether an *ancestor's* `.claude/rules/` reaches a subfolder launch is not stated. If it does, it is a delivery path that needs no approval.
- **`permissions.additionalDirectories`** is the guide's grant for reading outside the launch folder. It might fix cost 2; the guide also says it never loads `CLAUDE.md` from the added directory, so it can't fix cost 1.
- **Settings don't travel.** The guide: project `.claude/settings.json` is not inherited from parent directories, and a root `.claude/settings.local.json` loads in every subfolder session *"except in the cases where Claude Code doesn't use the repository root, such as on Windows"* — the maintainer's platform.

Unverified and worth the direct read: the memory page reportedly names a `claude-md-and-agents-md` value that loads both files, and says an `AGENTS.md`'s external imports load *"only if you already approved external imports for this project, with no prompt."* Either could change step 8's nested `CLAUDE.md` or the behavior of an `AGENTS.md`-only install.

---

## What this would deliberately not add

- **Rule text in nested files**, as the guide's sample does. The facts-only shape stands; the reason is unchanged.
- **Per-package `.claude/settings.json`, deny rules, worktree, LSP, or skills configuration as package content.** These are the adopter's tool settings, they are Claude Code-only, and the guide says settings aren't inherited, so a shipped root file wouldn't reach a subfolder launch anyway.
- **Rule text in the root `CLAUDE.md`** to survive the skipped imports. B-P4 showed inline body text does arrive, but `CLAUDE.template.md` stays free of rule text; that trade was already declined.
- **Endorsing the guide's subfolder launch unqualified.** The package's advice stays *start at the root, or approve the imports first.*
- **Replacing the nested pair or the approval keys with `.claude/rules/` now.** Unmeasured; Piece 3 decides it if Piece 2 earns it.

---

## Decisions proposed

| Question | Proposed decision |
| --- | --- |
| What to say about the approval prompt | Cite the memory page: the prompt is documented, the keys are not. Add the permanent-decline warning everywhere the approval is mentioned. |
| What to say about the guide | One line in the human guideline and in `package-shape.md`: the guide recommends subfolder launches for scoped work, and under this package that launch needs the imports approved first. |
| The second delivery cost | Name it in `package-shape.md` as measured. Leave the fix to Piece 2; no mechanism ships unmeasured. |
| Where Claude Code-only text goes | **A decision for the reviewer.** Root `AGENTS.md` says *"A change that only works under Claude Code belongs in the launcher, not the procedure,"* yet step 8 already carries Claude Code internals. The recommendation is to add the decline warning to step 8's existing approval bullet, because that is where the offer is made, and to record the tension rather than resolve it here. The alternative is to move the whole approval bullet into the `govern-init` launcher. |
| Coverage | **No new coverage row.** None of the files touched is in the complete-coverage set, and these are tool facts, not rules. Piece 2's probes are dated entries in `run-log.md`, like B-P4's scratch-repo sentinels. |

---

## Recommended split — three pieces at two dependency boundaries

- **Piece 1 — the text.** Documentation edits only, standing on the two measured costs and the documented prompt. An adopter is better warned the day it lands.
- **Piece 2 — the measurements.** Scratch-repo probes for the open questions. Nothing in Piece 2 changes a file outside `testing/`.
- **Piece 3 — the mechanism.** Only if Piece 2 finds a supported delivery path: replace or supplement the `~/.claude.json` keys in step 8. Its shape depends on what Piece 2 finds, so it is not drafted here.

Piece 1 depends on neither of the others. Piece 3 depends on Piece 2. **Landing Piece 1 alone is the recommendation; say if you'd rather fold Piece 2 in.**

---

## Piece 1 — propagation surface

1. **`docs/design/package-shape.md`**, *Multi-tool entry points*, the subfolder-launch bullet. Replace *"expected to prompt … unmeasured"* with the memory page's documented prompt, still unmeasured here. Add the permanent decline, the second delivery cost (the denied `Read`), and that the official guide recommends the launch this bullet describes. Present tense, no status line.
2. **`ai-docs/procedures/govern-init.md`** step 8, the approval bullet. Add one sub-bullet: *the prompt appears once per project; a decline disables the imports for good, and setting the keys is the only way back.* Subject to the placement decision above.
3. **`ai-docs/CLAUDE.template.md`** banner and **`README.md`**'s file-set row for it. Add a short clause after *"until external imports are approved for the project"*: Claude Code asks once, and a decline sticks. Change both together; they carry the same sentence.
4. **`human-docs/AI-Assisted-Coding-Developer-Guideline.md`**, the *"In a monorepo, install once, at the root"* paragraph. Add the decline warning and the guide-conflict line. **The one-pager's version moves with the guideline's**, whether or not its text changes.
5. **Root `AGENTS.md`**, *Multi-tool entry points*. Its fidelity-caveat bullet already says a subfolder session gets less. Whether it needs the decline clause is a judgment for the implementation. If it does, the always-on core is not touched.

## Piece 2 — the questions to measure

Each is a scratch-repo probe in B-P4's sentinel style. Record each result in `run-log.md` with the CC version.

1. Does an interactive subfolder launch show the dialog, and does it list the root files?
2. After a decline, does the dialog really never return, and do the keys restore delivery?
3. Can a `claudeMdExcludes` pattern suppress an `@` import, or only discovered files?
4. Does an ancestor's `.claude/rules/` rule without `paths:` reach a subfolder launch unapproved?
5. Does `permissions.additionalDirectories`, or a `//`-absolute `Read` allow, fix the denied rule-file read, and from which settings file, given that settings aren't inherited?
6. On Windows, does a root `.claude/settings.local.json` load in a subfolder session?
7. Does the `claude-md-and-agents-md` value exist, and would it make the nested one-line `CLAUDE.md` unnecessary?

---

## Verification the change would owe

Stated, not performed. Writing this file owes only `.\scripts\check-links.ps1`.

On landing Piece 1, which edits `ai-docs/`, run these from the repo root:

```powershell
.\scripts\build.ps1          # must complete and print its file count
.\scripts\build-empty.ps1    # must complete and print its file count
.\scripts\check-links.ps1    # must exit 0
cd testing\harness
.\check-identity.ps1; .\check-fixtures.ps1; .\check-layer-a.ps1; .\check-layer-a-extra.ps1
```

`build.ps1` slices `CLAUDE.template.md` and `govern-init.md` on anchors. A script that throws is a stop signal: fix the script alongside the edit.

Manual checks the scripts can't make:

- **Read both vendor pages directly** on the day it lands. Re-quote every line this proposal relies on, and drop or narrow any claim the read doesn't support.
- **Drift `ai-docs/` ↔ `human-docs/`.** The decline warning should be one fact stated once for each reader, not copied text.
- **Version / Last reviewed** bumped on every governed file touched; **the one-pager's version equals the guideline's.**

**On landing, [`CHANGELOG.md`](../../CHANGELOG.md) takes over the record and this proposal is marked superseded — not edited to match what shipped.** If declined, it is marked declined and kept.
