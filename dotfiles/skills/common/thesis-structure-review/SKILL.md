---
name: thesis-structure-review
description: Use when reviewing or rewriting a thesis or dissertation for chapter order, section boundaries, academic narrative flow, concept ordering, related work synthesis, top-down architecture explanation, or Chinese thesis wording consistency.
---

# Thesis Structure Review

Use this skill when turning a thesis draft into something a professor can follow quickly.

## Goal

- Make the chapter flow easy to follow.
- Keep each chapter responsible for one clear job.
- Make the problem statement academically defensible.
- Keep terminology, evidence, and chapter boundaries consistent.

## Default Chapter Order

Use this order unless the topic clearly needs a different one:

1. Introduction
2. Related Work
3. Background
4. Design Requirement
5. Approach
6. Experiment
7. Evaluation
8. Conclusion
9. Future Work

`Background` may move before `Related Work` if the reader needs technical foundations first.

## Master Checklist

Before rewriting, check:

- Does each chapter have one clear job?
- Does the introduction convince the reader the problem is real?
- Are background concepts defined before they are used?
- Are thesis-specific terms delayed until the reader can understand them?
- Does related work synthesize by theme instead of summarizing papers one by one?
- Does the system explanation start from the highest-level flow?
- Does the thesis use concrete evidence where it makes strong claims?
- Are conclusion and future work short, distinct, and modest?

## Chapter Checklist

### Introduction

- Keep it to `background`, `motivation`, `objective`, and optionally `thesis structure`.
- Do not front-load internal data model terms, code names, or implementation details.
- Show why the problem matters with real workload or operational evidence when possible.
- If there is a system overview figure, keep it high-level and top-down.
- For email or cross-system diagnosis theses, separate message flow, external factors, and observable evidence. Do not put paths, configuration, policies, diagnostic text, and local state into one flat list.
- If protocol states are insufficient, do not imply that free-form diagnostic text fully solves the problem. Explain that bounce or diagnostic text often provides only an externally visible symptom summary, not verified root cause.

### Related Work

- Group papers by theme, method family, or research question.
- State what each group of papers solves.
- State what each group does not solve for this thesis context.
- End with a clear research gap or positioning statement.
- Avoid turning the chapter into a sequence of paper summaries.

### Background

- Explain prerequisite technical concepts only.
- Do not mix in “how this thesis uses it” unless absolutely necessary.
- Prefer definitions, protocol context, and terminology alignment.

### Design Requirement

- State the design properties the system must satisfy.
- Tie each requirement to real data, workflow pain, or operational constraints.
- Avoid drifting into implementation details.

### Approach

- Start from top-level data flow and component responsibilities.
- Only then descend into internal representations, rules, and algorithms.
- Define thesis-specific abstractions where they first become necessary.
- Keep one reader-facing name per concept across the whole thesis.

### Experiment

- Put datasets, corpora, fixtures, setup, workload observations, and validation protocol here.
- Explain what was observed, what was measured, and what was tested.
- Avoid interpreting results too heavily in this chapter.

### Evaluation

- Put findings, interpretation, tradeoffs, and limitations here.
- Do not claim evaluation is complete if it is still preliminary.
- If evaluation is incomplete, describe current capability and future evaluation direction in neutral language.

### Conclusion

- Keep it short and retrospective.
- Summarize contribution, not implementation inventory.

### Future Work

- Keep it concrete.
- Prefer 2-4 realistic extensions over a long wish list.

## Structure Checklist

- Move technical explanation into `Background`.
- Move thesis-specific constraints into `Design Requirement`.
- Put architecture, methods, and implementation choices into `Approach`.
- Put validation setup and corpora into `Experiment`.
- Put interpretation and limitations into `Evaluation`.
- Remove implementation trivia that does not strengthen the academic argument, such as code line counts, repo layout, or framework inventories.

## Concept Ordering Checklist

