# AI Database Rules for Coding Agents

*Rules for working in a database project — a repository where the schema itself is the deliverable, whether declarative or migration-based — with §§1–5 below the whole scope. **Read [`core-rules.md`](./core-rules.md) first:** it holds the base that binds on every task; this file adds only the database-project rules. **Application code that queries a database is [`coding-rules.md`](./coding-rules.md)**; this file governs the schema itself.*

**Version:** 1.2 · **Last reviewed:** 2026-10-12 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the schema checklist to run on every change

Run this **after** the `core-rules.md` TL;DR. Full detail in §§1–5.

1. **Deploy guards:** no data-loss or drop guard relaxed to make a deploy succeed.
2. **Data loss:** nothing dropped, renamed, narrowed, or rebuilt without preserving the data it holds.
3. **Preview:** the project builds, and the generated deploy script was read before it ran.
4. **Source of truth:** the project is authoritative; drift is reported, not absorbed or overwritten.
5. **Shipped data:** committed reference data is synthetic, and deployment scripts are re-runnable and secret-free.

Any "no" or "unsure": fix or flag it before presenting. Scale depth to the blast radius (`core-rules.md`) — a comment or a new nullable column with a default needs a quick pass; anything that drops, renames, narrows, rebuilds, or deploys gets the full check, and your hand-off states which items you verified and what the generated script does, so the reviewer sees the check rather than assuming it.

---

## 1. Deploy guards are security settings

Applying a schema is irreversible, so `core-rules.md` §5's confirm-first, least-privilege, and no-standing-production-credentials rules apply unchanged.

- **Never relax a data-loss guard to make a deploy succeed.** Turning off a publish or migration setting that refuses to drop an object or discard rows deletes the check standing between a schema change and permanent data loss. A blocked deploy is the finding: report what it refused and what would have been destroyed.
- **Treat "shared" as wider than "production."** A team's development or integration database holds other people's work in progress; confirm before applying to any database you are not the sole user of.
- **Never widen permissions, disable a constraint, or drop a security object to get a script to run.** Grants, access policies, and audit objects in the project are part of the deliverable.

## 2. Rename is not drop-and-recreate

- **Preserve the rename record your tool keeps.** Unless the tool is told a change is a rename, it generates a drop and a create, and the deploy discards every row in the old object while reporting success. Where the tool records refactors in a log or a versioned migration, that record is source — commit it with the change, never regenerate it by hand.
- **Call out every narrowing change explicitly.** Dropping a column, shortening or changing a type, tightening nullability, and adding a constraint or unique index all either fail or lose data against a populated target. Name them in your hand-off; don't let them ride along in an otherwise additive diff.
- **A schema change that needs a data migration is not done without it.** When existing rows must be backfilled, transformed, or split, ship that step alongside — or stop and say the change cannot be applied safely yet.

## 3. Read the generated script before you run it

An authorized deploy (§1) of an unread script is still an unverified change.

- **Generate the deploy script and read it.** The tool derives the change from the state you author, so the derived script — not the schema diff — is what runs. Build the project, produce the script or plan against a representative target, and read what it will do.
- **Report what it drops, alters, or rebuilds.** A generated script routinely rebuilds a whole table to change one column — copy out, drop, recreate, copy back. On a large table that downtime and locking cost is the most important fact about the change; surface it before the deploy.
- **Preview against something representative.** An empty local database proves the project compiles, not that the change is safe. Where you cannot reach a populated target, say so rather than presenting the empty-database result as verification.

## 4. Drift and the source of truth

- **The project in version control is authoritative.** Where a deployed database differs from it, the difference is a finding to report, not a discrepancy to resolve on your own judgment — someone changed one of them for a reason you cannot see.
- **Never reconcile by editing the live database.** A direct fix puts the change outside review, history, and every other environment.
- **Check what a schema import carries before you commit it.** Scripting an existing database into the project pulls in more than tables: real rows in reference and lookup tables, environment-specific objects, comments and extended properties quoting internal detail, and credentials embedded in external-data-source, linked-server, or scoped-credential definitions. `core-rules.md` §1 applies to each.

## 5. Data and scripts that ship with the schema

Deployment scripts run on every deploy, against targets that already hold data, so idempotency here is a data-safety rule, not only craft.

- **Make every deployment script re-runnable.** Guard inserts against rows that already exist, make object creation conditional, and never write a script whose second run does something different from its first. A script that only works once is a defect, not a convention to match.
- **Committed reference data is shipped data.** Lookup tables, seed rows, and fixtures checked into the project are copied into every environment it deploys to, so `core-rules.md` §1's synthetic-data rule applies: obviously-invented values, never real records lifted from a live database.
- **Deployment scripts are a common secret-leak path.** Connection strings, credentials for external sources, and service-account passwords end up in post-deployment scripts because that is where the wiring happens; `core-rules.md` §1 forbids them there as anywhere else.

*(Application code that reads or writes a database — parameterized queries, the injection surface of dynamic SQL built inside a procedure or function — is [`coding-rules.md`](./coding-rules.md) §2. Performance craft — indexing, query shape, N+1 — is [`coding-patterns.md`](./coding-patterns.md) §3. Documentation of the schema is a written deliverable: [`writing-rules.md`](./writing-rules.md) §6.)*
