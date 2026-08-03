# govern-update — refresh an installed governance package

Refreshes an installed governance package in place. This procedure **copies and merges** the rules; it does not contain them. Like `govern-init.md`, it never reconstructs rule text from memory.

**How this is run.** Follow it directly, start to finish. Either run `/govern-update` in Claude Code, or hand any other agent — Codex, Cursor, Windsurf, the Copilot agent — the path to this file and tell it to read the file and follow it exactly. Nothing here needs a tool or a tool-specific feature: every step is reading files, writing files, comparing them, and asking the user before each tier lands.

**The whole difficulty of this procedure is that `govern-init` forks part of the package at install time.** The portable rule files are upstream's and can be replaced. But the target's `AGENTS.md` carries ~27 filled placeholders describing *that* project, `ai-governance/client-profiles.md` carries *that* engagement's active-client pointer, and `ai-governance/client-profiles/` carries client-authored profiles. An update that overwrites those is a regression, not an update — it turns a configured repo into one that reads as unconfigured. Know which tier every file is in before you write anything.

## Source package

**The source package is the repository you are reading this file from** — the upstream governance repo, whose `ai-docs/` directory holds the current rule files and templates. The **target** is a different repo: the client project with an existing `ai-governance/` directory in it. Keep the two straight; every step below names which side it means.

**Do not reconstruct the rule files from memory** — a paraphrased safety rule is not the safety rule. If a source file named below cannot be read, stop and say so rather than writing an approximation of it.

**If the source is a pre-existing local clone rather than a freshly cloned copy, check it is not itself stale.** If it's a git repo, `git fetch` and report whether it is behind `origin`; offer to pull before continuing. Updating a client repo *from* a stale local clone quietly propagates the staleness — the exact failure this procedure exists to correct.

## Procedure

### 1. Confirm the target, and refuse the shapes you cannot safely update

- Confirm you are at the target repo's **root**.
- Expect `AGENTS.md` at the root and an `ai-governance/` directory beneath it. **If there is no governance installed, stop and point the user at `govern-init.md`** — this procedure updates, it does not scaffold.
- **Detect the pre-restructure layout and refuse it.** If you find rule files at the repo root instead of in `ai-governance/`, or a file named `ai-coding-rules.md`, this repo was scaffolded by an old installer. Do **not** attempt to update it in place: `ai-coding-rules.md` was split and reorganized into `core-rules.md`, `coding-rules.md`, and `writing-rules.md`, and no mechanical move reproduces that split. Report what you found and hand it back — the honest options are a fresh `govern-init` into the current shape, or a human-guided migration. Guessing here would silently drop rules.
- **Require a clean working tree for the files you are about to touch.** If any of them have uncommitted changes, stop and show the user. An update must not be entangled with work in progress — git is the only undo this procedure offers.

### 2. Learn the current anchors from `build.ps1` — do not hardcode them

`scripts/build.ps1` in the source already performs every transformation this procedure needs: it slices the template banners off the three entry files (`Slice-From`), strips `AGENTS.md`'s closing footnote, replaces placeholder tokens, drops the `## Sample profile` section, and rewrites the active-profiles paragraph (`Replace-Paragraph`). The repo's verification contract **already requires** `build.ps1` to be updated whenever a template's structure changes.

**Read the anchor strings out of `build.ps1` and use those.** Do not copy an anchor list into this file: `build.ps1`, `build-empty.ps1`, and this procedure would then be three copies of one fact, which is the drift hazard this whole package exists to prevent.

Adopt `build.ps1`'s failure posture too — **if an anchor is not found in the file you are operating on, stop and report it.** A missing anchor means the shape changed underneath you; a best-effort merge at that point produces a mangled governance file that still looks plausible.

**One limit on that:** `build.ps1` *assembles from source* — it never merges into an existing install, so its anchors are **source-side only**. Locating the corresponding region in an already-installed target is this procedure's own problem, and a source anchor can be legitimately absent there. Steps 5 and 6 each say which anchors to use on the target side; use those, and do not assume a source anchor transfers.

### 3. Classify every file into a tier

