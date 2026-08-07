# AI Coding — New Engineer One-Pager

*The 5-minute version. Read the full **Developer Guideline: Using AI for Client Coding Work** before your first client task, and check the client profile for whichever account you're on.*

---

## The one rule that matters most
**You own every line you ship.** AI wrote it, you're accountable. If you can't read it, explain it, and stand behind it in review — it doesn't get committed. *"The AI suggested it" is never a defense.*

## Never do these
- **Paste secrets or sensitive client data into an AI tool** — no credentials, keys, tokens, `.env`, PII, health/education/financial records, or proprietary source. De-identify to a generic reproduction first.
- **Use an unapproved tool** for a client's non-public work, or leave model-training-on-your-input turned **on**.
- **Ship AI code unreviewed, unscanned, or untested.**
- **Install a package just because AI named it** — hallucinated names get hijacked with malware. Confirm it's real, legitimate, maintained, correctly licensed.
- **Carry one client's code or data into another client's work.**

## Know the client's rules first
Every client has different constraints. Before you write a line, check the **client profile** for: which tools are allowed, what data you can share, disclosure/IP/training terms, and compliance regime. When the client's policy is stricter than ours, **the client's policy wins.** (The sample profile in the guideline shows a strict one — three data levels, hard "never with AI" list for FERPA/HIPAA/PII, disclosure expected, accessibility mandatory.)

**And check the repo is governed.** The rules your AI tools follow are installed *in the engagement repo* — `AGENTS.md` at the root plus an `ai-governance/` directory beside it, including the client profile in the form the agent reads. The rules install in modules, so glance at what's actually in `ai-governance/`: `core-rules.md` is always there, the coding and writing modules only if this repo took them. Missing, stale, or short a module the work now needs? Get it installed before you start. Nothing binds an agent that never loaded it.

## The daily loop
1. **Scope it yourself** — know the design before you prompt.
2. **Prompt with abstractions, not secrets.**
3. **Read the output critically** — invented APIs? happy-path only? subtle bugs?
4. **Verify dependencies** before installing.
5. **Test against the requirement** — not just "looks right." (AI tests often just confirm whatever the code already does.)
6. **Review it like a junior wrote it fast** — because that's what happened.
7. **Commit with honest provenance** where the client expects disclosure.

## Before you commit / ship — quick check
- [ ] I've read and understood every line
- [ ] Passed SAST + secret scan + dependency scan
- [ ] Dependencies real, legitimate, correctly licensed
- [ ] Tests are real; security reviewed
- [ ] Accessible (if UI + client requires it) · meets client compliance
- [ ] Nothing from another client leaked in
- [ ] Docs it wrote: I ran the examples (a real flag name isn't a working command), and a one-line fix came back as a one-line diff

## When to stop and ask your engagement lead
Unsure if a tool or data input is allowed · the task seems to need sensitive data in an AI tool · a dependency/license/pattern you can't fully vet · something feels off (odd agent behavior, possible data exposure). **Suspected data exposure → escalate same day.**

---
*Full guideline + client profiles live in `AI-Assisted-Coding-Developer-Guideline`. Questions → your engagement lead.*
