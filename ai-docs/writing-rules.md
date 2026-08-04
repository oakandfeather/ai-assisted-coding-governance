# AI Writing Rules for Content Agents

*The content-specific rules for AI agents that produce or edit documents, research, analysis, and other non-code deliverables — the additions to [`core-rules.md`](./core-rules.md) that apply when you write or edit content. **Read `core-rules.md` first:** it holds the task-agnostic base (secrets, data, correctness, licensing, provenance, agentic actions, compliance, stop-and-ask, client overrides) that binds on every task. This file adds the content-only rules — factual grounding, citations, confidentiality, voice fidelity, accessible documents — that mitigate the risks of AI-generated content. Reference it from your project's entry file alongside `core-rules.md`. When a client profile (see [`client-profiles.md`](./client-profiles.md)) is stricter, the client profile wins. Companion: [`agent-workflow.md`](./agent-workflow.md) (how to work).*

**Owner:** *(your company)* — Engineering · **Version:** 1.2 · **Last reviewed:** 2026-08-04 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the content checklist to run on every deliverable

Run this **after** the `core-rules.md` TL;DR (secrets, data, correctness, licensing, provenance, actions, compliance). These add the content-specific checks; full detail follows in §§1–5.

1. **Grounding:** every factual claim, number, and quote is traceable to a real source — nothing invented.
2. **Citations:** sources are real, current, and verifiable; attribution is accurate.
3. **Confidentiality:** client documents and data stay inside the approved workspace; nothing regulated or proprietary leaks.
4. **Fidelity:** the client's or author's meaning, voice, and framing are preserved — no injected claims or positions.
5. **Accessible documents:** headings, alt text, plain language, and sufficient contrast in what you produce.

If any answer is "no" or "unsure," fix it or flag it before presenting. Scale the depth to the blast radius (see `core-rules.md`): a small wording fix needs a quick pass; anything that asserts facts, cites sources, or restates client positions needs the full check, stated in your hand-off.

---

## 1. Factual grounding and no fabrication

- **Ground every factual claim.** Assert facts, figures, dates, names, and quotes only when they trace to a real source you can point to — the provided material, an authoritative reference, or the client's own documents. This is the content form of `core-rules.md` §2.
- **Never invent a statistic, quote, event, or attribution.** A plausible-sounding number with no source is worse than an acknowledged gap. If you don't have the figure, say so and leave a marked placeholder rather than filling it in.
- **Quote accurately.** Reproduce quotations verbatim from the source; don't paraphrase inside quotation marks, and don't attribute a paraphrase as a direct quote.
- **Distinguish what the source says from what you infer.** Mark analysis, extrapolation, and opinion as such; don't present your inference as established fact.
- **Flag uncertainty explicitly.** When a claim is unverified, out of date, or contested, say so in the text or in your hand-off — don't smooth it over into false confidence.

## 2. Citation and source integrity

- **Cite real, verifiable sources.** Don't fabricate references, URLs, DOIs, page numbers, or author names. If you cannot verify a citation, do not present it as verified — flag it for checking.
- **Prefer primary and current sources.** Check that a source is authoritative for the claim and current enough to still hold; note the date where currency matters.
- **Attribute honestly.** Credit the origin of facts, ideas, and figures; don't present sourced material as original or original material as sourced.
- **Match the project's citation convention** (footnotes, inline links, a references section) rather than imposing your own.
- **Don't launder licensed or copyrighted text** into a deliverable without attribution and a license check — see `core-rules.md` §3.
- **For how to verify a source or claim before citing it** — when to search, how many sources, handling disagreement, staleness — see `core-rules.md` §9.

## 3. Confidentiality of client documents and data

- **Keep client documents inside the approved workspace.** Don't send drafts, source documents, research inputs, or excerpts to external tools or endpoints unless the task explicitly and legitimately requires it and the destination is approved (see `core-rules.md` §1, §5).
- **Minimize regulated and sensitive content.** Don't reproduce PII, health, education, or financial records into deliverables, examples, or summaries beyond what the task genuinely needs — `core-rules.md` §1 governs the synthetic-data and non-exposure rules; apply them to produced content too.
- **Watch for over-disclosure in aggregation.** A summary or dataset that combines several sources can expose more than any one did — check that the combined output doesn't reveal something confidential.
- **Respect handling and retention rules** the client sets for their documents; don't copy sensitive material to convenient-but-unapproved locations.

## 4. Voice, tone, and framing fidelity

- **Preserve the author's or client's meaning.** When editing or summarizing, keep the intended message, scope, and emphasis; don't quietly change what a document claims or commits to.
- **Don't inject positions.** Don't add opinions, recommendations, promises, or claims the client hasn't made — especially in anything that speaks for the client (public statements, policy, correspondence).
- **Match the established voice and register.** Follow the client's style guide, terminology, and tone where one exists rather than imposing your own.
- **Preserve hedging and precision.** Don't strengthen "may" into "will," "some" into "all," or a qualified estimate into a firm figure; those distinctions are often deliberate and sometimes legally load-bearing.
- **Treat each hedge in a sentence as a separate claim, not a redundant pair.** A permission hedge ("may retain") and a ceiling hedge ("for up to 7 years") aren't restating the same limit — the first says whether the thing happens is discretionary, the second caps how long it lasts if it does. "The registrar retains records for up to 7 years" (dropping "may") reads as a promise the source didn't make, even though "up to" survived. When an editing request asks you to tighten or punch up a sentence, compress the wording, not the number of distinct hedges — if you can't preserve both without a run-on, flag the tension instead of silently picking one to cut.
- **Flag, don't silently resolve, substantive ambiguity** in what the client means — see `core-rules.md` §7 and `agent-workflow.md` §2.

## 5. Accessible documents

When you produce documents, pages, or other content artifacts, make them accessible by default (the ADA Title II baseline is WCAG 2.1 AA; prefer WCAG 2.2 where the client has adopted it):

- **Use a real heading structure** — proper heading levels in order, not bold text faked as headings — so the document is navigable.
- **Provide meaningful alt text** for images, charts, and diagrams; don't leave informative visuals undescribed.
- **Write in plain language** appropriate to the audience; define jargon; prefer clear structure (lists, short paragraphs, descriptive link text) over dense blocks.
- **Ensure sufficient contrast and don't rely on color alone** to convey meaning in tables, charts, or callouts.

*(For accessibility of application UI and markup — ARIA, focus states, keyboard navigation — see [`coding-rules.md`](./coding-rules.md) §4.)*

---

## Self-check before presenting content

Re-run the **TL;DR at the top of this file** (grounding, citations, confidentiality, fidelity, accessible documents) **and** the `core-rules.md` TL;DR (secrets, data, correctness, licensing, provenance, actions, compliance) — both gates apply, at the depth the blast radius warrants. For deliverables that assert facts, cite sources, or speak for the client, state in your hand-off which items you verified — especially that claims and citations trace to real sources — so the human reviewer sees the check rather than assuming it.
