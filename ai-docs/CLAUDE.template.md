# CLAUDE.md (template)

> **This is a template, not this repository's own guidance.** For guidance on working *in this documentation repo*, see the root [`AGENTS.md`](../AGENTS.md). This file exists to be copied out.
>
> **How to use it.** This is the **thin Claude Code pointer**, not the governance body. Copy it to the **repository root** of the target project and rename it to `CLAUDE.md` — Claude Code auto-loads `CLAUDE.md` from the project root, not from a subfolder, and not under this `.template` name. It carries no rules of its own: it `@`-imports [`AGENTS.template.md`](./AGENTS.template.md) → `AGENTS.md`, the canonical entry file every agent reads, so Claude loads exactly the same body as Codex and Copilot — plus the two rule files that bind on every task, `core-rules.md` and `agent-workflow.md`, which `AGENTS.md` only links. Install `AGENTS.md` (from `AGENTS.template.md`) and the `ai-governance/` directory first, then this file, then fill the placeholders **in `AGENTS.md`** — there are none here.
>
> **Last step.** Retitle the copy to `# CLAUDE.md`, delete this banner (everything from the `(template)` title down to and including the horizontal rule below), and **keep everything beneath it verbatim** — the `@AGENTS.md` import, the two `@ai-governance/` rule imports, and their lead-ins. Those imports are routing, not local customization: `AGENTS.md` *links* the rule files rather than importing them, and a linked file the agent never opened never loaded, so deleting them as "not thin" silently un-governs the repo.

---

Guidance for Claude Code in this repository lives in `AGENTS.md`, the shared entry file all coding agents read. Load it:

@AGENTS.md

<!-- The two imports below are the routing fix, not local customization: AGENTS.md
     links the rule files, it does not import them, and a linked file nobody opened
     never loaded. Do not delete them as "not thin" - they are routing, not rules.
     Stripped from context before injection, so this note costs nothing. -->

`AGENTS.md` links the other rule files rather than importing them, and a linked file you have not opened has not loaded. The two that bind on every task are imported here instead:

@ai-governance/core-rules.md
@ai-governance/agent-workflow.md

Open the task-specific files `AGENTS.md` links as your task calls for them.
