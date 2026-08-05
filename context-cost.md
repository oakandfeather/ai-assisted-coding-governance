# Context cost of the governance package

**Owner:** *(your company)* — Engineering · **Last reviewed:** 2026-08-05

Tracks how much of an agent's context window the `ai-docs/` package consumes when it's loaded per `AGENTS.md`'s "load in one pass" instruction. Re-run the measurement below and update this table when `ai-docs/` files change size materially — it's a cost metric, not a governed rule file, so it doesn't need a version bump on every edit.

## Methodology

Word/char counts are exact (`wc -w -c` over each file). Token counts are an **approximation** at ~4 characters/token for English markdown — not a real tokenizer run, so treat these as ballpark, not precise.

```
wc -w -c ai-docs/*.md ai-docs/client-profiles/*.md
```

## Per-file cost

| File | Words | Est. tokens |
|---|---:|---:|
| `core-rules.md` | 1,618 | ~2,800 |
| `coding-rules.md` | 803 | ~1,450 |
| `writing-rules.md` | 1,485 | ~2,600 |
| `coding-patterns.md` | 1,276 | ~2,250 |
| `writing-patterns.md` | 1,796 | ~2,950 |
| `agent-workflow.md` | 3,043 | ~4,900 |
| `client-profiles.md` + one profile | 450 | ~800 |
| entry file (`AGENTS.md`, placeholders filled) | 1,248 | ~2,350 |

`agent-workflow.md` is the single largest file — about a third of the cost of a full non-trivial-task load.

## Scenario totals

Per the graduated loading rule in `AGENTS.md` ("scale that set to the blast radius"):

| Scenario | Files loaded | Est. tokens |
|---|---|---:|
| Trivial edit | entry file + `core-rules.md` | ~5,150 |
| Non-trivial coding task | entry + core-rules + coding-rules + coding-patterns + agent-workflow + client profile | ~14,550 |
| Non-trivial writing task | entry + core-rules + writing-rules + writing-patterns + agent-workflow + client profile | ~15,400 |
| Everything at once | entry + all seven `ai-docs/` files | ~23,500 |

## Caveats

- This is a one-time context-window cost **per session**, paid when files are actually `Read` — not merely linked to. The graduated-loading rule exists specifically to avoid paying the ~23.5k full cost on every task.
- Prompt caching (where the harness supports it) makes repeat reference *cheap in billing* within a session once a file is cached, but it does not reduce how much of the context window that file occupies.
- These numbers reflect `ai-docs/` as of 2026-08-05. Re-measure after any material edit to a file listed above.
