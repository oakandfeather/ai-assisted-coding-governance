# Coding Patterns for AI-Assisted Development

*A craft guide for coding agents: how to produce code that is reliable, efficient, and maintainable. This is the companion to the safety/risk rules — [`core-rules.md`](./core-rules.md) (the task-agnostic base: secrets, correctness, licensing, agentic actions) and [`coding-rules.md`](./coding-rules.md) (code-specific: dependencies, security, testing); this file governs engineering quality; [`agent-workflow.md`](./agent-workflow.md) governs how to work. Its content-track sibling is [`writing-patterns.md`](./writing-patterns.md) (writing craft), which owns documentation *of* code — READMEs, runbooks, API references — while this file owns the comments and docstrings that travel inside a source file. Where these overlap or conflict, **safety and correctness win over efficiency and elegance**, and a stricter client profile (see [`client-profiles.md`](./client-profiles.md)) wins over both.*

**Owner:** *(your company)* — Engineering · **Version:** 1.3 · **Last reviewed:** 2026-08-05 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — apply on every change

1. **Smallest correct change.** Solve the stated problem; don't rebuild what works.
2. **Match the codebase.** Its conventions beat your preferences.
3. **Fail loudly, early, and specifically.** No silent failures, no swallowed errors.
4. **Validate at the boundary, trust the interior.** Check untrusted input once, at the edge.
5. **Make it correct, then make it clear, then make it fast** — and only make it fast with a measurement in hand.
6. **Leave it testable:** pure logic, injected dependencies, deterministic behavior.
7. **Clean up what you allocate:** connections, files, locks, timers.

If a change can't satisfy these, flag the tension rather than quietly trading one away.

---

## 1. Reliability and correctness

- **Fail fast and explicitly.** Detect invalid state at the earliest point and stop with a specific error. A crash at the cause beats corrupt data three layers later.
- **Never swallow errors.** Don't catch-and-ignore, don't `except: pass`, don't discard a rejected promise. Handle it, propagate it, or log-and-rethrow — but never make a failure invisible.

  ```text
  BAD:  try { save(order) } catch (e) { /* ignore */ }        // failure vanishes
  GOOD: try { save(order) } catch (e) { throw new OrderSaveError(order.id, e) }
  ```
- **Handle every case.** Cover error paths, empty inputs, boundaries (0, 1, n, max), and — for enums/unions — every variant. Prefer exhaustive `switch`/pattern matches that break loudly on an unhandled case over a silent default.
- **Make errors actionable.** An error message should say what failed and what state caused it — enough to diagnose without a debugger. (Never put secrets or regulated data in messages or logs — see `core-rules.md` §1 and `coding-rules.md` §2.)
- **Design for idempotency and retries** where an operation may run more than once (network calls, queue consumers, migrations). Assume at-least-once delivery; guard side effects.
- **No partial writes.** Group operations that must succeed or fail together into a transaction or an all-or-nothing unit; don't leave data half-updated on failure.
- **Concurrency:** prefer immutable data and message-passing over shared mutable state. Where sharing is unavoidable, make the synchronization explicit and put timeouts on every blocking I/O and lock acquisition.

## 2. Simplicity and maintainability

- **YAGNI.** Build what the requirement needs, not what it might need. Flag speculative extension points instead of adding them.
- **Prefer the boring, explicit solution.** Clever code is a liability the reviewer and the next maintainer pay for.
- **Don't abstract on the first occurrence.** Duplication is cheaper than the wrong abstraction; extract shared code once the pattern is real (roughly the third repeat), not in anticipation.
- **One responsibility per unit.** A function that does one thing, named for what it does, is testable and reusable; a function with an `and` in its true name should split.
- **Name for intent, not mechanism.** `retryableFetch` over `doFetch2`. Names are the cheapest documentation.
- **Keep functions shallow and short.** Reduce nesting with early returns and guard clauses; deep indentation hides logic.
- **Comment the *why*, not the *what*.** The code shows what it does; comments explain intent, trade-offs, and non-obvious constraints. Match the surrounding comment density.

