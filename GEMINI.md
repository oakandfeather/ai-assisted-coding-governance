# GEMINI.md

Guidance for Gemini CLI in this repository lives in `AGENTS.md`, the shared entry file all coding agents read. Load it:

@./AGENTS.md

<!-- The three imports below are the routing fix, not local customization: AGENTS.md
     links the rule files, it does not import them, and a linked file nobody opened
     never loaded. Do not delete them as "not thin" - they are routing, not rules.
     client-profiles.md is the INDEX only: it names which client's profile binds and
     where. The profile body stays linked, so it is still read at a depth scaled to
     the task - importing it would charge every trivial edit for a client's full
     ruleset. Stripped from context before injection, so this note costs nothing.
     Paths are ai-docs/, not ai-governance/: this repo is the source package.
     Paths use the required "./" prefix: Gemini CLI's @import resolver does not
     accept a bare same-directory filename the way Claude Code's does. -->

`AGENTS.md` links the other rule files rather than importing them, and a linked file you have not opened has not loaded. The two that bind on every task are imported here instead, along with the client-profile index — the pointer to the overrides that outrank everything else:

@./ai-docs/core-rules.md
@./ai-docs/agent-workflow.md
@./ai-docs/client-profiles.md

Open the task-specific files `AGENTS.md` links as your task calls for them.
