# CLAUDE.md (template)

> **This is a template, not this repository's own guidance.** For guidance on working *in this documentation repo*, see the root [`AGENTS.md`](../AGENTS.md). This file exists to be copied out.
>
> **How to use it.** This is the **thin Claude Code pointer**, not the governance body. Copy it to the target project's **repository root** as `CLAUDE.md` — at the root it loads wherever in the repo Claude Code launches, while a copy in a subfolder loads only once the agent touches a file there, and nothing loads under this `.template` name. **Its imports don't travel as far:** launched in a subfolder, Claude Code skips every import that resolves outside that folder, which is all four below, until external imports are approved for the project, and a headless session can't approve them itself. An interactive session asks once; a decline sticks. Start Claude Code at the repo root. In a repo with nested projects, you can also approve the imports for each clone (`govern-init` step 8 says how). It carries no rules: it `@`-imports `AGENTS.md` (from [`AGENTS.template.md`](./AGENTS.template.md)), the body every agent reads, plus `core-rules.md`, `agent-workflow.md`, and the `client-profiles.md` index, which `AGENTS.md` only links. Install `AGENTS.md` and the `ai-governance/` directory first, then this file; fill the placeholders **in `AGENTS.md`** — there are none here.
>
> **Last step.** Retitle the copy to `# CLAUDE.md`, delete this banner (everything from the `(template)` title down to and including the horizontal rule below), and **keep everything beneath it verbatim** — the `@AGENTS.md` import, the three `@ai-governance/` imports, and their lead-ins. A linked file the agent never opened never loaded, so deleting the imports as "not thin" silently un-governs the repo.

---

Guidance for Claude Code in this repository lives in `AGENTS.md`, the shared entry file all coding agents read. Load it:

@AGENTS.md

<!-- The three imports below are the routing fix, not local customization: AGENTS.md
     links the rule files, it does not import them, and a linked file nobody opened
     never loaded. Do not delete them as "not thin" - they are routing, not rules.
     client-profiles.md is the INDEX only: it names which client's profile binds and
     where. The profile body stays linked, so it is still read at a depth scaled to
     the task - importing it would charge every trivial edit for a client's full
     ruleset. Stripped from context before injection, so this note costs nothing. -->

`AGENTS.md` links the other rule files rather than importing them, and a linked file you have not opened has not loaded. The two that bind on every task are imported here instead, along with the client-profile index — the pointer to the overrides that outrank everything else:

@ai-governance/core-rules.md
@ai-governance/agent-workflow.md
@ai-governance/client-profiles.md

Open the task-specific files `AGENTS.md` links as your task calls for them.