- List the core terms, acronyms, and thesis-specific abstractions first.
- Map prerequisite concepts before derived concepts.
- Define concepts before using them.
- Avoid forward references that say a needed term will be defined later.
- Avoid circular explanations where concept A depends on concept B and concept B depends on concept A.
- Keep the current point of view explicit: reader, operator, component, or process stage.
- For paper drafts, do not let a figure, table, research question, abstract, or contribution paragraph introduce a thesis-specific object before the body has given the reader a local definition.
- In the introduction, prefer reader-facing functional names over implementation-native object names. Formal object names can appear later in background, architecture, approach, or methodology after the need for them is established.
- For systems and log-analysis theses, use this dependency order unless the paper has a stronger reason to differ:
  problem domain -> observable evidence -> evidence representation -> parser/template output -> higher-level grouping -> lifecycle/workflow interpretation -> evaluation claim -> explicit limitation.
- When a later chapter needs a coined term, first define its parent concept. For example, define "diagnostic observation" before defining an attempt-level observation object, and define "diagnostic group" before defining a specific grouping implementation.
- Design-goal tables, overview figures, abstracts, and contribution lists must follow the same rule. If a formal implementation object has not yet been defined, use a reader-facing functional label first, such as "mail event", "delivery attempt", "diagnostic observation group", "final lifecycle result", or their Chinese equivalents.
- Do not let a traceability table introduce internal object names before the prose has explained why those layers exist. The table may point to the layer's function first and mention formal names only after the local definition.

## Terminology Checklist

- Keep one reader-facing term for each core concept across the thesis.
- If the same concept appears as `symptom group`, `error group`, and `cluster`, unify it unless the distinction is deliberate and explicitly defined.
- Prefer functional names over implementation-native names.
- Validate coined terms from a professor or first-time reader perspective.
- If a term is not self-explanatory, rename it or define it before relying on it.
- Distinguish overloaded words such as `incident`, `event`, `group`, and `correlation` if they operate at different layers.

## Evidence Checklist

- Add operational counts, workload estimates, corpus sizes, or error distributions when available.
- Answer “why not inspect logs manually?” with real scale or instability evidence when relevant.
- Explain what each number means in reader-facing terms.
- Do not rely on internal labels such as `signatures`, `handlers`, or `cache keys` unless they are defined and necessary.
- If a number cannot be traced back confidently, or the author no longer trusts it, remove it or soften it.
- When using evidence from mail systems, distinguish protocol status, remote diagnostic wording, local queue lifecycle, authentication evidence, filtering evidence, and forwarding path. Merge overlapping labels instead of listing the same diagnostic signal under several names.
- When an external service provider does not reveal a filtering reason, use conservative wording. It is acceptable to say the provider may avoid exposing anti-abuse rules or may combine several internal signals, but do not state those internal motives as verified facts.
- Prefer “this design follows from observed workload” over “this design is reasonable.”
- Every evaluation number should state its unit, denominator, source, and precision. For example, distinguish raw log documents, delivery attempts, events, unique message-recipient pairs, database rows, and UI rows.
- If a denominator comes from an approximate method, such as cardinality aggregation, mark the result as approximate wherever the number is reused, including the abstract, evaluation, and conclusion.
- When a table reports a status distribution, define the status labels before the table. The definitions should be mutually exclusive if the table presents categories as a partition.

## Architecture Checklist

- Explain systems from top level to lower levels.
- Start with high-level data flow and component responsibilities.
- Add a system overview figure if prose alone is hard to follow.
- Use progressive disclosure: overview first, internals later.
- Keep chapter boundaries clean:
  `Background` explains prerequisites.
  `Design Requirement` explains why the system needs certain properties.
  `Approach` explains how the system satisfies them.
- Use reader-facing labels in overview figures when the formal object names have not yet been introduced. Define the formal terms in the surrounding prose before relying on them in later figures or tables.
- Keep input, transformation, output, assumptions, and failure modes close together for each pipeline stage. Do not split all overviews into one section and all details into another if that forces the reader to reconstruct the process.
- Distinguish observation, interpretation, decision, and outcome layers. A parser output, symptom group, workflow candidate, and final lifecycle result should not be treated as the same object unless the thesis explicitly proves that equivalence.
- Keep design-goal traceability tables, overview figures, and object-relation tables in a safe order:
  1. reader-facing system goal or data flow,
  2. local definition of formal objects,
  3. object relation or cardinality table,
  4. implementation identifiers and reproducibility details.
- High-level figures should show functional transformations, not raw code nouns. Use implementation identifiers in detailed tables or after the narrative has introduced the concept.

