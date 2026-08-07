# Client Profiles

*Client-specific rules. Load the active client's profile before starting work; where it is stricter than the portable rules in [`core-rules.md`](./core-rules.md) or the task modules, the profile governs.*

**Version:** 1.4 · **Last reviewed:** 2026-08-07 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## Active client profiles

*(none yet)* — **no live client profile ships in this package.** The sample below is not one; never infer a client's rules from it. An empty list means the repo is unconfigured: ask for the client's rules, don't assume them.

Add each client as `client-profiles/<client>.md` and link it here. Cover: permitted tools · data rules · disclosure · compliance regimes · escalation path. The client's own AI policy, where they have one, is the upstream authority: it controls on conflict, so reconcile the profile against it, never the reverse.

## Sample profile

- **Example State University (ESU)** — a fictional client, shown only for expected shape and detail level: [`client-profiles/example-university.md`](./client-profiles/example-university.md). Delete once a real profile exists.