## 3. Efficiency and performance

- **Correct first, fast second.** Never trade correctness or clarity for speed the requirement doesn't demand.
- **Measure before optimizing.** Don't guess at hot paths — profile. Optimizing unmeasured code adds complexity for no proven gain.
- **Get the algorithmic complexity right, though.** This isn't premature — an O(n²) loop or an N+1 query pattern is a design defect, not a micro-optimization. Watch for repeated work inside loops and per-iteration I/O.

  ```text
  BAD:  for user in users: orders = db.query(Order, user.id)   # N+1: one query per user
  GOOD: orders_by_user = db.query(Order, [u.id for u in users])  # one batched query
  ```
- **Right data structure for the access pattern.** Set/map for membership and lookup, not linear scans of a list; pick the structure by how the data is queried.
- **Batch and stream at scale.** Batch remote calls and DB round-trips; stream or paginate large datasets instead of loading everything into memory.
- **Cache deliberately, not reflexively.** A cache adds invalidation and staleness bugs — add it only against a measured cost, and be explicit about its lifetime and invalidation.
- **Release resources promptly.** Close connections, files, and handles; free large buffers; use the language's scoped-cleanup construct (`with`, `defer`, `try-with-resources`, RAII) so cleanup survives the error path.

## 4. Interfaces and data

- **Narrow, honest contracts.** Expose the minimum surface; accept the least you need and return a precise type. A small interface is easier to use correctly and change safely.
- **Validate untrusted input at the boundary; trust it inside.** Parse and check external input once at the edge, then pass well-typed, known-valid data inward — don't re-check the same thing at every layer.

  ```text
  BAD:  handler(raw) → service(raw) → repo(raw)      // every layer re-parses raw dict/JSON
  GOOD: handler: order = parseOrder(raw) or 400 → service(order: Order) → repo(order)
  ```
- **Make invalid states unrepresentable.** Use the type system and enums so bad combinations can't be constructed; prefer that over runtime guards where the language allows.
- **Immutability by default.** Favor immutable values and pure transformations; localize mutation. Shared mutable state is the source of the hardest bugs.
- **Single source of truth.** Derive values instead of duplicating them; don't store what you can compute, and don't let two fields drift out of sync.
- **Be explicit about nullability and absence.** Distinguish "missing," "empty," and "zero"; don't overload one sentinel to mean several things.

  ```text
  BAD:  getDiscount() returns 0 for "no discount", "not yet loaded", AND "lookup failed"
  GOOD: getDiscount() returns Discount | None, raises LookupError on failure
  ```

## 5. Testability and change discipline

- **Write code that's easy to test.** Separate pure logic from I/O; inject dependencies (clock, network, filesystem, randomness) rather than reaching for globals — this makes behavior deterministic and mockable. (For what makes a *good* test, see `coding-rules.md` §3: test the requirement, not the implementation.)
- **Determinism.** No hidden dependence on wall-clock time, ambient locale, map iteration order, or unseeded randomness in logic that must be reproducible.
- **Separate refactors from behavior changes.** Don't reformat, rename, and change logic in one indivisible diff — it hides the real change from review. Keep diffs small and scoped.
- **Follow the existing structure.** Put new code where its neighbors live; reuse the project's existing helpers, error types, and patterns before introducing your own.
- **Update the docs and types that travel with the code** — signatures, docstrings, and adjacent comments — so they don't rot against the change.

---

## Self-check before presenting code

Re-run the TL;DR at the top: smallest correct change, matches the codebase, fails loudly, validates at the boundary, correct-before-fast (with a measurement for any optimization), left testable, resources cleaned up. Where a requirement forced a trade-off against one of these, name it in your hand-off so the reviewer sees the choice. Then run the safety self-checks in `core-rules.md` and `coding-rules.md` — all gates apply.
