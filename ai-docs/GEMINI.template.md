# GEMINI.md (template)

> **This is a template, not this repository's own guidance.** For guidance on working *in this documentation repo*, see the root [`AGENTS.md`](../AGENTS.md). This file exists to be copied out.
>
> **How to use it.** This is the **thin Antigravity CLI pointer**, not the governance body. Copy it to the **repository root** of the target project and rename it to `GEMINI.md` — that is Antigravity CLI's workspace context filename, read from the project root, not from a subfolder, and not under this `.template` name. It carries no rules of its own: it `@`-imports [`AGENTS.template.md`](./AGENTS.template.md) → `AGENTS.md`, the canonical entry file every agent reads — plus the two rule files that bind on every task, `core-rules.md` and `agent-workflow.md`, and the `client-profiles.md` index naming which client's overrides bind. `AGENTS.md` only links all three. Install `AGENTS.md` (from `AGENTS.template.md`) and the `ai-governance/` directory first, then this file, then fill the placeholders **in `AGENTS.md`** — there are none here.
>
> **This file is optional in a way `CLAUDE.md` is not — don't skip it, but don't mis-sell it either.** Antigravity CLI reads a root `AGENTS.md` natively, so a repo without this file is governed, not blind. What `GEMINI.md` adds is **delivery**: a root file carrying `@` imports, so the two always-on rule files arrive loaded instead of depending on the agent choosing to follow a link. The imports live here rather than in `AGENTS.md` because `AGENTS.md` is the shared body every CLI reads, and this syntax would be literal text to Codex and the Copilot CLI. Whether that expansion actually fires inside a workspace-root `GEMINI.md` is **undocumented and unverified** — Google documents `@filename` for *Rules files* (`~/.gemini/GEMINI.md`, `.agents/rules/`) and separately documents the CLI parsing a root `GEMINI.md`/`AGENTS.md`, without joining the two. If it does not fire, nothing breaks; `AGENTS.md` still governs.
>
> **Antigravity's import syntax differs from Claude Code's — keep the `./` prefix.** Antigravity resolves a relative `@` mention against the rules file's own location, and the explicit relative form (`@./file.md`) is the one its docs demonstrate, so this file uses `@./AGENTS.md`, not `@AGENTS.md`. Do not "simplify" it to match `CLAUDE.md`'s bare form — that is a different tool with a different import resolver.
>
> **Last step.** Retitle the copy to `# GEMINI.md`, delete this banner (everything from the `(template)` title down to and including the horizontal rule below), and **keep everything beneath it verbatim** — the `@./AGENTS.md` import, the three `@./ai-governance/` imports, and their lead-ins. Those imports are routing, not local customization: `AGENTS.md` *links* the rule files rather than importing them, and a linked file the agent never opened never loaded, so deleting them as "not thin" throws away the only reason this file ships.

---

Guidance for Antigravity CLI in this repository lives in `AGENTS.md`, the shared entry file all coding agents read. Load it:

@./AGENTS.md

<!-- The three imports below are the routing fix, not local customization: AGENTS.md
     links the rule files, it does not import them, and a linked file nobody opened
     never loaded. Do not delete them as "not thin" - they are routing, not rules.
     client-profiles.md is the INDEX only: it names which client's profile binds and
     where. The profile body stays linked, so it is still read at a depth scaled to
     the task - importing it would charge every trivial edit for a client's full
     ruleset. Stripped from context before injection, so this note costs nothing.
     Paths use the "./" prefix: Antigravity resolves a relative @ mention against
     the rules file's own location, and the explicit form is the one its docs
     demonstrate. Do not normalize it to CLAUDE.md's bare form - different resolver.
     Note this file is NOT load-bearing for coverage: Antigravity CLI reads root
     AGENTS.md natively, so the repo is governed without it. It ships to upgrade
     two links into imports - see AGENTS.md, "Multi-tool entry points". -->

`AGENTS.md` links the other rule files rather than importing them, and a linked file you have not opened has not loaded. The two that bind on every task are imported here instead, along with the client-profile index — the pointer to the overrides that outrank everything else:

@./ai-governance/core-rules.md
@./ai-governance/agent-workflow.md
@./ai-governance/client-profiles.md

Open the task-specific files `AGENTS.md` links as your task calls for them.