## Figure Design Checklist

Use this checklist when a thesis figure explains architecture, data flow, workflow, or system components.

- A figure should reduce reading effort. If the figure repeats paragraph text without clarifying grouping, flow, or boundary, rewrite the figure instead of adding more labels.
- Prefer one visual question per figure. Separate high-level data flow, administrator workflow, object relations, and evaluation setup when one figure becomes crowded.
- Use restrained grayscale or one accent color by default. Avoid assigning many colors to categories unless color is part of the argument and remains readable in grayscale printing.
- Use dashed outer frames for conceptual groups, trust boundaries, evidence families, or output groups. The group label should name the role of the group, not repeat every item inside it.
- In data-flow diagrams, use boxes for sources, processes, stores, and outputs; use arrows only for real data movement or dependency. Avoid long arrow chains when a component-style layout makes the system boundary clearer.
- Keep labels short and reader-facing. A figure can use labels such as "可觀測郵件證據", "證據整理", "診斷症狀分群", and "管理員分流結果"; move detailed implementation names to prose, tables, or appendices.
- Make visual hierarchy carry meaning: sources and outputs can share a plain style, while transformation steps can use a light fill. Do not use color merely to decorate.
- Before finalizing, check whether boxes overlap, arrows are crowded, title padding is balanced, and the figure still works when printed without color.

## Implementation Screenshot Checklist

Use this checklist when a thesis includes screenshots from a real implementation.

- Put implementation screenshots in the implementation, system realization, or user workflow chapter. Do not use screenshots as the first explanation of the architecture; use architecture diagrams for that.
- Each screenshot must answer one concrete question for the reader, such as how diagnostic groups are shown, how lifecycle summaries appear, how a daily report candidate is presented, or where an administrator opens evidence.
- Capture the part of the interface that supports the prose. If the screenshot only shows filters, navigation, a trend header, or an empty table while the paragraph discusses grouped cases, recapture the screen after scrolling or selecting the relevant state.
- Treat screenshots as evidence with privacy risk. Before adding them to a thesis, check for personal email addresses, full Message-ID values, queue IDs, raw NDR text, hostnames that should not be public, and other identifying context.
- State the masking scope precisely in the caption. For example, write "已遮蔽個人郵件位址" when only email addresses are masked; do not write "已去識別化" unless all identifying fields in the screenshot have actually been removed or generalized.
- Preserve useful operational context when needed. It is acceptable to keep category names, counts, lifecycle labels, and non-sensitive domain-level context if they are needed to support the thesis claim.
- After inserting screenshots, run the thesis build and inspect at least the generated figure list or labels. If possible, visually inspect the image file to ensure it is not blank, clipped, or showing the wrong page state.

## Functional Architecture And Implementation Split Checklist

Use this checklist when a thesis has both a high-level system architecture chapter and a lower-level implementation chapter.

The architecture chapter should explain the system from the reader's functional point of view. It should answer:

- What operational problem the system handles.
- What capabilities the system provides.
- How evidence flows through the main functional layers.
- Which distinctions the architecture preserves, such as observation, interpretation, grouping, lifecycle outcome, and workflow candidate.
- Which claims are intentionally out of scope, especially unverified root cause, administrator action outcomes, or external-provider internal policy.

The architecture chapter should avoid implementation inventory. Move these details to the implementation chapter unless the architecture argument truly depends on them:

- ETL job details.
- OpenSearch, database, table, endpoint, or service names.
- Configuration paths.
- Model version strings.
- Exact export scripts and output paths.
- API response fields.
- Code identifiers such as `mailEvent`, `deliveryAttempt`, `patternGroupObservation`, `patternGroup`, and `finalOutcome`.

The implementation chapter should explain how the architecture is realized. It is the right place for:

- Data sources and ETL flow.
- Normalization, masking, and anonymization boundaries.
- Exact implementation object names and their reader-facing meanings.
- Parser or model versions.
- Rule configuration sources.
- API, UI, report generation, and evaluation export mechanics.
- Evidence preservation details such as Rspamd and Milter parsing.
- Implementation screenshots that show administrator-facing evidence views, daily-report candidates, or workflow entry points, provided their privacy scope is checked and the caption states any masking precisely.

