# AI Writing Rules for Content Agents

*Rules for producing or editing written deliverables — documents, research, analysis, technical documentation — with §§1–6 below the whole scope. **Read [`core-rules.md`](./core-rules.md) first:** it holds the task-agnostic base that binds on every task; this file adds only the content rules on top of it. **Documentation about code** — READMEs, API references, runbooks, release notes — is a written deliverable, so it is governed here, and by `coding-rules.md` only when you also change code. Where a client profile (see [`client-profiles.md`](./client-profiles.md)) is stricter, it wins. Companions: [`writing-patterns.md`](./writing-patterns.md) (writing craft) and [`agent-workflow.md`](./agent-workflow.md) (how to work).*

**Version:** 1.6 · **Last reviewed:** 2026-08-15 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the content checklist to run on every deliverable

Run this **after** the `core-rules.md` TL;DR. Full detail in §§1–6.

1. **Grounding:** every factual claim, number, and quote is traceable to a real source — nothing invented.
2. **Citations:** sources are real, current, and verifiable; attribution is accurate.
3. **Confidentiality:** client documents and data stay inside the approved workspace; nothing regulated or proprietary leaks.
4. **Fidelity:** the client's or author's meaning, voice, and framing are preserved — no injected claims or positions.
5. **Accessible documents:** headings, alt text, plain language, and sufficient contrast in what you produce.
6. **Verified documentation:** every command, snippet, and API call you document was actually run — or is labelled unverified.

Any "no" or "unsure": fix or flag it before presenting. Scale depth to the blast radius (`core-rules.md`) — a small wording fix needs a quick pass; anything asserting facts, citing sources, or restating client positions needs the full check, stated in your hand-off.

---

## 1. Factual grounding and no fabrication

- **Ground every factual claim.** Assert facts, figures, dates, names, and quotes only when they trace to a real source you can point to — the provided material, an authoritative reference, or the client's own documents (the content form of `core-rules.md` §2).
- **Never invent a statistic, quote, event, or attribution.** A plausible-sounding number with no source is worse than an acknowledged gap: say you don't have it and leave a marked placeholder.
- **Quote accurately.** Verbatim from the source; don't paraphrase inside quotation marks, and don't attribute a paraphrase as a direct quote.
- **Distinguish what the source says from what you infer.** Mark analysis, extrapolation, and opinion as such; don't present inference as established fact.
- **Flag uncertainty explicitly.** When a claim is unverified, out of date, or contested, say so in the text or your hand-off — don't smooth it into false confidence.

## 2. Citation and source integrity

- **Cite real, verifiable sources.** Don't fabricate references, URLs, DOIs, page numbers, or author names. If you cannot verify a citation, flag it for checking rather than presenting it as verified.
- **Prefer primary and current sources.** Check that a source is authoritative for the claim and current enough to still hold; note the date where currency matters.
- **Attribute honestly.** Credit the origin of facts, ideas, and figures; don't present sourced material as original or original material as sourced.
- **Match the project's citation convention** (footnotes, inline links, a references section) rather than imposing your own.
- **Don't launder licensed or copyrighted text** into a deliverable without attribution and a license check (`core-rules.md` §3). How to verify a source or claim before citing it — when to search, how many sources, handling disagreement, staleness — is `core-rules.md` §9.

## 3. Confidentiality of client documents and data

- **Keep client documents inside the approved workspace.** Don't send drafts, source documents, research inputs, or excerpts to external tools or endpoints unless the task explicitly and legitimately requires it and the destination is approved (`core-rules.md` §1, §5).
- **Minimize regulated and sensitive content.** Don't reproduce PII, health, education, or financial records into deliverables, examples, or summaries beyond what the task genuinely needs; `core-rules.md` §1's synthetic-data and non-exposure rules apply to produced content too.
- **Watch for over-disclosure in aggregation.** A summary or dataset combining several sources can expose more than any one did — check that the combined output doesn't reveal something confidential.
- **Respect the client's handling and retention rules** for their documents; don't copy sensitive material to convenient-but-unapproved locations.

## 4. Voice, tone, and framing fidelity

- **Preserve the author's or client's meaning.** When editing or summarizing, keep the intended message, scope, and emphasis; don't quietly change what a document claims or commits to.
- **Don't inject positions.** No opinions, recommendations, promises, or claims the client hasn't made — especially in anything that speaks for the client (public statements, policy, correspondence).
- **Match the established voice and register.** Follow the client's style guide, terminology, and tone where one exists rather than imposing your own.
- **Preserve hedging and precision.** Don't strengthen "may" into "will," "some" into "all," or a qualified estimate into a firm figure; those distinctions are often deliberate and sometimes legally load-bearing.
- **Treat each hedge in a sentence as a separate claim, not a redundant pair.** A permission hedge ("may retain") and a ceiling hedge ("for up to 7 years") aren't restating the same limit — the first says whether the thing happens is discretionary, the second caps how long it lasts if it does. "The registrar retains records for up to 7 years" (dropping "may") reads as a promise the source didn't make, even though "up to" survived. When an editing request asks you to tighten or punch up a sentence, compress the wording, not the number of distinct hedges — if you can't preserve both without a run-on, flag the tension instead of silently picking one to cut.
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

- **Run every example before you ship it.** Commands, snippets, config fragments, and API calls in documentation are claims about behavior — verify them the way `coding-rules.md` §3 requires of tests: actually execute the command, compile the snippet, hit the endpoint. `core-rules.md` §2 forbids inventing a flag or config key; this goes further — a *real* flag in an unrun example is still an unverified claim, failing the way a fabricated citation does. If you cannot run it, say so in the document or your hand-off rather than presenting it as working.
- **Running it once doesn't license the generalization you write about it.** Verify the form you ship, not a neighbour of it. Suppose you ran a filtered-test invocation once, with a `--` separator before the filter flag, and it worked: that establishes *that* invocation, not that the separator is **required** — which is a claim about the runs you didn't make. Write it anyway and you have documented a rule you never tested — often one your own transcript already contradicts, which is the failure mode §1 calls presenting inference as established fact. When a sentence claims more than the run does — *always*, *required*, *only*, *any* — either run the variant that proves it or narrow the sentence to what you actually observed.

*(The rest of what documentation owes its reader — audience and document type, showing what success looks like, the *why*, per-type completeness, keeping docs true as behavior changes — is **craft**, in [`writing-patterns.md`](./writing-patterns.md) §4. This file governs risk; that one quality.)*

---

## Self-check before presenting content

Re-run this file's **TL;DR** **and** the `core-rules.md` TL;DR — both gates apply, at the depth the blast radius warrants. For deliverables that assert facts, cite sources, or speak for the client, state in your hand-off which items you verified, especially that claims and citations trace to real sources, so the human reviewer sees the check rather than assuming it.
