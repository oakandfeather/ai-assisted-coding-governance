# CLAUDE.md (template)

> **This is a template, not this repository's own guidance.** For guidance on working *in this documentation repo*, see the root [`AGENTS.md`](../AGENTS.md). This file exists to be copied out.
>
> **How to use it.** This is the **thin Claude Code pointer**, not the governance body. Copy it to the **repository root** of the target project and rename it to `CLAUDE.md` — Claude Code auto-loads `CLAUDE.md` from the project root, not from a subfolder, and not under this `.template` name. It carries no rules of its own: it `@`-imports [`AGENTS.template.md`](./AGENTS.template.md) → `AGENTS.md`, the canonical entry file every agent reads, so Claude loads exactly the same body as Codex and Copilot. Install `AGENTS.md` (from `AGENTS.template.md`) and the `ai-governance/` directory first, then this file, then fill the placeholders **in `AGENTS.md`** — there are none here.
>
> **Last step.** Retitle the copy to `# CLAUDE.md`, delete this banner (everything from the `(template)` title down to and including the horizontal rule below), and keep the `@AGENTS.md` import line and its one-sentence lead-in.

---

Guidance for Claude Code in this repository lives in `AGENTS.md`, the shared entry file all coding agents read. Load it:

@AGENTS.md