| Tier | Files | Treatment |
| --- | --- | --- |
| **A — verbatim** | `ai-governance/core-rules.md`, `coding-rules.md`, `writing-rules.md`, `coding-patterns.md`, `agent-workflow.md` | Replace wholesale from source. |
| **B — banner-stripped** | `CLAUDE.md`, `.github/copilot-instructions.md` | Re-derive from the template (slice the banner per step 2), then replace — but diff first, and gate it separately. See below. |
| **C — merge** | `AGENTS.md` | Replace **only** the mandatory-rules block. See step 5. |
| **D — merge** | `ai-governance/client-profiles.md` | Preserve the active-client paragraph. See step 6. |
| **E — never touch** | `ai-governance/client-profiles/*.md` | Leave alone entirely. Report as untouched. |

**Tier E is absolute.** These files are client-authored and often summarize a client's own AI policy. You do not need their contents to do this job, so do not read them — list them to report them and nothing more.

**Write every file with the line endings it already has.** Read the target file, keep its convention (CRLF or LF), and write the replacement back the same way. This sounds cosmetic and is not: normalizing line endings rewrites *every line of every file you touch*, so a change of a few lines lands as a diff of several hundred. Step 7 tells the user to review that diff because it is the audit trail for when the rules changed — a whole-file diff destroys the thing this procedure asks them to read. For the same reason, when you compare a target file against the incoming one to decide whether it changed, **compare after normalizing line endings**, or a file that is byte-for-byte current will look modified and every run will ask you to approve a diff with nothing in it.

**Tier B carries no placeholders, but that is not what makes a file safe to replace.** The risk to `CLAUDE.md` is **appended local content**: it is the natural place for a team to add Claude-specific project notes beneath the `@AGENTS.md` import, and `govern-init` step 1 already refuses to overwrite a pre-existing `CLAUDE.md` for exactly that reason. So give tier B **its own diff and its own gate** rather than folding it into the tier-A batch. If the target holds anything the incoming template does not, treat it as local customization: surface it and ask. Silently dropping a team's notes inside a batch nobody reads is the worst of both.

**In tiers A and D, preserve a locally-filled `Owner:`.** The source repo ships those headers with `*(your company)*` unfilled; an adopting organization may have filled theirs in. Compare, and if the target's value differs from the source's, carry the target's value across into the replacement.

**Handle files the source has added or removed:**

- **Added upstream** (e.g. a new rules module): copy it into `ai-governance/`, and note that the link to it arrives automatically with the tier-C block replacement in step 5 — that block is where the rules files are linked. Verify afterwards that the link is present and resolves.
- **Removed upstream:** report it and ask. **Never auto-delete** a governance file from a client's repo; a rule that vanishes silently is worse than one that lingers.

### 4. Present the plan, then apply tier by tier

Show the user what will change before changing it: per file, whether it is identical, updated, added, or removed, and for updated files the `Version:` / `Last reviewed:` delta from their headers. Those header fields are the readable narrative of what moved; content comparison is what actually detects it, so **trust the content diff, not the version number** — an upstream edit that forgot to bump its version still needs to land.

Then apply with **one approval per tier, not per file.** Tier A goes as a single batch — five full rule-file diffs are unreadable, and a gate nobody reads is not a safety measure. Tier B gets its own gate (it may hold appended local content), and tiers C and D are merges, so each gets its own gate and its own diff.

Note that without an install manifest there is no baseline, so "the target differs from the source" is genuinely ambiguous: it may be an upstream change or a deliberate local edit. Treat every difference as needing confirmation, and say plainly that you cannot tell the two apart.

### 5. Tier C — merge `AGENTS.md`

The file splits at the first `---` after the mandatory-rules block:

```
**Owner:** … · **Version:** … · **Last reviewed:** … · **Active client:** …   <- target's
(lead-in sentence)                                                            <- target's
## ⚠️ Mandatory rules
   (four paragraphs of links, the always-on core, precedence)                  <- the package's
---                                                                            <- the seam
## Project overview  …through…  ## Escalation                                   <- target's
```

**Replace only the mandatory-rules block** — from the `## ⚠️ Mandatory rules` heading up to (not including) the following `---`. Everything else is the target's: its header line, its lead-in sentence (projects customize it), and every section after the seam. Take the replacement from the source template with its banner and closing footnote sliced off per step 2.

