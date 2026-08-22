# AI Coding Rules for Coding Agents

*Rules for writing, editing, or running code, with §§1–4 below the whole scope. **Read [`core-rules.md`](./core-rules.md) first:** it holds the task-agnostic base that binds on every task; this file adds only the code rules on top of it. Reference it from your project's entry file alongside `core-rules.md`. **A database project** — a repository where the schema itself is the deliverable — is [`database-rules.md`](./database-rules.md); this file governs application code, including the code that queries a database. Where a client profile (see [`client-profiles.md`](./client-profiles.md)) is stricter, it wins. Companions: [`coding-patterns.md`](./coding-patterns.md) (engineering craft) and [`agent-workflow.md`](./agent-workflow.md) (how to work).*

**Version:** 2.5 · **Last reviewed:** 2026-08-22 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the code checklist to run on every change

Run this **after** the `core-rules.md` TL;DR. Full detail in §§1–4.

1. **Dependencies:** every package real, necessary, and flagged for verification.
2. **Security:** input validated, output escaped, safe defaults, no injection surface.
3. **Tests:** verify the requirement, cover edge cases, nothing faked to pass.
4. **Accessibility:** WCAG-compliant if UI.

Any "no" or "unsure": fix or flag it before presenting. Scale depth to the blast radius (`core-rules.md`) — anything touching auth, input handling, data storage/transmission, or dependencies gets the full check deliberately, stated in your hand-off.

---

## 1. Dependencies and supply chain

- **Only use packages you are confident exist.** Never invent a package name; if unsure one is real, say so explicitly and tell the user to verify before installing — hallucinated names are a known malware vector (slopsquatting).
- **Prefer the standard library and already-present dependencies**; don't add a dependency for something small you can write directly.
- When you do suggest a new dependency, name it exactly, state what it's for, and note that it should be checked for legitimacy, maintenance status, and license compatibility before install — see `core-rules.md` §9 for how to research that.
- **Never auto-install packages** as part of an agentic action without surfacing them for confirmation first.
- Pin/announce versions where relevant; don't silently pull "latest."

## 2. Security by default

Generate secure code the first time; don't rely on a later pass to fix it.

- **Validate and sanitize all input.** Assume every input is hostile.
- **Use parameterized queries / prepared statements** — never build SQL (or shell commands, or HTML) by string concatenation of untrusted input.
- **Escape output** to prevent injection (XSS, command injection, path traversal).
- **Use safe defaults:** least privilege, secure cookies, HTTPS, current crypto (no MD5/SHA1 for security, no home-rolled crypto), and no disabled TLS verification.
- **Handle errors without leaking internals** (no stack traces or secrets in responses).
- **Apply authn/authz checks on every protected operation**; don't assume the caller is authorized.
- **Call out any security-sensitive surface you generate**, so the reviewer knows where to look.

## 3. Testing

- Write tests that **verify the requirement**, not tests that merely restate the implementation. A test that passes regardless of whether the code is correct is worse than no test.
- Cover edge cases, error paths, and boundary conditions — not just the happy path.
- Don't delete, weaken, or skip failing tests to make a suite go green; fix the cause or surface it.
- Never fake, stub, or hardcode a result so a test appears to pass while the underlying functionality doesn't work.

## 4. Accessibility

**Meet WCAG 2.1 AA** by default in any UI, markup, or component you generate (the ADA Title II baseline; prefer WCAG 2.2 where the client has adopted it):

- Provide meaningful `alt` text, form labels, and ARIA roles where needed.
- Ensure sufficient color contrast and visible focus states.
- Use semantic HTML and keyboard-navigable, screen-reader-friendly structures.
- Don't ship inaccessible defaults and leave it to the reviewer to catch.

*(This file governs code, not the documents around it. Non-UI document accessibility — headings, alt text, plain language, contrast — is [`writing-rules.md`](./writing-rules.md) §5. Documentation a change ships — README, API reference, runbook, release note — is a written deliverable: [`writing-rules.md`](./writing-rules.md) §6 governs its risks (actually run any command or snippet you document), [`writing-patterns.md`](./writing-patterns.md) §4 its craft. This file governs the code they describe. Nor does it govern the schema itself: deploying a schema, destructive DDL, and the data that ships with a database project are [`database-rules.md`](./database-rules.md) — §2's parameterized-query rule still binds on any dynamic SQL built inside a procedure or function.)*

---

## Self-check before presenting code

Re-run this file's **TL;DR** **and** the `core-rules.md` TL;DR — both gates apply, at the depth the blast radius warrants. For changes with a security-sensitive surface or client-regulated data, state in your hand-off which items you verified, so the human reviewer sees the check rather than assuming it.
