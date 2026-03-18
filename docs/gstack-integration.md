# gstack Integration Guide

**gstack**: Garry Tan's (YC President & CEO) open-source software factory for Claude Code.

13 specialized skills that work as a complete autonomous team: CEO, Eng Manager, Designer, Staff Engineer, QA Lead, Release Engineer, and more.

---

## What Is gstack?

From Garry Tan's README:
> "I have written over 600,000 lines of production code in the last 60 days... 10,000 to 20,000 usable lines per day... as a part-time part of my day while doing all my duties as CEO of YC."

gstack is his **open source software factory** — 13 specialist skills that turn Claude Code into a virtual engineering team you actually manage.

**MIT Licensed. Free. Available now.**

---

## The 13 Skills

### Planning & Product (CEO/Founder Level)

**`/plan-ceo-review`**
- Rethink the product problem
- Find the 10-star feature hiding in a 3-star request
- Modes: Expansion, Selective Expansion, Hold Scope, Reduction
- Example: "Photo upload" → "Auto-identify product + pull specs + draft listing automatically"

**`/design-consultation`**
- Build a complete design system from scratch
- Research landscape, propose creative risks
- Generate realistic mockups of your actual product
- Writes DESIGN.md that flows through all other phases

### Architecture & Engineering (Eng Manager/Staff Engineer Level)

**`/plan-eng-review`**
- Lock in architecture and data flow
- ASCII diagrams for every flow, state machine, error path
- 14-case test matrix, 6 failure modes, 3 security concerns
- Forces hidden assumptions into the open

**`/review`**
- Find bugs that pass CI but blow up in production
- Auto-fixes obvious issues
- Flags completeness gaps
- Traces every new enum through all switch statements

**`/plan-design-review`**
- 80-item design audit with letter grades
- AI Slop detection (flags: gradient hero, icon grid, uniform radius)
- Infers your design system
- Report only — never touches code

**`/design-review`**
- Same 80-item audit as `/plan-design-review`
- Then fixes what it finds
- Atomic commits, before/after screenshots

### QA & Browser Testing (QA Lead Level)

**`/qa`**
- Opens real Chromium browser, logs in, clicks through flows
- Tests: happy path, mobile, slow connection, edge cases
- Finds bugs, fixes them with atomic commits
- Re-verifies fixes, generates regression tests
- Example: Finds preview bug on second upload, fixes it, tests it

**`/qa-only`**
- Same methodology as `/qa` but report-only
- No code changes, pure bug report

**`/browse`**
- Gives the agent real eyes
- ~100ms per command
- Full command reference: see BROWSER.md

**`/setup-browser-cookies`**
- Import cookies from your real browser (Chrome, Arc, Brave, Edge)
- Test authenticated pages with real sessions

### Release & Documentation (Release Engineer Level)

**`/ship`**
- Sync main, run tests, audit coverage
- Push, open PR
- Bootstraps test frameworks from scratch if needed
- Coverage audit with every run

**`/document-release`**
- Update all project docs automatically
- Reads every doc file, cross-references diff
- Keeps README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md in sync
- Catches stale docs automatically

### Operations & Insights (Eng Manager Level)

**`/retro`**
- Team-aware weekly retro
- Per-person breakdowns, shipping streaks, test health trends
- Growth opportunities and blockers

**`/gstack-upgrade`**
- Upgrade gstack to the latest version
- Or set `auto_upgrade: true` in ~/.gstack/config.yaml

---

## Complete Workflow Example: Photo Upload Feature

