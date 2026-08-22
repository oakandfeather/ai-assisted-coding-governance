---
name: govern-update
description: Update an already-installed AI-assisted coding governance package to the latest upstream version — refreshes the portable rule files and the package-owned sections of the three entry files (AGENTS.md, CLAUDE.md, GEMINI.md), while preserving the target repo's filled-in placeholders, its active-client pointer, and its client profiles. Use when asked to "update / refresh / pull the latest governance rules", when an installed `ai-governance/` directory is behind the source package, or after the governance source repo has changed. For a repo with no governance installed yet, use `govern-init` instead.
---

# govern-update

**This file is a launcher, not the procedure.** The procedure lives in the governance repo at `ai-docs/procedures/govern-update.md`, and is read fresh from there on every run — so it is current as of the source repo's last `git pull`, no matter how old this launcher is.

## 1. Locate the source package

Find the upstream package in this order:

1. A path the user gives you.
2. `$AI_GOVERNANCE_PATH` if set.
3. Clone it: `git clone --depth 1 https://github.com/oakandfeather/ai-assisted-coding-governance` into a temp directory. Use a temp directory, **not** a remote added to the target repo — the target's git state is the client's, and this must not touch it.
4. Ask. **Do not reconstruct the rule files from memory** — a paraphrased safety rule is not the safety rule. If you cannot find the source package, stop and say so.

## 2. Read the procedure and follow it

Read `ai-docs/procedures/govern-update.md` from the resolved source, and **follow it exactly**. It is the whole procedure — the staleness check on the source itself, the layouts to refuse, the anchors, the A–E tiers, the two merges, and the hand-off. Nothing in this launcher supersedes it.

**If that file is not there, you are stale — stop.** Either this launcher predates the source it is pointed at, or the source predates the split that created `ai-docs/procedures/`. Show the user what you found, and offer to re-deploy both skills (`govern-init` and `govern-update`) from `ai-docs/skills/` into `~/.claude/skills/` before proceeding. Do not fall back to updating from memory.

That check matters more here than anywhere: **a stale updater updates backwards** — it will happily "restore" an obsolete file layout over a correct one. `~/.claude/skills/` is a one-shot copy that `git pull` does not touch, and it has already bitten this package: a deployed `govern-init` went unnoticed long enough to start scaffolding a pre-restructure shape (rule files at the repo root, a since-split `ai-coding-rules.md`) out of perfectly current rules. Keeping the procedure in the source repo is what turns that failure from silent into a hard stop — but only if you honor the stop.
