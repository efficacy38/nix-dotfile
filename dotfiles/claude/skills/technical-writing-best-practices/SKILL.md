---
name: technical-writing-best-practices
description: Use when writing technical articles, tutorials, or documentation. Covers concept ordering, section structure, and active learning techniques.
---

# Technical Writing Best Practices

## The Problem

When writing technical content, it's easy to accidentally use concepts before defining them, creating a confusing reading experience where readers encounter undefined terminology.

**Symptoms of this problem:**
- Readers feel overwhelmed by terminology
- The article feels "disjointed" or hard to follow
- Concepts seem to explain themselves in circles

## The Rule: Define Before Use

Every concept must be formally defined before it's used in explanations.

## Practical Application

### Step 1: Identify All Concepts

Before writing, list all technical terms that will appear:
- Core terms (e.g., KDC, TGT, Ticket, Principal)
- Acronyms (e.g., SSO, LDAP, MITM)
- Protocol-specific jargon

### Step 2: Determine Dependency Order

Map which concepts depend on others:
```
TGT requires understanding of:
  - Ticket (what TGT is a special case of)
  - KDC (who issues TGT)
  - Principal (who receives TGT)
```

### Step 3: Structure Content Accordingly

**Recommended order:**
1. **Intuition/Analogy** - Build mental model without jargon
2. **Background/History** - Why this technology exists
3. **Core Concepts** - Define all terms formally
4. **Concept-to-Analogy Mapping** - Connect back to intuition
5. **Details** - Now safe to use all defined terms freely
6. **Advanced Topics** - Build on established foundation

### Step 4: Validate

Read through and check: "At this point in the article, has every term I'm using been defined?"

## Example: Kerberos Article

**Before (problematic):**
```
## Amusement Park Analogy
...service center gives you a TGT (Ticket Granting Ticket)...
[TGT used but not yet defined!]

## History
...

## LDAP Relationship
...Kerberos issues TGT for authentication...
[Still using TGT without formal definition]

## Core Concepts
### TGT
TGT is... [Finally defined, but too late]
```

**After (correct):**
```
## Amusement Park Analogy
...service center gives you a "wristband"...
[Pure analogy, no Kerberos terms]

## History
...

## Core Concepts
### TGT
TGT is a special Ticket that... [Formally defined]

## Analogy Mapping Table
| Amusement Park | Kerberos |
| Wristband | TGT |
[Now readers can connect analogy to formal terms]

## LDAP Relationship
...Kerberos issues TGT... [Safe to use - already defined]
```

## Checklist

When writing technical content:

- [ ] List all technical terms before writing
- [ ] Map concept dependencies
- [ ] Keep analogies pure (no mixing with jargon)
- [ ] Define core concepts early in the article
- [ ] Add a mapping table if using analogies
- [ ] Review: every term usage comes after its definition

## Anti-patterns to Avoid

1. **Premature jargon in analogies**: Using technical terms in "simple" examples
2. **Forward references**: "We'll explain TGT later" - readers need it now
3. **Circular definitions**: Defining A using B, then B using A
4. **Assumed knowledge**: Using acronyms without expansion on first use

---

## Part 2: Section Structure - Keep Related Content Together

### The Problem

When explaining multi-step processes (like protocols), separating "overview" from "details" forces readers to scroll back and forth, losing context.

**Symptoms:**
- Reader says content feels "overwhelming" or "disconnected"
- Long scroll distances between related information
- Reader loses track of which step they're reading about

### The Rule: Group by Logical Unit, Not by Content Type

Instead of organizing by content type (all overviews together, all details together), organize by logical unit (each unit contains its overview AND details).

### Example: Protocol Documentation

**Before (problematic):**
```
### Message Exchange Flow
  #### Phase 1: AS Exchange (overview)
  #### Phase 2: TGS Exchange (overview)
  #### Phase 3: AP Exchange (overview)
### AS Exchange Message Format (details)
### TGS Exchange Message Format (details)
### AP Exchange Message Format (details)
```

Reader thinking: "I'm reading about AS-REQ format... wait, what was the purpose of AS Exchange again?" *scrolls up*

**After (correct):**
```
### AS Exchange: Get TGT with Password
  (flow diagram + message table)
  #### AS-REQ format
  #### AS-REP format

### TGS Exchange: Get Service Ticket with TGT
  (flow diagram + message table)
  #### TGS-REQ format
  #### TGS-REP format

### AP Exchange: Authenticate to Service
  (flow diagram + message table)
  #### AP-REQ format
  #### AP-REP format
```

Each section is self-contained. Reader can understand one phase completely before moving on.

### When to Apply

- Protocol explanations (request/response pairs)
- Multi-step processes (each step = one section)
- API documentation (each endpoint = overview + examples + errors)

---

## Part 3: Active Learning with Thought Questions

### The Problem

Passive reading leads to shallow understanding. Readers may feel they understand while reading, but can't apply the knowledge later.