```
1. You: I want to add photo upload for sellers.
   
2. You: /plan-ceo-review
   Claude: "Photo upload is not the feature. The real job is helping 
   sellers create listings that actually sell. What if we auto-identify 
   the product, pull specs and comps from the web, and draft the listing 
   automatically? That's 10 stars. Photo upload is 3 stars."
   [8 expansion proposals, you cherry-pick 5, defer 3]

3. You: /plan-design-review
   Claude: Design Score: B | AI Slop Score: C
   "Default Bootstrap form. Gradients, icon grids, uniform radius."
   [80-item audit, infers your design system, exports DESIGN.md]
   [flags 3 AI slop patterns]

4. You: /plan-eng-review
   Claude: [ASCII architecture diagrams for every data flow]
   Upload → Classify → Enrich → Draft
   [14-case test matrix, 6 failure modes, 3 security concerns]

5. You: Approve plan. Exit plan mode.
   Claude: [Writes 2,400 lines across 11 files in ~8 minutes]
   Models, services, controllers, views, migrations, tests

6. You: /review
   Claude: [AUTO-FIXED] Orphan S3 cleanup on failed upload
           [AUTO-FIXED] Missing index on listings.status
           [ASK] Race condition on hero image selection → You: yes
   3 issues → 2 auto-fixed, 1 fixed

7. You: /qa https://staging.myapp.com
   Claude: [Opens real browser, logs in, uploads photos, clicks flows]
   Upload → classify → enrich → draft: end to end ✓
   Mobile: ✓ | Slow connection: ✓ | Bad image: ✓
   [Finds bug: preview doesn't clear on second upload — fixes it]
   Regression test generated

8. You: /ship
   Claude: Tests: 42 → 51 (+9 new)
           Coverage: 14/14 code paths (100%)
           PR: github.com/you/app/pull/42

RESULT: One feature. Seven commands. Reframed product, 80-item design audit,
architecture diagrams, 2,400 LOC, found race condition, auto-fixed 2 issues,
real-browser QA, found & fixed 1 bug, 9 new tests, regression tests.
That is not a copilot. That is a team.
```

---

## How gstack Integrates with Your Existing System

**Your Current Stack** (from iancleary/dotfiles):

```
Product Layer:
  /grill-me, /write-a-prd, /prd-to-issues, /planning, /shaping

Solution Layer:
  /solution-iterator (find best architectural approach)
  /tdd, /test-writer, /code-review, /test-writer

Development Layer:
  /ralph-codex (build & iterate), /improve-my-codebase

Optimization Layer:
  /llm-usage-researcher (optimize LLM choice)
  /autoresearch (optimize skill prompts)
```

**gstack adds:**

```
Governance & Review:
  /plan-ceo-review (product rethinking at scale)
  /plan-eng-review (architecture enforcement)
  /plan-design-review (design auditing)
  /design-consultation (design system creation)
  /review (production-bug prevention)

Real-World Verification:
  /browse (agent with real eyes)
  /qa (end-to-end testing in real browser)
  /qa-only (bug reporting)
  /setup-browser-cookies (authenticated testing)

Release & Documentation:
  /ship (atomic releases)
  /document-release (auto-sync docs)

Insights:
  /retro (team awareness, metrics)
```

---

## Integration Strategy

### Strategy 1: Side-by-Side (Recommended)

Use **gstack for governance & release**, keep your existing skills for strategy & optimization:

```
1. Strategy: Use your skills (/solution-iterator, /llm-usage-researcher)
   → Find optimal architectural approach
   
2. Planning: Use gstack (/plan-ceo-review, /plan-eng-review, /plan-design-review)
   → Rethink product, lock architecture, audit design
   
3. Implementation: Use your /ralph-codex or gstack principles
   → Build with tests, iterate to convergence
   
4. Verification: Use gstack (/qa, /review, /ship)
   → Real browser testing, production bug prevention, release
   
5. Optimization: Use your skills (/autoresearch, /improve-my-codebase)
   → Improve skills and codebase over time
```

### Strategy 2: Unified Flow

Replace your product/planning skills with gstack, keep optimization:

```
/plan-ceo-review (gstack)
  ↓
/plan-eng-review (gstack)
  ↓
/ralph-codex (your skill) or code directly
  ↓
/qa (gstack)
  ↓
/review (gstack)
  ↓
/ship (gstack)
  ↓
/autoresearch (your skill - optimize afterwards)
```

---

## Why This Matters

**Before gstack**: You have autonomous solution finding, feature building, and optimization. But you lack:
- Structured governance (CEO rethinking products)
- Architectural review (locking design decisions)
- Real browser testing (eyes on actual user experience)
- Production bug prevention (staff engineer code review)