When implementation identifiers are removed from the architecture chapter, add an early implementation section that maps reader-facing Chinese concepts to exact implementation names. A common pattern is:

- 郵件事件 -> `mailEvent`
- 投遞嘗試 -> `deliveryAttempt`
- 診斷症狀觀測 -> `patternGroupObservation`
- 診斷症狀群組 -> `patternGroup`
- 最終生命週期結果 -> `finalOutcome`

High-level architecture figures should use functional transformations, not raw code nouns. Good labels include "原始投遞證據", "事件與嘗試", "診斷文字樣板", "診斷症狀群組", and "生命週期與工作流程". Keep exact implementation names for implementation tables, appendices, or prose after local definitions.

For mail-system theses, place Rspamd and Milter consistently across chapters:

- Background: define what Milter and Rspamd are.
- Architecture: describe them as auxiliary evidence sources, not grouping engines.
- Implementation: explain how their evidence is parsed, preserved, and shown.
- Evaluation: report them as field coverage or evidence availability, not as proof of remote root cause.

## Chinese Thesis Checklist

- Prefer formal Taiwanese academic wording over direct English translation.
- Prefer Chinese when the concept can be expressed naturally in Chinese.
- Keep established technical acronyms or proper names in English when that is clearest, such as `LLM` or `RCA`.
- Do not introduce an acronym in bare form on first mention.
- Write the full name first, then the abbreviation, and only use the abbreviation alone afterward.
- Keep English only where it improves clarity.
- Rewrite generic terms such as `triage`, `log`, or `grouping` into clear Chinese when appropriate.
- When a thesis is based on code, do not let implementation object names dominate the narrative. First define the reader-facing Chinese concept, then mention the formal implementation name only when precision is needed.
- If an implementation name becomes a thesis concept, give it one stable Chinese name and use that name in prose. Mention the code identifier only at the definition point, in reproducibility details, in exported table headers, or in appendices that intentionally mirror implementation output. For example, use "診斷症狀群組" in Chinese prose and reserve `patternGroup` for exact implementation alignment.
- Keep protocol names, product names, paper names, and stable identifiers in English when needed, but explain their role in Chinese. Examples: SMTP, DSN, NDR, Postfix, Drain, OpenSearch, Message-ID, queue ID.
- Translate generic status values, labels, and operational outcomes into Chinese in prose and figures. For example, use "送達、暫緩、退信、逾期、已恢復、失敗、等待中" instead of `sent`, `deferred`, `bounced`, `expired`, `recovered`, `failed`, and `pending` unless quoting a field value.
- Use monospace only for paths, exact field names, table names, configuration keys, command names, or literal identifiers. Do not use monospace for thesis concepts such as a diagnostic group, lifecycle result, or administrator workflow unless the exact implementation symbol is being discussed.
- When a paragraph contains many English tokens, separate them into three classes before rewriting: established technical names to keep, exact implementation identifiers to localize or move to tables, and generic English wording to translate.
- When explaining implementation objects and relations, do not write database-style prose as the main thesis argument. Avoid foregrounding phrases such as "one-to-zero-or-one", "current X", "final Y", or "history" unless the exact relationship is being specified in a table. First explain the academic meaning in Chinese: what distinction the model preserves, why it matters, and what limitation remains.
- In object-relation paragraphs, introduce the reader-facing Chinese concept before the formal implementation name. For example, write "某次投遞嘗試中觀測到的分群結果（formalName）" instead of making the formalName the grammatical subject of several consecutive sentences.
- Place citations near the source name, method name, or claim they support instead of accumulating all citations at the end of a Chinese sentence.
- Citation form should fit the rhetorical role. The rule is not "always use the full paper title"; the rule is that the citation must be close to the object or claim it supports, and the source should not be hidden behind vague Chinese paraphrase.
  - Author-narrative form: use when the paper itself is not the memorable object, e.g. "He 等人~\cite{...} 指出……".
  - Title-narrative form: use for a core source, a short recognizable title, or the first introduction of a source whose title is important to the argument, e.g. "\textit{Bounce in the Wild}~\cite{...} 分析……".
  - Method/system form: use when the contribution is a named method, system, or tool, e.g. "Drain~\cite{...}" or "COMET~\cite{...}".
  - Claim-support form: use when the sentence synthesizes a broader claim and the individual source names are not central, e.g. "……受到資料量與多來源關聯困難影響~\cite{...}."
  - Standard/document form: use for RFCs, official docs, and manuals, e.g. "RFC 5321~\cite{...}" or "Postfix DEBUG_README~\cite{...}".
