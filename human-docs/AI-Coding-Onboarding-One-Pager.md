# AI Coding — New Engineer One-Pager

*The 5-minute version. Read the full **Developer Guideline: Using AI for Client Coding Work** before your first client task, and check the client profile for whichever account you're on.*

**Version:** 1.12 · **Last reviewed:** 2026-09-01 · **Review cycle:** Versioned and reviewed in step with the developer guideline it condenses — the version number tracks that guideline's, so a reader can tell at a glance which edition this summarizes.

---

## The one rule that matters most
**You own every line you ship.** AI wrote it, you're accountable. If you can't read it, explain it, and stand behind it in review — it doesn't get committed. *"The AI suggested it" is never a defense.*

## Never do these
- **Paste secrets or sensitive client data into an AI tool** — no credentials, keys, tokens, `.env`, PII, health/education/financial records, or proprietary source. De-identify to a generic reproduction first.
- **Use an unapproved tool** for a client's non-public work, or leave model-training-on-your-input turned **on**.
- **Ship AI code unreviewed, unscanned, or untested.**
- **Install a package just because AI named it** — hallucinated names get hijacked with malware. Confirm it's real, legitimate, maintained, correctly licensed, and pinned to a version.
- **Carry one client's code or data into another client's work.**

## Know the client's rules first
Every client has different constraints. Before you write a line, check the **client profile** for: which tools are allowed, what data you can share, disclosure/IP/training terms, and compliance regime. When the client's policy is stricter than ours, **the client's policy wins.** (The sample profile in the guideline shows a strict one — three data levels, hard "never with AI" list for FERPA/HIPAA/PII, disclosure expected, accessibility mandatory.)

**And check the repo is governed.** The rules your AI tools follow are installed *in the engagement repo* — **two** entry files at the root, `AGENTS.md` and `CLAUDE.md`, plus an `ai-governance/` directory beside them holding the rules, the client profile in the form the agent reads, and the client's own AI policy it summarizes (`client-policies/`, or a citation in the profile when the client won't have the text in their repo). Both entry files matter: Claude Code reads `CLAUDE.md` and every other supported CLI reads `AGENTS.md`, so a repo with only one of them is ungoverned for half your tools. Missing or stale? Get them installed before you start. Nothing binds an agent that never loaded them.

## The daily loop
1. **Scope it yourself** — know the design before you prompt.
2. **Prompt with abstractions, not secrets.**
3. **Read the output critically** — invented APIs? happy-path only? subtle bugs?
4. **Verify dependencies** before installing.
5. **Test against the requirement** — not just "looks right." (AI tests often just confirm whatever the code already does.)
6. **Review it like a junior wrote it fast** — because that's what happened.
7. **Commit with honest provenance** where the client expects disclosure.

**On a database project**, change one thing: ask for the **generated deploy script**, not the schema diff. The derived script is what actually runs, and a data loss or a table rebuild shows up there and nowhere else — a change can build clean, diff clean, and still drop a populated column on apply.

## Before you commit / ship — quick check
- [ ] I've read and understood every line
- [ ] Passed SAST + secret scan + dependency scan
- [ ] Dependencies real, legitimate, correctly licensed, version-pinned
- [ ] Tests are real, and nothing was skipped or weakened to go green; security reviewed
- [ ] Accessible (if UI + client requires it) · meets client compliance
- [ ] Nothing from another client leaked in
- [ ] Docs it wrote: I ran the examples (a real flag name isn't a working command), and a one-line fix came back as a one-line diff

## When to stop and ask your engagement lead
Unsure if a tool or data input is allowed · the task seems to need sensitive data in an AI tool · a dependency/license/pattern you can't fully vet · something feels off (odd agent behavior, possible data exposure). **Suspected data exposure → escalate same day.**

---
*Full guideline + client profiles live in `AI-Assisted-Coding-Developer-Guideline`. Questions → your engagement lead.*