**Symptoms:**
- Reader finishes article but can't answer basic questions
- Confusion about similar concepts (e.g., "What's the difference between X and Y?")
- Misunderstanding edge cases or security implications

### The Solution: Add Thought Questions

At the end of each major section, add questions that:
1. Target common confusion points
2. Let readers self-assess understanding
3. Use collapsible answers (`<details>`) for self-paced learning

### Question Design Principles

**Good questions target:**
- Differences between similar concepts ("TGT vs Service Ticket")
- "Why" questions about design decisions ("Why not just send the password?")
- Security implications ("What if X is stolen?")
- Edge cases ("What if the attacker replays immediately?")

**Bad questions:**
- Recall questions with obvious answers ("What does KDC stand for?")
- Questions answered in the previous paragraph
- Questions requiring external knowledge

### Format

```markdown
#### 思考題

<details>
<summary>Q1：[Question that targets a common confusion point]</summary>

[Structured answer with examples if helpful]

</details>

<details>
<summary>Q2：[Question about design rationale or security]</summary>

[Answer explaining the "why"]

</details>
```

### Example Questions by Topic

**For authentication protocols:**
- "Why can't the attacker use the stolen ticket/token?"
- "What's the difference between [credential A] and [credential B]?"
- "Why does [component X] need to exist? Can't we skip it?"

**For encryption/security:**
- "Why is [data] encrypted with [key A] instead of [key B]?"
- "What can an attacker do if they obtain [component X]?"
- "Why are there two encrypted parts in this message?"

**For system design:**
- "Why is this centralized/distributed?"
- "What are the tradeoffs of this design?"
- "What happens if [component] fails?"

### Placement

Place thought questions at the **end of each major section**, not at the end of the article. This:
- Reinforces learning while context is fresh
- Breaks up long content into digestible chunks
- Gives natural pause points for readers

---

## Part 4: Reader Review - Validate with a Naive Reader

### The Problem

As the author, you're too close to the material. You understand the concepts deeply, which makes it hard to spot gaps in explanation that would confuse a newcomer.

**Symptoms:**
- Readers ask questions you thought were obvious
- Implicit assumptions that experts make but beginners don't share
- Logical jumps that feel natural to you but confuse others

### The Solution: Spawn a Naive Reader Subagent

After completing your article, use the Task tool to spawn a subagent that role-plays as a reader who knows **nothing** about the topic. This reader will identify:

1. **Unclear concepts** - Terms or ideas that need more explanation
2. **Missing context** - Background knowledge the author assumed
3. **Logical gaps** - Steps or connections that aren't explicit

### Workflow

After finishing the article:

```
1. Spawn a subagent with the "naive reader" prompt (see below)
2. The subagent reads the article and reports confusion points
3. For each confusion point, either:
   - Add clarification directly to the article
   - Add a thought question (思考題) to prompt deeper thinking
4. Repeat if major changes were made
```

### Subagent Prompt Template

Use this prompt when spawning the reader review subagent:

```
You are a reader who knows NOTHING about [TOPIC]. You have general intelligence
but zero domain knowledge about this subject.

Read the following article and identify:
1. Terms or concepts that are used but not clearly explained
2. Logical jumps where you feel lost ("how did we get from A to B?")
3. Assumptions the author seems to make about your prior knowledge
4. Sections where you understand the words but not the meaning

For each issue, explain:
- Where in the article the confusion occurs
- What specifically is unclear
- What question you would ask the author

Be honest about confusion. Don't pretend to understand. If something feels
vague or hand-wavy, say so.

Article to review:
[PASTE ARTICLE CONTENT]
```

### Handling Feedback

| Feedback Type | Action |
|---------------|--------|
| Missing definition | Add definition before first use |
| Unclear explanation | Expand with example or analogy |
| Logical gap | Add transitional explanation |
| Assumed knowledge | Add background section or link |
| Edge case question | Add as 思考題 with answer |

### Example

**Subagent feedback:**
> "In the section about TGS Exchange, you mention 'session key' but I don't
> understand what makes it different from a regular encryption key or why
> it's called 'session' key."

**Resolution options:**

1. **Add clarification:**
   ```markdown
   Session Key（會話金鑰）是一個臨時的加密金鑰，只在這次「會話」
   （session）期間有效。與長期金鑰不同，session key 用完即丟，
   降低了金鑰洩露的風險。
   ```

2. **Add as thought question:**
   ```markdown
   <details>
   <summary>Q：為什麼要用 Session Key 而不是直接用長期金鑰？</summary>

   長期金鑰（如使用者密碼衍生的金鑰）如果頻繁使用，被竊取的風險較高。
   Session Key 是臨時產生的，即使被竊取也只影響單次會話，大幅降低安全風險。

   </details>
   ```

---

## Part 5: Series Articles and Prerequisites

### The Problem

