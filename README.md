# AI-Assisted Coding Governance

This repository provides policy and guidance for AI-assisted software development for yourself or clients. This repository is documentation only — there is no application code, no build, and no test runner.

---

## Two tracks, same rules

The same governance is maintained for two different readers - AI agents and people:

- **[`ai-docs/`](./ai-docs/)** — for AI agents (coding and content work). Terse, imperative, rule-shaped. These are the files you copy into a client project.
- **[`human-docs/`](./human-docs/)** — for people. Onboarding, the full developer guideline, and the authoritative client policy.

Alongside them, **[`testing/`](./testing/)** holds the plan for verifying that this package actually works — that it installs correctly, and that its rules change how an agent behaves. It is a third directory rather than a third track: it ships to nobody and is not onboarding material. See [`testing/Governance-Test-Plan.md`](./testing/Governance-Test-Plan.md) for the plan and [`testing/coverage-matrix.md`](./testing/coverage-matrix.md) for what each scenario currently scores; the dated record behind both — every run, and every revision to the plan — is in [`testing/run-log.md`](./testing/run-log.md) and [`testing/test-plan-changes.md`](./testing/test-plan-changes.md).

## Adopting this in a client project

**The same package installs the same way for everyone.** Every install lands two entry files — `AGENTS.md` and `CLAUDE.md` — plus an `ai-governance/` rules directory, covering Claude Code, OpenAI Codex, the GitHub Copilot CLI and coding agent, and any other tool that reads a root `AGENTS.md`, in one pass. **Which AI tool you use doesn't change *what* gets installed — only *how* you install it, and which entry file that tool then reads.**

**Scope: coding CLIs.** The package targets command-line coding agents only. In-IDE assistants that use their own instruction path — GitHub Copilot Chat and inline suggestions, which read `.github/copilot-instructions.md` — are **out of scope**, and that file is not shipped. If you need Copilot in the IDE governed, that is a second entry file to maintain by hand; see the trade-off recorded in [`AGENTS.md`](./AGENTS.md) under *Multi-tool entry points*.

### Step 1 — Find your AI tool

Every tool ends up covered no matter how you install, so this table is really "which entry file will *my* tool auto-load, and which install path is easiest for me":

| Your AI tool | Entry file it auto-loads | Easiest install path |
| --- | --- | --- |
| **Claude Code** | `CLAUDE.md` (which imports `AGENTS.md`, `core-rules.md`, `agent-workflow.md`, and `client-profiles.md`) | **Path A** — the `/govern-init` skill |
| **OpenAI Codex, the Copilot CLI / coding agent, or any other `AGENTS.md` reader** | `AGENTS.md` | **Path B** — hand your agent the procedure |
| **No agent in the loop** (you are copying files yourself) | *(both — they land as files)* | **Path C** — copy the files by hand |

All three land the identical file set; they differ only in who does the work. **Path A** is a one-time setup that buys you a slash command. **Path B** needs no setup at all — you paste one instruction into any agent that can read and write files, which is the fastest route if you're not on Claude Code (and works in Claude Code too, without installing the skill). **Path C** is you, a file manager, and ten minutes; take it when no agent is in the loop.

One honest caveat, whichever path you take: **Claude Code's `@import` reliably pulls `AGENTS.md` into context; every other supported CLI loads `AGENTS.md` but has no import mechanism, so it does not reliably pull the relative-linked `ai-governance/*.md` files in the same way.** (Behavior varies by tool; see `testing/coverage-matrix.md`.) That is why each entry file restates the non-negotiable core inline and tells the agent, in imperative terms, to open `core-rules.md` before any task (and `coding-rules.md` / `writing-rules.md` / `database-rules.md` before code / content / schema work). The core binds regardless; the full rules bind reliably on Claude Code and depend on the agent following the link elsewhere. Human review before merge (below) is the backstop.

### Path A — the `/govern-init` skill (Claude Code)

Run from the target repo's root, `/govern-init` copies the file set in, strips the template banners, interviews you for the `*(placeholders)*`, and authors the active client's profile.

**One-time setup** — the skills aren't installed by default. Clone this repo, install them where Claude Code finds them, and point them at the source package. This installs both `/govern-init` (scaffold a new repo) and `/govern-update` (refresh an existing install); you want both, since the second is how installed repos stop drifting. The destination (`~/.claude/skills`) and the steps are the same on every OS; only the shell syntax differs, so use the block for your OS.

