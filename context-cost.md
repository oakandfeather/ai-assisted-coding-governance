# Context cost of the governance package

**Last reviewed:** 2026-08-23

Tracks how much of an agent's context window the `ai-docs/` package consumes when it's loaded per `AGENTS.md`'s "load in one pass" instruction. Re-run the measurement below and update this table when `ai-docs/` files change size materially — it's a cost metric, not a governed rule file, so it doesn't need a version bump on every edit.

*How these numbers were arrived at — every compression pass, what it took, what it declined, and each re-measurement that found a row stale — is in [`context-cost-log.md`](./context-cost-log.md). **This file states the current cost.***

## Methodology

Word/char counts are exact (`wc -w -c` over each file). Token counts are an **approximation** at ~4 characters/token for English markdown — not a real tokenizer run, so treat these as ballpark, not precise.

```
wc -w -c ai-docs/*.md ai-docs/client-profiles/*.md
```

**The entry-file row is a separate measurement, not part of the command above.** `ai-docs/*.md` also matches `AGENTS.template.md`, but that file still carries its "how to use it" banner and unfilled `*(placeholders)*` — content an installed repo never actually loads. Run `scripts/build.ps1` first and measure `build/AGENTS.md` instead: banner stripped, placeholders filled, which is what an agent's context actually pays for.

## Per-file cost

| File | Words | Est. tokens |
|---|---:|---:|
| `core-rules.md` | 1,765 | ~3,050 |
| `coding-rules.md` | 771 | ~1,350 |
| `writing-rules.md` | 1,405 | ~2,400 |
| `database-rules.md` | 1,259 | ~2,100 |
| `coding-patterns.md` | 1,122 | ~1,980 |
| `writing-patterns.md` | 1,803 | ~3,000 |
| `agent-workflow.md` | 2,574 | ~4,200 |
| `client-profiles.md` + one profile | 414 | ~750 |
| entry file (`AGENTS.md`, placeholders filled) | 1,006 | ~1,850 |
| entry file (`CLAUDE.md`, the thin pointer itself) | 181 | ~150 |

## Standing constraints on compression

These bind the next pass over `ai-docs/`. Each was arrived at by a pass that took a cut and reverted it, or declined one and said why; [`context-cost-log.md`](./context-cost-log.md) has the working.

- **Reachability outranks yield: a rule that survives only as a pointer is unreachable at the moment it is needed.** Cuts *within* a file an agent loads whole are safe; cuts *between* files it may load separately are not. `coding-rules.md` §4 versus `writing-rules.md` §5 is the sharpest case — those two are *alternative* loads, so deleting either leaves a hole rather than a pointer. This is the same argument that puts the blast-radius gate inline in the entry file rather than delegating it to `agent-workflow.md` §7.
- **Within-file is a licence to delete a *duplicate*, not a rule that merely resembles one.** `agent-workflow.md` §8's closing *"scope delegated work to reading and proposing rather than to acting"* reads like its least-access bullet and is a stricter default than it; replacing it with a backreference swaps an actionable rule for a pointer.
- **One clause of rationale each is the floor, not padding.** On a rule an agent would otherwise pattern-match past, the trailing "so the human reviewer sees the check rather than assuming it" is the thing doing the work. The three self-check footers are where this bites.
- **`agent-workflow.md` §6 currently delegates the blast-radius enumeration to §7's floor**, so an agent reading §6 alone learns that a typo is exempt without learning what always qualifies. **If a Layer B run shows the falsification pass skipped on design-bearing work, restore the enumeration in §6 first.**
- **Do not trim `database-rules.md` §5's "a script that only works once is a defect, not a convention to match."** The trailing words read as a restatement of the bullet's own lead-in and are not: they override `core-rules.md` §2's match-the-existing-conventions rule for the one case where the local convention *is* the defect. That is the B-D5 control-arm fail signature exactly — bare `INSERT`s written "in the local style" — which makes it the sentence in that file with the most measured behavioral value.
- **A nested `@` path resolves against the importing file's directory, not the repo root.** From `ai-governance/client-profiles.md`, `@client-profiles/acme.md` loads and `@ai-governance/client-profiles/acme.md` silently does not — and the second is the shape a maintainer would copy from `CLAUDE.md`'s own root-relative imports. `check-links.ps1` resolves non-template `@` targets against the file's own directory, which matches.
- **The strongest remaining cross-file candidate, for a pass that revisits that line:** `writing-rules.md` §2's *"prefer primary and current sources… note the date where currency matters"* restates `core-rules.md` §9's third bullet nearly verbatim, in a section whose own last bullet already delegates staleness to §9 — so unlike the other declined candidates, the file has declared the topic delegated and then restated it anyway.

**The remaining reduction is a governance decision, not a density one.** Every file has had a density pass and each is at its recorded floor; what is left is duplication that reachability protects. Cutting further means removing a rule or relaxing the constraint above.

## Scenario totals

**There is a floor.** The installed `CLAUDE.md` `@`-imports `core-rules.md`, `agent-workflow.md`, and the `client-profiles.md` index directly, so on Claude Code those three arrive in every session whether or not the agent decides to open anything — they are no longer a loading *choice*. The graduated rule in `AGENTS.md` ("scale that set to the blast radius") still governs the five conditional files **and the client profile's body**, which is what the second column measures.

| Scenario | On top of the floor | Est. tokens |
|---|---|---:|
| **Floor — every session** | entry files (`AGENTS.md` + `CLAUDE.md`) + `core-rules.md` + `agent-workflow.md` + `client-profiles.md` index, imported | **~9,450** |
| Trivial edit | *nothing* | ~9,450 |
| Non-trivial coding task | + `coding-rules.md` + `coding-patterns.md` + the client profile body | ~13,250 |
| Non-trivial writing task | + `writing-rules.md` + `writing-patterns.md` + the client profile body | ~15,300 |
| Non-trivial database-project task | + `database-rules.md` + `coding-patterns.md` + the client profile body | ~14,000 |
| Everything at once | + all five conditional files + the client profile body | ~20,700 |

On every supported CLI other than Claude Code there is no floor, because none of them has an import mechanism: every rule file including `core-rules.md` still depends on the agent following a link. The first column is a Claude Code guarantee and an aspiration everywhere else.

## Caveats

- This is a one-time context-window cost **per session**. **The floor is paid unconditionally on Claude Code** — `CLAUDE.md` imports those files, so they load whether the agent wants them or not, and they survive `/compact`. Everything above the floor is still paid only when a file is actually `Read`, and **a linked file that is never opened costs nothing and binds nothing** — which is the failure the floor exists to prevent, not a saving. The graduated-loading rule exists to avoid paying the ~20.7k full cost on every task.
- Prompt caching (where the harness supports it) makes repeat reference *cheap in billing* within a session once a file is cached, but it does not reduce how much of the context window that file occupies.
- These numbers reflect `ai-docs/` as of 2026-08-23, re-measured file by file rather than carried forward. Carrying figures forward is how rows go stale — re-measure after any material edit to a file listed above, and record the pass in [`context-cost-log.md`](./context-cost-log.md).