When writing articles that are part of a series, readers may land on an advanced article without having read the prerequisites, leading to confusion.

**Symptoms:**
- Readers ask questions that were answered in previous articles
- Confusion about basic terminology that the series assumes known
- Readers struggle because they lack foundational knowledge

### The Solution: Explicit Prerequisites Block

At the start of every series article, add a prerequisite notice:

```markdown
:::note
**前置閱讀**

本文假設你已經讀過系列的前幾篇文章，特別是：
- [Previous Article Title](/posts/previous-article-slug)——理解 X 和 Y 概念

如果你不熟悉 Z，建議先閱讀上述文章。本文會使用「Term A」、「Term B」等術語。
:::
```

### What to Include

1. **Required reading**: Link to essential previous articles
2. **Key concepts**: List what concepts are assumed known
3. **Terminology warning**: Mention specific terms that won't be re-explained

### Example

From a FreeIPA certificate management article (part 4 of a Kerberos series):

```markdown
:::note
**前置閱讀**

本文假設你已經讀過系列的前幾篇文章，特別是：
- [FreeIPA 實戰：部署企業級 Kerberos 環境](/posts/freeipa-kerberos-deployment)——理解 FreeIPA 架構和 Kerberos Principal

如果你不熟悉 Kerberos，建議先閱讀上述文章。本文會使用「Principal」、「keytab」等 Kerberos 術語。
:::
```

---

## Part 6: Bilingual Terminology Handling

### The Problem

When writing technical content in Chinese (or other non-English languages), mixing English technical terms with the local language can create readability issues if not done consistently.

**Symptoms:**
- Inconsistent use of English vs translated terms
- Poor readability due to missing spaces around English terms
- Reader confusion about whether two terms refer to the same concept

### The Rule: Decide Early, Apply Consistently

Before writing, decide your terminology strategy:

| Strategy | When to Use | Example |
|----------|-------------|---------|
| All Chinese | Audience prefers native terms | 憑證、私鑰、公鑰 |
| All English | Technical audience, industry standard terms | certificate, private key |
| Mixed (recommended) | Bilingual audience, core terms in English | Certificate 是一份「數位身份證」 |

### Mixed Strategy Guidelines

For the mixed approach (English core terms, Chinese explanations):

1. **First occurrence**: `**English Term**（中文解釋）` or `**English Term** 是...`
2. **Subsequent occurrences**: Just the English term
3. **Always add spaces** around English terms in Chinese text

**Spacing rules:**
```markdown
✅ 當你申請 certificate 時，CA 會驗證你的身份
❌ 當你申請certificate時，CA會驗證你的身份

✅ 這個 private key 必須保密
❌ 這個private key必須保密
```

### Glossary Table

For articles with many technical terms, add a quick reference table early:

```markdown
### 常見術語速查

| 術語 | 說明 |
|---|---|
| TLS | Transport Layer Security，HTTPS 使用的加密協議 |
| Private Key | 必須保密的密鑰，用於解密和簽章 |
| Public Key | 可公開的密鑰，用於加密和驗證簽章 |
| Certificate | 包含 public key 和身份資訊的數位文件 |
| CA | Certificate Authority，簽發 certificate 的機構 |
```

### Example Progression

**First mention (with explanation):**
```markdown
**Certificate** 是一份「數位身份證」，包含擁有者的身份資訊和 public key。
```

**Subsequent mentions (term only):**
```markdown
當你連接到 HTTPS 網站時，伺服器會出示 certificate。
```

---

## Complete Checklist

When writing technical content:

**Concept Ordering:**
- [ ] List all technical terms before writing
- [ ] Map concept dependencies
- [ ] Keep analogies pure (no mixing with jargon)
- [ ] Define core concepts early in the article
- [ ] Add a mapping table if using analogies
- [ ] Review: every term usage comes after its definition

**Section Structure:**
- [ ] Group related content together (overview + details in same section)
- [ ] Each section is self-contained and can be understood independently
- [ ] Reader doesn't need to scroll back to understand current section

**Active Learning:**
- [ ] Add 2-4 thought questions at the end of each major section
- [ ] Questions target common confusion points, not recall
- [ ] Answers are in collapsible `<details>` blocks
- [ ] Questions cover "why" and "what if" scenarios

**Reader Review:**
- [ ] Spawn naive reader subagent after completing the article
- [ ] Address all confusion points identified
- [ ] Add clarifications or thought questions as appropriate
- [ ] Re-review if major changes were made

**Series Articles:**
- [ ] Add prerequisite notice at the start (:::note block)
- [ ] Link to required previous articles
- [ ] List assumed knowledge and terminology

**Bilingual Terminology:**
- [ ] Decide terminology strategy (Chinese/English/Mixed)
- [ ] First mention: term with explanation
- [ ] Subsequent mentions: term only
- [ ] Add spaces around English terms in Chinese text
- [ ] Consider adding a glossary table for many terms