**macOS / Linux** (bash):

```bash
# 1. Clone the source package, if you don't already have it locally.
git clone https://github.com/oakandfeather/ai-assisted-coding-governance.git
cd ai-assisted-coding-governance

# 2. Install the skills where Claude Code finds them. Personal, not per-project:
#    you run /govern-init inside the target repo, which has no governance
#    files yet — a project-level install would have to already be there.
#    Delete first: `cp -r` into an existing directory nests a copy inside it
#    rather than replacing it, so a re-run would leave the old skill in place.
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/govern-init ~/.claude/skills/govern-update
cp -r ai-docs/skills/govern-init   ~/.claude/skills/govern-init
cp -r ai-docs/skills/govern-update ~/.claude/skills/govern-update

# 3. Point it at this repo, so it knows where to copy the package FROM.
#    `export` alone lasts only for the current shell — append it to your
#    shell profile so it survives, then reload.
PROFILE=~/.bashrc          # zsh (the macOS default): PROFILE=~/.zshrc
echo "export AI_GOVERNANCE_PATH=$(pwd)" >> "$PROFILE"
source "$PROFILE"
```

**Windows** (PowerShell):

```powershell
# 1. Clone the source package, if you don't already have it locally.
git clone https://github.com/oakandfeather/ai-assisted-coding-governance.git
Set-Location ai-assisted-coding-governance

# 2. Install the skills where Claude Code finds them. Delete first: -Force does
#    NOT replace an existing directory, it nests a copy inside it, so a re-run
#    would leave the old skill in place and silently keep running it.
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue `
    "$HOME\.claude\skills\govern-init", "$HOME\.claude\skills\govern-update"
Copy-Item -Recurse -Force ai-docs\skills\govern-init   "$HOME\.claude\skills\govern-init"
Copy-Item -Recurse -Force ai-docs\skills\govern-update "$HOME\.claude\skills\govern-update"

