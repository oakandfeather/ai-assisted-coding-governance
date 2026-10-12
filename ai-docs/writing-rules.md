# AI Writing Rules for Content Agents

*Rules for producing or editing written deliverables — documents, research, analysis, technical documentation — with §§1–6 below the whole scope. **Read [`core-rules.md`](./core-rules.md) first:** it holds the base that binds on every task; this file adds only the content rules. **Documentation about code** — READMEs, API references, runbooks, release notes — is a written deliverable, governed here, and by [`coding-rules.md`](./coding-rules.md) only when you also change code.*

**Version:** 1.7 · **Last reviewed:** 2026-10-12 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the content checklist to run on every deliverable

Run this **after** the `core-rules.md` TL;DR. Full detail in §§1–6.

1. **Grounding:** every factual claim, number, and quote is traceable to a real source — nothing invented.
2. **Citations:** sources are real, current, and verifiable; attribution is accurate.
3. **Confidentiality:** client documents and data stay inside the approved workspace; nothing regulated or proprietary leaks.
4. **Fidelity:** the client's or author's meaning, voice, and framing are preserved — no injected claims or positions.
5. **Accessible documents:** headings, alt text, plain language, and sufficient contrast in what you produce.
6. **Verified documentation:** every command, snippet, and API call you document was actually run — or is labelled unverified.

Any "no" or "unsure": fix or flag it before presenting. Scale depth to the blast radius (`core-rules.md`) — a small wording fix needs a quick pass; anything asserting facts, citing sources, or restating client positions needs the full check, and your hand-off states which items you verified — especially that claims and citations trace to real sources — so the reviewer sees the check rather than assuming it.

---

## 1. Factual grounding and no fabrication

- **Ground every factual claim.** Assert facts, figures, dates, names, and quotes only when they trace to a real source you can point to — the provided material, an authoritative reference, or the client's own documents.
- **Never invent a statistic, quote, event, or attribution.** A plausible number with no source is worse than an acknowledged gap: say you don't have it and leave a marked placeholder.
- **Quote accurately.** Verbatim from the source; don't paraphrase inside quotation marks or attribute a paraphrase as a direct quote.
- **Distinguish what the source says from what you infer.** Mark analysis, extrapolation, and opinion as such.
- **Flag uncertainty explicitly.** When a claim is unverified, out of date, or contested, say so in the text or your hand-off.

## 2. Citation and source integrity

- **Cite real, verifiable sources.** Don't fabricate references, URLs, DOIs, page numbers, or author names. If you cannot verify a citation, flag it for checking rather than presenting it as verified.
- **Prefer primary and current sources** that are authoritative for the claim — how to verify a source before citing it is `core-rules.md` §9.
- **Attribute honestly.** Credit the origin of facts, ideas, and figures; don't present sourced material as original or original material as sourced.
- **Match the project's citation convention** (footnotes, inline links, a references section) rather than imposing your own.
- **Don't launder licensed or copyrighted text** into a deliverable without attribution and a license check (`core-rules.md` §3).

## 3. Confidentiality of client documents and data

- **Keep client documents inside the approved workspace.** Don't send drafts, source documents, research inputs, or excerpts to external tools or endpoints unless the task legitimately requires it and the destination is approved (`core-rules.md` §1, §5).
- **Minimize regulated and sensitive content.** Don't reproduce PII, health, education, or financial records into deliverables, examples, or summaries beyond what the task needs; `core-rules.md` §1 applies to produced content too.
- **Watch for over-disclosure in aggregation.** A summary or dataset combining several sources can expose more than any one did.
- **Respect the client's handling and retention rules**; don't copy sensitive material to convenient-but-unapproved locations.

## 4. Voice, tone, and framing fidelity

- **Preserve the author's or client's meaning.** When editing or summarizing, keep the intended message, scope, and emphasis; don't quietly change what a document claims or commits to.
- **Don't inject positions.** No opinions, recommendations, promises, or claims the client hasn't made — especially in anything that speaks for the client (public statements, policy, correspondence).
- **Match the established voice and register** — the client's style guide, terminology, and tone where one exists.
- **Preserve hedging and precision.** Don't strengthen "may" into "will," "some" into "all," or a qualified estimate into a firm figure; those distinctions are often deliberate and sometimes legally load-bearing.
- **Each hedge in a sentence is a separate claim.** A permission hedge and a ceiling hedge are not a redundant pair: drop "may" from "the registrar *may* retain records for *up to* 7 years" and it becomes a promise the source never made, even with "up to" intact. When asked to tighten or punch up a sentence, compress the wording, not the number of hedges — if you can't keep both, flag the tension instead of cutting one.
- **Flag, don't silently resolve, substantive ambiguity** in what the client means (`core-rules.md` §7, `agent-workflow.md` §2).

## 5. Accessible documents

Make documents, pages, and other content artifacts accessible by default (the ADA Title II baseline is WCAG 2.1 AA; prefer WCAG 2.2 where the client has adopted it):

- **Use a real heading structure** — proper heading levels in order, not bold text faked as headings — so the document is navigable.
- **Provide meaningful alt text** for images, charts, and diagrams; don't leave informative visuals undescribed.
- **Write in plain language** appropriate to the audience; define jargon; prefer clear structure (lists, short paragraphs, descriptive link text) over dense blocks.
- **Ensure sufficient contrast and don't rely on color alone** to convey meaning in tables, charts, or callouts.

*(Application UI and markup accessibility — ARIA, focus states, keyboard navigation — is [`coding-rules.md`](./coding-rules.md) §4.)*

## 6. Verified documentation

Applies when the deliverable documents software — a README, API reference, runbook, release note, help-center article, in-repo guide, or an agent instruction file such as `AGENTS.md` and its companions.

- **Run every example before you ship it.** Commands, snippets, config fragments, and API calls in documentation are claims about behavior: execute the command, compile the snippet, hit the endpoint. A *real* flag in an unrun example is still an unverified claim. If you cannot run it, say so in the document or your hand-off rather than presenting it as working.
- **Verify the form you ship, not a neighbour of it — and claim only what the run showed.** One working run with a `--` separator establishes that invocation, not that the separator is *required*. When a sentence claims more than the run does — *always*, *required*, *only*, *any* — run the variant that proves it or narrow the sentence to what you observed.

*(The rest of what documentation owes its reader — audience, document type, what success looks like, the *why*, keeping docs true as behavior changes — is craft, in [`writing-patterns.md`](./writing-patterns.md) §4.)*
