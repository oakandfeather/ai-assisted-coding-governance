---
name: govern-init
description: Scaffold the AI-assisted coding governance package into a target project repository — copies the two entry files (AGENTS.md at the root and a thin CLAUDE.md) plus the companion rule files into an ai-governance/ directory, then interviews the user to fill in the placeholders and to author the active client's profile. Covers Claude Code, OpenAI Codex, and every other AGENTS.md-reading coding CLI in one pass. Use when setting up a new client engagement repo, when asked to "add the coding rules / governance / AGENTS.md / CLAUDE.md to this project", when asked to set up or add a client profile, or when a repo has an AGENTS.md/CLAUDE.md whose *(placeholders)* are still unfilled.
---

# govern-init

**This file is a launcher, not the procedure.** The procedure lives in the governance repo at `ai-docs/procedures/govern-init.md`, and is read fresh from there on every run — so it is current as of the source repo's last `git pull`, no matter how old this launcher is.

## 1. Locate the source package

The package lives in the governance repo (`ai-docs/`). Find it in this order:

1. A path the user gives you.
2. `$AI_GOVERNANCE_PATH` if set.
3. Ask. **Do not reconstruct the rule files from memory** — a paraphrased safety rule is not the safety rule. If you cannot find the source package, stop and say so.

## 2. Locate the client overlay, if there is one

Some teams keep client masters in a **private overlay repo** — `clients/<client>/profile.md` and `clients/<client>/policy.md`, and no rule files. Find it in this order:

1. A path the user gives you.
2. `$AI_GOVERNANCE_CLIENTS_PATH` if set.
3. Prompt for it, and offer to persist it — `[Environment]::SetEnvironmentVariable('AI_GOVERNANCE_CLIENTS_PATH', <path>, 'User')` on Windows, a line in the shell profile on macOS/Linux, the same two forms `README.md` documents for `$AI_GOVERNANCE_PATH`.

**A missing overlay is not a stop.** It is optional, and most engagements have none. Say there is no overlay and carry on — the procedure interviews for the client's rules instead. Do not carry step 1's "stop and say so" posture over to this one; that posture exists because the *rule files* cannot be reconstructed, and nothing here is a rule file.

## 3. Read the procedure and follow it

Read `ai-docs/procedures/govern-init.md` from the resolved source, and **follow it exactly**. It is the whole procedure — the file set, the banner stripping, the placeholder interview, the client-profile authoring, and the hand-off. Nothing in this launcher supersedes it.

**If that file is not there, you are stale — stop.** Either this launcher predates the source it is pointed at, or the source predates the split that created `ai-docs/procedures/`. Show the user what you found, and offer to re-deploy both skills (`govern-init` and `govern-update`) from `ai-docs/skills/` into `~/.claude/skills/` before proceeding. Do not fall back to scaffolding from memory.

That check matters because `~/.claude/skills/` is a one-shot copy that `git pull` does not touch, and a stale installer scaffolds the wrong shape out of perfectly current rules. It has happened in this package's history: a deployed `govern-init` went unnoticed long enough to start laying down a pre-restructure layout (rule files at the repo root, a since-split `ai-coding-rules.md`). Keeping the procedure in the source repo is what turns that failure from silent into a hard stop — but only if you honor the stop.
