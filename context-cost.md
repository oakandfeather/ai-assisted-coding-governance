# Context cost of the governance package

**Last reviewed:** 2026-08-06

Tracks how much of an agent's context window the `ai-docs/` package consumes when it's loaded per `AGENTS.md`'s "load in one pass" instruction. Re-run the measurement below and update this table when `ai-docs/` files change size materially — it's a cost metric, not a governed rule file, so it doesn't need a version bump on every edit.

## Methodology

Word/char counts are exact (`wc -w -c` over each file). Token counts are an **approximation** at ~4 characters/token for English markdown — not a real tokenizer run, so treat these as ballpark, not precise.

```
wc -w -c ai-docs/*.md ai-docs/client-profiles/*.md
```

**The entry-file row is a separate measurement, not part of the command above.** `ai-docs/*.md` also matches `AGENTS.template.md`, but that file still carries its "how to use it" banner and unfilled `*(placeholders)*` — content an installed repo never actually loads. Run `scripts/build.ps1` first and measure `build/AGENTS.md` instead: banner stripped, placeholders filled, which is what an agent's context actually pays for.

## Per-file cost

| File | Words | Est. tokens |
|---|---:|---:|
| `core-rules.md` | 1,614 | ~2,800 |
| `coding-rules.md` | 799 | ~1,450 |
| `writing-rules.md` | 1,481 | ~2,600 |
| `coding-patterns.md` | 1,272 | ~2,250 |
| `writing-patterns.md` | 1,792 | ~2,950 |
| `agent-workflow.md` | 3,039 | ~4,900 |
| `client-profiles.md` + one profile | 446 | ~800 |
| entry file (`AGENTS.md`, placeholders filled) | 973 | ~1,800 |

`agent-workflow.md` is the single largest file — over a quarter of the cost of a full non-trivial-task load.

## Scenario totals

Per the graduated loading rule in `AGENTS.md` ("scale that set to the blast radius"):

| Scenario | Files loaded | Est. tokens |
|---|---|---:|
| Trivial edit | entry file + `core-rules.md` | ~4,600 |
| Non-trivial coding task | entry + core-rules + coding-rules + coding-patterns + agent-workflow + client profile | ~14,000 |
| Non-trivial writing task | entry + core-rules + writing-rules + writing-patterns + agent-workflow + client profile | ~15,850 |
| Everything at once | entry + all seven `ai-docs/` files | ~19,550 |

## What a partial install saves

Module selection at install time (`govern-init` step 2a) removes files from the repo entirely rather than relying on an agent to skip them — which is the difference between a cost an agent *might* not pay and one it *cannot*. The ceiling is what moves:

| Install | `ai-governance/` holds | Ceiling (everything at once) |
|---|---|---:|
| Full | all seven | ~19,550 |
| Code-only (no writing modules) | core, coding-rules, coding-patterns, agent-workflow, client-profiles | ~14,000 |
| Writing-only (no coding modules) | core, writing-rules, writing-patterns, agent-workflow, client-profiles | ~15,850 |
| Core-only | core, client-profiles | ~4,600 |

Read those as ceilings, not typical loads: a code-only install and a full install cost the same on an actual coding task, because graduated loading already skips the writing modules. What declining a module buys is the removal of the worst case — no agent can load what isn't there, and no future edit can quietly make the file bigger. The trade is real and worth stating plainly: a repo without `writing-rules.md` has no §6 run-every-example rule the day someone asks it for a README. Decline a module because the work genuinely isn't there, not to shave the ceiling.

## Caveats

- This is a one-time context-window cost **per session**, paid when files are actually `Read` — not merely linked to. The graduated-loading rule exists specifically to avoid paying the ~19.5k full cost on every task.
- Prompt caching (where the harness supports it) makes repeat reference *cheap in billing* within a session once a file is cached, but it does not reduce how much of the context window that file occupies.
- These numbers reflect `ai-docs/` as of 2026-08-05. Re-measure after any material edit to a file listed above.