- Avoid vague translated source labels such as "SRE 的除錯方法", "記錄檔解析評估研究", or "LLM4AIOps 綜述" when they pretend to name a source. Replace them with an author, title, method/system name, or claim-support citation depending on the sentence.
- Run a final zh-TW wording pass after structure and evidence placement are stable.

## Paragraph Checklist

- Prefer short paragraphs.
- Use 1-3 sentences per paragraph by default.
- Split long paragraphs when they mix setup, claim, and implication.
- Prefer prose over shallow bullet lists.

## Academic Paper Adaptation Checklist

Use technical-writing rules to protect the academic argument, not to turn the thesis into a tutorial.

- Keep the "define before use" rule, concept dependency ordering, logical-unit grouping, and naive-reader review workflow.
- Keep claim, evidence, and limitation near each other. A strong claim should be followed nearby by its citation, table, figure, result, or explicit boundary.
- For every research question, verify that the thesis has a matching claim, evidence source, evaluation unit, and limitation.
- Remove tutorial-only devices from the paper body: thought questions, collapsible answers, prerequisite callouts, recommendation matrices, curated resource lists, action-item endings, and teaching analogies that do not support the research claim.
- Convert tutorial-style "what should the reader do?" material into academic forms: design implication, evaluation criterion, limitation, or future work.
- Use comparison tables only when they compress evidence or definitions. If a table contains long argumentative paragraphs, rewrite it as prose.
- Use thresholds only when they are part of the evaluation design or supported by prior work. Do not invent operational thresholds only to make a paper sound actionable.
- If evidence is incomplete, state the unproven part in the same section where the claim appears. Do not hide core limitations only in the conclusion.

## Evaluation Claim Boundary Checklist

Use this checklist when a thesis reports real system data or operational evaluation.

- For each research question, verify four local items: claim, evidence object, evaluation unit, and limitation.
- If a system uses a rule as a design principle, do not phrase it as a validated human judgment unless there is a labeled dataset. For example, write "treated as possibly requiring a different first-pass inspection" instead of "has a different handling procedure" when no human-labeled handling-compatibility data exists.
- Candidate generation is not the same as actionability. If a workflow report only produces candidates, do not claim false-positive reduction, justified-rejection classification, reviewer usefulness, or administrator outcome improvement.
- If a configuration defines "important" cases, state the rule family or configuration source near the metric. Also state whether the thesis evaluates the validity of that importance definition.
- Lifecycle evaluation must separate attempt-level observations from final outcomes. A temporary diagnostic observation should not be written as a final failure unless the lifecycle evidence supports that conclusion.
- When using protocol states such as SMTP or DSN temporary failures, connect the interpretation to both the protocol semantics and the observed lifecycle data. Do not infer final delivery meaning from the first bounce alone.
- Residual, unknown, or evidence-incomplete cases are not noise to hide. Report them as part of the method boundary when they affect the claim.

## Rewrite Workflow

1. Identify overloaded or missing chapters.
2. Decide target chapter order.
3. Move misplaced content before polishing prose.
4. Reorder concepts so prerequisites appear first.
5. Unify terminology.
6. Strengthen weak claims with observed evidence.
7. Rebuild top-down transitions and architecture overview.
8. Rewrite related work into synthesis, not paper-by-paper summary.
9. Run a professor-style reader review for undefined terms, logical jumps, and weakly motivated claims.
10. Patch only the concrete blockers returned by the review.
11. Rerun a focused follow-up review that asks whether the previous blockers are fixed.
12. Do a final zh-TW wording pass.

## Professor-Style Reader Gate

Before calling a thesis revision complete, read the draft as a professor encountering the work for the first time.

