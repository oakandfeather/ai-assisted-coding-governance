# CLAUDE.md

Guidance for Claude Code in this repository lives in `AGENTS.md`, the shared entry file all coding agents read. Load it:

@AGENTS.md

<!-- The two imports below are the routing fix, not local customization: AGENTS.md
     links the rule files, it does not import them, and a linked file nobody opened
     never loaded. Do not delete them as "not thin" - they are routing, not rules.
     Stripped from context before injection, so this note costs nothing.
     Paths are ai-docs/, not ai-governance/: this repo is the source package. -->

`AGENTS.md` links the other rule files rather than importing them, and a linked file you have not opened has not loaded. The two that bind on every task are imported here instead:

@ai-docs/core-rules.md
@ai-docs/agent-workflow.md

Open the task-specific files `AGENTS.md` links as your task calls for them.
