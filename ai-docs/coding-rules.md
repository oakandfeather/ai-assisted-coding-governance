# AI Coding Rules for Coding Agents

*The code-specific rules for coding agents — the additions to [`core-rules.md`](./core-rules.md) that apply when you write, edit, or run code. **Read `core-rules.md` first:** it holds the task-agnostic base (secrets, data, correctness, licensing, provenance, agentic actions, compliance, stop-and-ask, client overrides) that binds on every task. This file adds the code-only rules — dependencies, security, testing, accessibility — that operationalize our client coding guidelines and mitigate the risks of AI-generated code. Reference it from your project's entry file alongside `core-rules.md`. When a client profile (see [`client-profiles.md`](./client-profiles.md)) is stricter, the client profile wins. Companions: [`agent-workflow.md`](./agent-workflow.md) (how to work) and [`coding-patterns.md`](./coding-patterns.md) (engineering craft).*

**Owner:** *(your company)* — Engineering · **Version:** 2.0 · **Last reviewed:** 2026-07-22 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the code checklist to run on every change

Run this **after** the `core-rules.md` TL;DR (secrets, data, correctness, licensing, provenance, actions, compliance). These add the code-specific checks; full detail follows in §§1–4.

1. **Dependencies:** every package real, necessary, and flagged for verification.
2. **Security:** input validated, output escaped, safe defaults, no injection surface.
3. **Tests:** verify the requirement, cover edge cases, nothing faked to pass.
4. **Accessibility:** WCAG-compliant if UI.

If any answer is "no" or "unsure," fix it or flag it before presenting. Scale the depth to the blast radius (see `core-rules.md`): for anything touching auth, input handling, data storage/transmission, or dependencies, run the full check deliberately and say so in your hand-off.

---

## 1. Dependencies and supply chain

- **Only use packages you are confident exist.** Do not invent package names. If you are unsure a package is real, say so explicitly and tell the user to verify before installing — hallucinated names are a known malware vector (slopsquatting).
- **Prefer the standard library and already-present dependencies.** Don't add a dependency for something small you can write directly.
- When you do suggest a new dependency, name it exactly, state what it's for, and note that it should be checked for legitimacy, maintenance status, and license compatibility before install.
- **Never auto-install packages** as part of an agentic action without surfacing them for confirmation first.
- Pin/announce versions where relevant; don't silently pull "latest."

## 2. Security by default

Generate secure code the first time; don't rely on a later pass to fix it.

- **Validate and sanitize all input.** Assume every input is hostile.
- **Use parameterized queries / prepared statements** — never build SQL (or shell commands, or HTML) by string concatenation of untrusted input.
- **Escape output** appropriately to prevent injection (XSS, command injection, path traversal).
- **Use safe defaults:** least privilege, secure cookies, HTTPS, current crypto (no MD5/SHA1 for security, no home-rolled crypto), and no disabled TLS verification.
- **Handle errors without leaking internals** (no stack traces or secrets in responses).
- Apply authn/authz checks on every protected operation; don't assume the caller is authorized.
- When you generate code with a known security-sensitive surface, **call it out** so the reviewer knows where to look.

## 3. Testing

- Write tests that **verify the requirement**, not tests that merely restate the implementation. A test that passes regardless of whether the code is correct is worse than no test.
- Cover edge cases, error paths, and boundary conditions — not just the happy path.
- Don't delete, weaken, or skip failing tests to make a suite go green; fix the cause or surface it.
- Never fake, stub, or hardcode a result so that a test appears to pass when the underlying functionality doesn't work.

## 4. Accessibility

When generating UI, markup, or components, meet **WCAG 2.1 AA** by default (the ADA Title II baseline; WCAG 2.2 is the current W3C Recommendation — prefer it where the client has adopted it):

- Provide meaningful `alt` text, form labels, and ARIA roles where needed.
- Ensure sufficient color contrast and visible focus states.
- Use semantic HTML and keyboard-navigable, screen-reader-friendly structures.
- Don't ship inaccessible defaults and leave it to the reviewer to catch.

*(For accessibility of non-UI documents — headings, alt text, plain language, contrast in produced content — see [`writing-rules.md`](./writing-rules.md).)*

---

## Self-check before presenting code

Re-run the **TL;DR at the top of this file** (dependencies, security, tests, accessibility) **and** the `core-rules.md` TL;DR (secrets, data, correctness, licensing, provenance, actions, compliance) — both gates apply, at the depth the blast radius warrants. For changes with a security-sensitive surface or client-regulated data, state in your hand-off which items you verified, so the human reviewer sees the check rather than assuming it.