**After adding gstack**: Your system becomes:
- ✅ Strategically sound (CEO-level rethinking)
- ✅ Architecturally solid (Eng manager enforcement)
- ✅ Visually polished (Designer auditing)
- ✅ Production-safe (Staff engineer review)
- ✅ Actually tested (Real browser QA)
- ✅ Well-documented (Auto-sync docs)
- ✅ Continuously improving (Your autoresearch + gstack retro)

---

## File Locations

```
.claude/skills/gstack/
├── SKILL.md                        # Main entry point
├── browse/                         # Browser skill
├── qa/                             # QA skill
├── ship/                           # Release skill
├── plan-ceo-review/                # Product rethinking
├── plan-eng-review/                # Architecture
├── plan-design-review/             # Design audit
├── design-consultation/            # Design system
├── design-review/                  # Design + code
├── review/                         # Code review
├── retro/                          # Weekly retro
├── document-release/               # Doc sync
├── setup-browser-cookies/          # Session mgmt
├── gstack-upgrade/                 # Self-upgrade
└── [full gstack source]
```

All linked as Claude Code skills. Available via `/` in Claude Code.

---

## Quick Start

### Use in This Project

All skills are already available. Type `/` in Claude Code and select:
- `/plan-ceo-review` — Rethink features
- `/plan-eng-review` — Lock architecture
- `/plan-design-review` — Audit design
- `/qa` — Test in real browser
- `/ship` — Release with atomic commits
- etc.

### Use in Your Projects

Add this to your project's CLAUDE.md:

```markdown
## gstack

Use /browse from gstack for all web browsing. Never use mcp__claude-in-chrome__* tools.

Available skills:
- /plan-ceo-review — Rethink the product
- /plan-eng-review — Lock architecture
- /plan-design-review — 80-item design audit
- /design-consultation — Build design system
- /design-review — Audit + fix design
- /review — Find production bugs
- /browse — Agent with real eyes
- /qa — Full QA testing in real browser
- /qa-only — Bug report without fixes
- /setup-browser-cookies — Test authenticated pages
- /ship — Atomic release
- /document-release — Keep docs in sync
- /retro — Weekly metrics & insights
- /gstack-upgrade — Update gstack

For issues: cd .claude/skills/gstack && ./setup
```

Then copy gstack into your project:

```bash
cp -Rf ~/.claude/skills/gstack .claude/skills/gstack
rm -rf .claude/skills/gstack/.git
cd .claude/skills/gstack && ./setup
```

---

## The Philosophy

**gstack is governance without overhead.**

Traditional engineering teams have:
- CEO/Founder who rethinks products → `/plan-ceo-review`
- Engineering Manager who locks architecture → `/plan-eng-review`
- Designer who audits design → `/plan-design-review`
- Staff Engineer who catches bugs → `/review`
- QA Lead who tests everything → `/qa`
- Release Engineer who ships safely → `/ship`
- Tech Writer who updates docs → `/document-release`

With gstack, **all 13 specialists are slash commands**. You're managing the same review gates, same quality bars, same release process — just with autonomous agents doing the work.

The difference: **you're not paying for 13 people, and you're not bottlenecked by their schedule.** You run `/qa` at 3 AM if you want. You run `/plan-ceo-review` five times to explore different products. You run `/review` on every PR automatically.

That changes everything.

---

## Credits & License

**Author**: Garry Tan, President & CEO of Y Combinator

**License**: MIT (Free, forever, no strings)

**Source**: https://github.com/garrytan/gstack

**Philosophy**: "I open sourced how I do development and I am actively upgrading my own software factory here. You can fork it and make it your own. That's the whole point. I want everyone on this journey."

---

## Next Steps

1. **Try gstack in Claude Code**: Type `/plan-ceo-review` on any feature
2. **Combine with your skills**: Use /solution-iterator for design, /qa for verification
3. **Add to projects**: Copy to other repos you want to ship faster
4. **Keep it updated**: `auto_upgrade: true` in ~/.gstack/config.yaml

The models are getting better every week. The people who figure out how to work with them now — *really* work with them — are going to have a massive advantage.

This is that window. Let's go. 🚀