# 3. Point it at this repo. User scope persists across sessions and needs no
#    admin; a plain `$env:` assignment would die with this shell.
[Environment]::SetEnvironmentVariable('AI_GOVERNANCE_PATH', $PWD.Path, 'User')
```

Restart Claude Code afterwards so it picks up both the skills and the environment variable. Verify with `/govern-init` — if it asks where the source package is, `AI_GOVERNANCE_PATH` didn't take.

**Per engagement:** `cd` to the target repository's **root**, then run `/govern-init`.

The rules live in exactly one place — this repo's `ai-docs/`. So does the procedure, at [`ai-docs/procedures/govern-init.md`](./ai-docs/procedures/govern-init.md): the installed skill is a ~20-line **launcher** that finds `$AI_GOVERNANCE_PATH` and reads that file fresh on every run. `git pull` here therefore keeps both the rule files *and* the procedure a new scaffold receives current. If the launcher can't find the source package it stops and says so; it will not reconstruct the rule files from memory, because a paraphrased safety rule is not the safety rule.

**One thing `git pull` still doesn't update: the launcher.** `~/.claude/skills/` is a one-shot copy. But the launcher rarely changes, and when it *is* out of date it fails loudly rather than quietly — it looks for `ai-docs/procedures/govern-init.md` in the source, and stops with a re-deploy prompt if it isn't there. Still: **re-run step 2 after any `git pull` that touches `ai-docs/skills/`.**

### Path B — hand the procedure to any agent (any OS, any tool)

The installer and updater are plain Markdown procedures with no tool calls in them, so any agent that can read and write files can run one. Nothing to install: clone this repo, then paste the instruction.

**To install the package** into a target repo, open your agent *in that repo* and give it:

> Read `<path-to-this-repo>/ai-docs/procedures/govern-init.md` and follow it exactly. That repository is the source package; this repository is the target.

**To refresh an existing install** in a repo that already has an `ai-governance/` directory:

> Read `<path-to-this-repo>/ai-docs/procedures/govern-update.md` and follow it exactly. That repository is the source package; this repository is the target.

The agent needs read access to this repo and write access to the target. Both procedures will interview you — for the placeholders and the client profile on install, for a per-tier approval on update — so stay in the loop rather than firing and forgetting. Both stop rather than guess if they can't read a source file.

### Path C — copy the files by hand (any OS, any tool)

This path is **pure file-copying — no scripts, identical on macOS, Linux, and Windows.** Put the two entry files where each tool looks for them and the rest in an `ai-governance/` directory beside them, renaming the templates:

| From | To | Why |
| --- | --- | --- |
| `ai-docs/AGENTS.template.md` | `AGENTS.md` *(repo root)* | The **canonical entry** — the one full body. Codex CLI, the Copilot CLI and coding agent, and every other `AGENTS.md` reader load it from the root. Fill its placeholders. |
| `ai-docs/CLAUDE.template.md` | `CLAUDE.md` *(repo root)* | Thin Claude Code pointer: `@AGENTS.md`, plus `@ai-governance/core-rules.md`, `@ai-governance/agent-workflow.md`, and `@ai-governance/client-profiles.md`. Claude Code auto-loads `CLAUDE.md` from the root only — not a subfolder, not under the `.template` name — and imports the shared body. Keep all four import lines: `AGENTS.md` only *links* those files, and the two always-on rule files plus the client-profile index are imported here so they cannot be skipped. |
| `ai-docs/core-rules.md` | `ai-governance/core-rules.md` | The task-agnostic base rules — mandatory for every task. |
| `ai-docs/coding-rules.md` | `ai-governance/coding-rules.md` | Code-specific rules: dependencies, security, testing, accessibility. |
| `ai-docs/writing-rules.md` | `ai-governance/writing-rules.md` | Content-specific rules: grounding, citations, confidentiality, voice, accessible docs, verified documentation. |
| `ai-docs/database-rules.md` | `ai-governance/database-rules.md` | Database-project rules, for repos where the schema is the deliverable: deploy guards, destructive schema change, reading the generated deploy script, drift, shipped data. |
| `ai-docs/coding-patterns.md` | `ai-governance/coding-patterns.md` | Engineering-craft patterns. |
| `ai-docs/writing-patterns.md` | `ai-governance/writing-patterns.md` | Writing-craft patterns, including documentation of software. |
| `ai-docs/agent-workflow.md` | `ai-governance/agent-workflow.md` | How to work: loop, ask-vs-proceed, verification, hand-off, iteration and self-review, economy of effort, subagent delegation. |
| `ai-docs/client-profiles.md` | `ai-governance/client-profiles.md` | Index of per-client overrides. |
| `ai-docs/client-profiles/` | `ai-governance/client-profiles/` | The profiles themselves — **excluding `example-university.md`**, which is a fictional sample and must never land in a real client's repo. |

The two entry files go at the repo root; the eight companion files and `client-profiles/` travel together into `ai-governance/`. `AGENTS.md` links into `./ai-governance/`, `CLAUDE.md` imports `AGENTS.md` plus the two always-on rule files and the client-profile index, and the files inside `ai-governance/` link each other with relative `./` paths — so keep them together; separating them breaks the chain. Then fill in the italicized `*(placeholders)*` **in `AGENTS.md`** (the thin `CLAUDE.md` carries none), and write the active client's profile into `ai-governance/client-profiles/`. **Unfilled placeholders mean the repo is unconfigured:** ask before assuming a stack, client, or command. Never guess a client's rules — no profile at all is safer than an invented one, because `core-rules.md` §8 only falls back to sensitive-by-default when the profile is *absent*.

`human-docs/` stays here. It is not copied into client repos. The copied `AGENTS.md` carries a short "For the humans on this project" note pointing developers back to it — that travels automatically, no extra copy step. To put the same pointer where people look first, add a block like this to the target repo's `README.md` (or `CONTRIBUTING.md`) — the install procedure offers this automatically on Paths A and B; on Path C you add it by hand:

```markdown
## AI-assisted development