- Mark every first occurrence of a core term and check whether it has already been defined.
- Check whether each chapter starts from the reader's current knowledge instead of the author's implementation memory.
- Check whether abstract, introduction, figures, and contribution paragraphs use implementation-native terms before the paper has motivated them.
- Check whether each transition answers "why does this next concept follow from the previous one?"
- Check whether each evaluation number states its counting unit and the claim it supports.
- Treat "I will define this later" as a warning. Either add a local definition, move the term later, or move the definition earlier.

## Native Reader Subagent Gate

Use this gate when the thesis has been structurally revised but still may contain author-blind spots: undefined terms, implementation-native wording, unnatural Chinese, excessive English terms, or transitions that only make sense to the author.

This gate adapts the naive-reader workflow from technical writing to Chinese thesis review. It has two roles:

- Concept reader: a generally intelligent reader who understands basic computing ideas but does not know the thesis project.
- Native academic reader: a Traditional Chinese academic reader who checks whether the prose sounds like a Chinese thesis rather than translated notes or code documentation.

Use a subagent when the user asks for a reader check, when a chapter has been heavily rewritten, or when the user says the prose still feels unnatural or overloaded with terminology. The subagent should not rewrite the whole thesis. It should report blockers that the main agent then patches.

### Subagent Prompt Template

Use this prompt shape and replace bracketed fields:

```text
You are reviewing a Traditional Chinese thesis chapter as a native academic reader.
You are generally familiar with computing systems, but you do not know this thesis project or its implementation history.

Read the provided chapter or section and report whether it is understandable without asking the author.

Check:
1. Undefined terms or implementation object names used before the reader can understand them.
2. English terms that should be translated or explained in Chinese.
3. Sentences that sound like direct translation, code documentation, or notes rather than thesis prose.
4. Logical jumps between paragraphs, figures, tables, research questions, claims, and evidence.
5. Places where citations are too far from the source name, method name, or claim they support.
6. Tables or bullet lists that should be prose because they carry argument rather than compact data.
7. Source titles paraphrased in Chinese when the formal original title should be used.
8. Implementation identifiers repeated in prose where a reader-facing Chinese term should carry the argument.

For each issue, include:
- Location or quoted short phrase.
- What a first-time reader would not understand.
- Whether the problem is conceptual, terminology, Chinese prose, evidence, or structure.
- A concrete patch direction, not a full rewrite.

Return PASS only if the section can be read as a coherent Chinese thesis section by a first-time reader.
Otherwise return NOT PASS and list blockers.

Text to review:
[PASTE CHAPTER OR SECTION]
```

### How To Handle Feedback

- Missing definition: add a local definition before first use, or move the term later.
- Implementation-native wording: define the reader-facing Chinese concept first, then mention the formal object name only when needed.
- Excessive English terms: keep protocol names, product names, paper names, and exact identifiers; translate generic statuses, labels, process names, and operational outcomes.
- Translationese: rewrite the paragraph in natural Chinese academic prose, usually by reducing noun piles and making the subject, action, evidence, and limitation explicit.
- Logical jump: add a transition sentence that explains why the next concept follows from the previous one.
- Evidence gap: move the citation, table, figure, or limitation closer to the claim.
- Table or bullet overuse: convert argumentative content into paragraphs; keep tables for compact data, mappings, or definitions.

Treat NOT PASS as blocking for the reviewed section. Patch the concrete blockers, then rerun the reader gate if the rewritten section changed substantially.

### Focused Follow-Up Gate

After a NOT PASS review, do not rerun only a broad review and assume the issue is gone. Use a focused follow-up prompt that lists the previous blockers and asks the subagent to verify only those points.

Use this pattern:

```text
Use thesis-structure-review as a strict follow-up reviewer.
Only verify whether these previously reported blockers are fixed:
1. [blocker A]
2. [blocker B]
3. [blocker C]
Do not edit. Return PASS/NOT PASS with blockers only.
```

Run final build or formatting checks after patching when the thesis source is compiled from LaTeX, Markdown, or another build system.

## Output Checklist

When applying this skill:

- State structural problems first.
- Explain the chapter mapping or rewrite direction.
- Edit the thesis directly rather than only suggesting an outline.
- If the problem statement is weak, strengthen it with evidence.
- If the architecture explanation is diffuse, reorganize it top-down and consider adding a figure.
- If the prose is hard to follow, inspect concept order and section grouping before doing sentence-level polishing.