**The trap: one filled placeholder lives inside the block you are replacing.** `**Active client:** *(fill in)*` sits in the mandatory-rules block, and it is a *second, separate* placeholder from the `Active client` field in the header line — `build.ps1` fills the two independently. Replace the block naively and you revert a configured repo's active client to `*(fill in)*`, breaking the one line that tells every agent which client profile binds it. **Extract the target's filled value first, and substitute it into the replacement block.**

Then, because you materially edited a governed document: set `Last reviewed` in the header to today's date (absolute, e.g. `2026-07-25`) and bump `Version` a minor step. Leave `Owner` and `Active client` in the header exactly as they were.

**One carve-out, on the same logic as the assertion below: if `Last reviewed` is still the unfilled `*(date)*`, leave it.** A repo that never completed `govern-init`'s interview has never been reviewed, and stamping today's date there asserts a review that did not happen — the same false assertion the `Active client` rule refuses to make. Bump `Version` as normal, since it records that the rules moved rather than that anyone read them, and **say in the hand-off that the date is still unfilled**.

**Assert before writing — but assert the right thing.** The invariant is that the merge must not *introduce* a placeholder where the target had a real value. So compare against what the target had:

- Target's in-block `Active client` was **filled**, and the merged block still contains a `*(…)*` token → the substitution failed. **Stop.** Never write a file that reverts a configured repo to unconfigured.
- Target's in-block `Active client` was **already unfilled** (`*(fill in)*`) → that is a legitimately unconfigured repo, and `govern-init` treats an unfilled placeholder as the correct safe state: it signals "ask before assuming" rather than asserting a client falsely. Carry the placeholder forward, update the rules around it, and **say so in the hand-off** — the repo still needs configuring, and `core-rules.md` §8's sensitive-by-default still applies. Do not "helpfully" fill it in.

A blanket "no placeholders may survive" check is wrong here, and gets this backwards: it would refuse to deliver current safety rules to precisely the repos that are least configured.

### 6. Tier D — merge `ai-governance/client-profiles.md`

Under `## Active client profiles` there are two paragraphs, and they have different owners:

- **The first paragraph is the target's** — the engagement's client list, or the honest "no profile yet" empty state. **Preserve it verbatim.** This is the pointer that makes `core-rules.md` §8's client-override chain resolve; overwrite it and either the client's rules stop being findable, or a repo with no profile starts claiming one.
- **The paragraph beginning "Add each client as…" is the package's** generic guidance. Take it from the source.

**Locate the target's region by its two bounding anchors — not by `build.ps1`'s.** `build.ps1` finds this paragraph in the *source* by the literal `*(none yet)*`, and that string is correctly **absent** from any configured target, where the region instead begins `- **<Client>**:`. Search a configured repo for `*(none yet)*` and you will halt a perfectly valid update. Instead take everything **between the `## Active client profiles` heading and the paragraph beginning "Add each client as"**. Both anchors are stable, and the span survives a multi-client list with blank lines between entries — which "the first paragraph, up to the next blank line" would silently truncate, dropping clients out of the override chain.

So: start from the source file, strip the `## Sample profile` section outright (it points at the fictional sample, which is never copied into a real repo), then splice the target's bounded region back in under `## Active client profiles`.

### 7. Hand off

Report, per tier:

- **Updated** — which files, with their `Version:` deltas.
- **Merged** — for `AGENTS.md` and `client-profiles.md`: what was replaced, and explicitly **what was preserved** (the active-client value, the project sections, the client list). State that the placeholder check passed.
- **Untouched** — name `ai-governance/client-profiles/` and its files explicitly. Reviewers need to see that client content was not in scope.
- **Still unconfigured** — if the target's `Active client` or its active-profiles paragraph was unfilled, say so plainly. The rules are now current, but the repo has no client profile, so `core-rules.md` §8's sensitive-by-default governs until someone authors one. This is open work, not a clean result.
- **Added / removed upstream** — including anything you refused to delete and why.
- **Anything that stopped the run** — a missing anchor, a legacy layout, a dirty working tree, a stale source clone, or a stale launcher that halted before this file was reached. Say what you did not do.

Then tell the user to review the diff and commit it: this is governance their reviewers should see in a PR, and the diff is the audit trail for when the rules changed.
