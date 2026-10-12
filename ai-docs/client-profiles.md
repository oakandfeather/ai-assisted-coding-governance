# Client Profiles

*Client-specific rules. Load the active client's profile before starting work; where it is stricter than the portable rules in [`core-rules.md`](./core-rules.md) or the task modules, the profile governs.*

**Version:** 1.8 · **Last reviewed:** 2026-10-12 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## Active client profiles

*(none yet)* — **no live client profile ships in this package.** The sample below is not one; never infer a client's rules from it. An empty list means the repo is unconfigured: ask for the client's rules, don't assume them.

Add each client as `client-profiles/<client>-profile.md`, where `<client>` is one lowercase kebab-case slug reused identically in the policy filename beside it (`client-policies/<client>-policy.md`) — in **the repo this file is installed in**, the engagement repo, never back in the governance package it was copied from — and link it here. Cover: permitted tools · data rules · disclosure · compliance regimes · escalation path. **A profile carries only what changes an agent's behavior on a task** — test each line by naming the moment in a task where it changes what an agent does, and cut any line that fails, whatever it is about. Procurement, governance bodies, contract terms, and org structure belong in the human guideline; anything restating `core-rules.md` belongs nowhere. **Keep it to those fields at roughly a line each** — half a dozen tight bullets under a short authority note, not a page; a field earns more lines only when the client's rules genuinely make it longer. The client's own AI policy, where they have one, is the upstream authority: it controls on conflict, so reconcile the profile against it, never the reverse.

**Where the client's own policy lives, and what to do when two profiles disagree.** Reproduce the policy at `client-policies/<client>-policy.md`, beside `client-profiles/`, so it resolves for anyone holding this repo; where the client will not permit its text in their repo, the profile's authority note cites it instead — title, version or date, and canonical URL. Where two or more active profiles differ on a rule, **the stricter governs, rule by rule**. Where they are not comparable — different disclosure trailer formats, escalation contacts, or data-classification vocabularies — there is no stricter option: that is a `core-rules.md` §7 stop-and-ask.

## Sample profile

- **Example State University (ESU)** — a fictional client, shown only for expected shape and detail level: [`client-profiles/example-university.md`](./client-profiles/example-university.md). Delete once a real profile exists.
