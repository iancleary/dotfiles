---
name: weekly-workflow-audit
description: Scan the last 7 days of work sessions and transcripts to find repeated tasks, repeated instruction patterns, and opportunities to turn ad hoc workflows into reusable skills or scheduled tasks. Use when asked to run a workflow audit, automation audit, weekly skill audit, or to analyze how Ian has been using AI and what should be automated next.
---

# Weekly Workflow Audit

Run a blunt weekly audit of recent work and answer one question: **what should stop being manual?**

## Goal

Identify:
- tasks Ian did more than once with the same shape
- instruction patterns Ian repeated across sessions
- work that should become a reusable skill
- work that should become a scheduled report or cron job

Do not make shit up. If the sample is thin, say so clearly.

## Data sources

Prefer these in order:
1. `sessions_list` for the last 7 days
2. `sessions_history` for relevant sessions when visibility allows
3. `~/.openclaw/agents/main/sessions/sessions.json`
4. relevant `~/.openclaw/agents/main/sessions/*.jsonl` transcript files when history access is restricted
5. recent `memory/YYYY-MM-DD.md` files only as supporting evidence, not as the primary source

Prefer cowork or work-oriented sessions when visible, but include main Discord work channels when that is where the work actually happened.

## Method

1. List sessions active in the last 7 days.
2. Filter to work-relevant sessions.
3. Read the transcript/history for each relevant session.
4. Extract:
   - the user ask
   - what work was done
   - any repeated phrasing or repeated setup steps
5. Group similar work into patterns.
6. Count occurrences conservatively.
7. Recommend the highest-leverage automation for each pattern.

When access restrictions block ideal data sources, fall back to direct transcript inspection and explicitly mention that limitation.

## Output format

For each pattern, report:
- **Repeated task:** short concrete description
- **Count this week:** conservative count
- **Why it repeats:** one sentence
- **Recommendation:** one of:
  - create a new skill
  - improve an existing skill
  - create a cron/scheduled report
  - create a template/checklist

Then end with:

## Top automation opportunities this week

Rank the top 3 by expected leverage. Be opinionated.

## Heuristics

### Recommend a skill when:
- the workflow has 3+ steps
- the same kind of request is being re-explained
- there is stable decision logic or a stable output shape
- the task benefits from bundled references, scripts, or templates

### Recommend a scheduled task when:
- timing matters more than conversation context
- the same report/check should happen weekly or daily
- the output is a digest, reminder, audit, or status report

### Recommend a template/checklist when:
- the work repeats but still needs human judgment
- a full skill would be overkill
- consistency matters more than automation depth

## Quality bar

A good audit:
- cites real evidence from the week
- distinguishes repeated work from one-off work
- admits when there is not enough data
- gives concrete next steps instead of vague ideas
- optimizes for leverage, not novelty