This repository follows *(your company)*'s AI-assisted coding governance. The rules AI
agents follow live in `./ai-governance/` — start at `AGENTS.md`. Developer onboarding
and the full guideline live in the AI-governance source repository.
```

Curious what the result of any of these paths actually looks like? `build/` in this repo is a ready-made example of it — the package fully assembled and filled in for the sample client (ESU), regenerated on demand via `scripts/build.ps1`. For the generic, unconfigured shape instead — no client, `AGENTS.md` placeholders left as-is — see `empty-build/`, regenerated via `scripts/build-empty.ps1`. Both are gitignored, not something you copy from.

### Keeping an install current

Every path leaves a **copy** in the client repo, and a copy drifts: when `core-rules.md` gains a section or the precedence chain changes here, nothing propagates on its own.

**Claude Code:** run `/govern-update` from the target repo's root. **Any other agent:** the Path B instruction above, pointed at [`ai-docs/procedures/govern-update.md`](./ai-docs/procedures/govern-update.md) — same procedure, no setup.

Either way it shows you what changed before changing anything, then works in tiers — the seven portable rule files and the thin `CLAUDE.md` are replaced outright, while `AGENTS.md` and `ai-governance/client-profiles.md` are **merged**, because those two carry local content an overwrite would destroy. `ai-governance/client-profiles/` is never touched at all.

**By hand** (no agent in the loop), the same split is what matters. Safe to re-copy straight from `ai-docs/`: `core-rules.md`, `coding-rules.md`, `writing-rules.md`, `database-rules.md`, `coding-patterns.md`, `writing-patterns.md`, `agent-workflow.md`, and the thin `CLAUDE.md` (re-strip its banner). **Do not re-copy** `AGENTS.md` or `ai-governance/client-profiles.md`: bring the upstream changes into them by hand instead, keeping your filled placeholders, your `Active client` value — it appears **twice**, in the header *and* inside the mandatory-rules block — and your active-client list. Leave `ai-governance/client-profiles/` alone.

One thing no path can do: a repo scaffolded before the `ai-governance/` restructure (rule files at the root, a since-split `ai-coding-rules.md`) cannot be mechanically updated, because that file's contents were reorganized into three. The update procedure detects that shape and refuses rather than guessing; re-install fresh, or migrate with a human reading both versions.

## Precedence

> **client profile > `core-rules.md` > `coding-rules.md` / `writing-rules.md` / `database-rules.md` > `coding-patterns.md` / `writing-patterns.md` / `agent-workflow.md` > project entry file** *(`AGENTS.md` / `CLAUDE.md`)*

The stricter rule always wins. Above all of it sits the client's own AI policy, where they have one: it is the upstream authority and controls where anything here conflicts with it. Reproduce it in [`human-docs/Example-Client-AI-Policy.md`](./human-docs/Example-Client-AI-Policy.md), which explains the slot and what such a policy covers.

The client profiles ship with one **sample** profile — Example State University, a fictional public university — to show the expected shape. It is not a live client; replace it with the real thing.

## Why these are files, not a skill

The rules bind on every task, so they have to load on every task. Every supported tool auto-loads a root entry file each session — `CLAUDE.md` for Claude Code, `AGENTS.md` for Codex, the Copilot CLI, and every other `AGENTS.md` reader — whereas a skill only enters context when the model judges its description relevant, and a rule that might not load is not a rule. Copying the files into the client's repo also keeps the governance reviewable in their PRs and auditable by whoever maintains the project next.

The installer and updater sit outside that argument, because they are *procedures*, not rules: they run when you ask for them, and nothing binds on their being in context. They are files too — [`ai-docs/procedures/`](./ai-docs/procedures/) — for a different reason: a procedure written as prose with no tool calls in it can be handed to **any** agent (Path B), while a skill can only be run by Claude Code. `ai-docs/skills/` holds thin launchers over those same files, so the slash commands stay available without forking the procedure into a second copy. Neither the procedures nor the launchers contain rule text, and neither is installed into a client's repo. Claude Code uses the root `CLAUDE.md` import; every other supported CLI uses `AGENTS.md`.

## Maintaining this repo

See [`AGENTS.md`](./AGENTS.md) for the reference chain, the deduplication discipline, and editing conventions. The short version: each rule is stated once in its owning file, everything else links to it, and the two tracks must not drift apart.

This repo applies its own governance to itself, using the same two-entry-file design it ships: `AGENTS.md` is the canonical entry file, and `CLAUDE.md` `@`-imports it along with the two always-on rule files and the client-profile index. The one deliberate difference from an install: they link to `ai-docs/` directly rather than to a copied `ai-governance/`, because the rule files already live here — see the note in `AGENTS.md`.

[`CHANGELOG.md`](./CHANGELOG.md) holds the dated record of the package's **shape** — every change to what it ships, which file carries which body, and which tools it targets, with the reasoning behind it. The entry files state the shape as it stands now; the changelog states what it used to be.

[`context-cost.md`](./context-cost.md) tracks the context-window cost of loading `ai-docs/` — per-file and per-scenario token estimates, plus the standing constraints on compressing those files further, re-measured whenever they change materially. [`context-cost-log.md`](./context-cost-log.md) holds the pass-by-pass record behind those numbers.
