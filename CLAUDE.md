# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**Glyphic** is a weekend prototype (12-16 hours) for a translation shop game combining cipher puzzles with Papers Please-style capacity management. The prototype tests whether translation puzzles without time pressure + limited customer capacity creates satisfying strategic tension.

**Engine:** Godot 4.5
**Language:** GDScript
**Timeline:** One weekend (Saturday-Sunday development)
**Prototype Goal:** Answer 5 critical questions about core mechanics (see Design Document)

---

## Running the Project

### Launch in Godot Editor
```bash
# Open project in Godot 4.5+
godot /Users/diarmuidcurran/Godot\ Projects/Prototypes/glyphic/project.godot
```

### Run from Command Line
```bash
# Run the project directly
godot --path "/Users/diarmuidcurran/Godot Projects/Prototypes/glyphic"
```

**Note:** This is an early-stage prototype. No build process, tests, or CI/CD exists yet. Development happens entirely in Godot Editor.

---

## Development Architecture

### Design Philosophy: Visual-First Prototyping

This prototype follows a **pixels-before-systems** approach:
1. **Phase 1 (0-2h):** Get static visuals on screen matching design specs
2. **Phase 2 (2-6h):** Make UI interactive with simplified/fake logic
3. **Phase 3 (6-9h):** Replace fake logic with real calculations
4. **Phase 4 (9-12h):** Add texture layers (examination, negotiation)
5. **Phase 5 (12-16h):** Integration, story beats, polish

**Key Principle:** Every phase produces something visible/clickable that tests specific design questions. No "invisible progress" phases.

### Scene-Based Modular Architecture

**DO create separate scenes for:**
- Reusable UI components (`CustomerCard.tscn`, `DictionaryEntry.tscn`)
- Game entities with independent logic (`BookExamination.tscn`, `TranslationWorkspace.tscn`)
- Popup overlays (`CustomerSelectionPopup.tscn`, `UpgradeShopMenu.tscn`)

**Expected scene structure:**
```
Main.tscn (root)
├── Background (desk surface)
├── TopBar (day/cash/capacity labels)
├── Workspace (center - translation area)
│   ├── BookExamination.tscn (examination phase)
│   └── TranslationWorkspace.tscn (puzzle phase)
├── LeftPanel (customer queue)
│   └── CustomerCard.tscn (×7-10 instances)
├── RightPanel (dictionary)
│   └── DictionaryEntry.tscn (×20 instances)
└── DialogueBox (bottom - customer messages)
```

**DON'T** build everything in one monolithic Main scene. Modularity enables parallel iteration and isolated testing.

---

## Core Game Systems

### 1. Translation Puzzle System
**What:** Player decodes unknown Unicode symbols (∆◊≈⊕⊗⬡∞◈...) into English by pattern recognition
**Critical Numbers:**
- 20-symbol alphabet
- 5 texts with increasing difficulty
- Text 1: "the old way" (simple substitution)
- Text 5: "they are returning soon" (synthesis puzzle)
- No time pressure - contemplative solving

**Key Behavior:** Dictionary auto-fills after symbol confirmed 3× (prototype: immediate for testing)

### 2. Limited Capacity System
**What:** Daily choice constraint - 7-10 customers arrive, can only serve 5
**Critical Numbers:**
- Daily capacity: 5 slots (6 with Coffee Machine upgrade)
- Must refuse 2-5 customers per day
- Recurring customers: Refuse 2× = relationship broken, they stop appearing
- The Stranger: Refuse 1× = gone forever (sensitive)

**Key Behavior:** Refusal consequences persist across days - tracking relationship damage is critical

### 3. Money & Rent System
**What:** Economic pressure loop forcing strategic customer choices
**Critical Numbers:**
- Starting cash: $100
- Daily utilities: $30 (auto-deduct at day end)
- Weekly rent: $200 (due Friday, manual payment)
- Translation income: Easy $50, Medium $100, Hard $200
- Cheap negotiation: 50% payment reduction

**Key Balance:** Player should be able to afford Friday rent with average play (mix Easy/Medium jobs), but tight enough to create strategic tension.

### 4. Customer Negotiation (Fast/Cheap/Accurate)
**What:** Each customer wants 3 things, can only have 2
**Options:**
- Fast + Cheap = Low pay, quick job, mistakes forgiven
- Fast + Accurate = Normal pay, quick + perfect (hard mode)
- Cheap + Accurate = Low pay, patient, must be perfect

**Prototype Simplification:** Priorities are preset per customer (not player-negotiated). Only "Cheap" has mechanical effect (50% payment). "Fast" and "Accurate" are dialogue flavor only.

### 5. Book Examination Phase
**What:** Optional pre-puzzle investigation using interactive tools
**Tools:**
- Zoom (default): Magnify 2× to examine cover/spine
- UV Light ($500 upgrade): Reveal hidden ownership marks
- Better Lamp ($300 upgrade): Show faded text hints (1 letter/word)

**Critical Design:** Must be OPTIONAL and SKIPPABLE. If players always skip it, that's a valid test result (examination may be busywork).

---

## Critical Design Constraints

### Scope Boundaries (What's OUT)
The following are **explicitly excluded** from the prototype:
- ❌ Time pressure/customer timers
- ❌ Multiple weeks (just 1 week: Monday-Sunday)
- ❌ Marcus moral choice system (mistranslation)
- ❌ Multiple endings
- ❌ Character portraits
- ❌ Animation/juice (screen shake, particles)
- ❌ Sound/music
- ❌ Save/load system
- ❌ Tutorial overlays/tooltips

**If implementing any of these:** Check design doc first. They were cut intentionally to focus on testing core questions.

### Five Critical Questions (Prototype Success Criteria)
After 7-day playthrough, score each 1-5:

**Q1:** Is decoding symbols satisfying as core loop?
**Q2:** Does limited capacity create strategic tension?
**Q3:** Does book examination add engaging texture?
**Q4:** Does customer negotiation create variety?
**Q5:** Does story emerge naturally from translations?

**Decision Threshold:**
- **≥20 points:** Build full game
- **15-19 points:** Iterate weak mechanics
- **<15 points:** Core loop broken, pivot

---

## Data Structures & Key Numbers

### Translation Text Format
```gdscript
var texts = [
  {
    id: 1,
    name: "Text 1 - Family History",
    symbols: "∆ ◊≈ ⊕⊗◈",
    solution: "the old way",
    mappings: {"∆": "the", "◊≈": "old", "⊕⊗◈": "way"},
    difficulty: "Easy",
    payment_base: 50
  },
  # ... 4 more texts
]
```

### Customer Data Structure
```gdscript
var customers = {
  "Mrs. Kowalski": {
    type: "recurring",
    appears_days: [1, 2, 3],  # Monday-Wednesday
    payment: 50,
    priorities: ["Cheap", "Accurate"],
    refusal_tolerance: 2,  # Stops appearing after 2 refusals
    dialogue: {
      greeting: "Hello dear, I found this old family book",
      success: "Oh wonderful! Thank you!",
      # ...
    }
  },
  # ... Dr. Chen, The Stranger
}
```

### Dictionary Entry States
- **Gray (unknown):** Never seen before, shows "???"
- **Yellow (tentative):** Seen 1-2 times, might be wrong
- **Green (confirmed):** Used correctly 3+ times, locked in

**Prototype shortcut:** Skip yellow state, go straight to green after 1 correct use (for faster testing)

---

## Development Workflow

### Phase-by-Phase Build Order
Follow `DEVELOPMENT_ROADMAP.md` for detailed feature breakdown. **Quick summary:**

**Phase 1 (Sat morning, 0-2h):** Foundation
- Game state manager (day, cash, capacity)
- Symbol data (20 glyphs → words)
- UI workspace layout (panels visible)

**Phase 2 (Sat morning-afternoon, 2-6h):** Core puzzle loop
- Translation display + validation
- Dictionary auto-fill
- Money tracking
- 5 translation texts

**Phase 3 (Sat afternoon-evening, 6-9h):** Strategic choice
- Customer queue display
- Accept/refuse logic
- Capacity enforcement (5-slot limit)
- Relationship tracking across days

**Phase 4 (Sun morning, 9-12h):** Engaging texture
- Book examination phase
- UV Light tool
- Negotiation display
- Multi-day progression + rent deadline

**Phase 5 (Sun afternoon, 12-16h):** Polish & integration
- Upgrade shop (3 upgrades)
- Story integration (lore snippets)
- Win condition (Day 7 cliffhanger)
- Balance tweaks + full playthrough test

### Testing Strategy
- **Test each feature immediately** after implementation (don't batch)
- **Acceptance criteria:** Each feature in roadmap has "Testable" one-liner
- **Sunday evening:** Full 7-day playthrough, score 5 critical questions

### Scope Management (If Running Over Time)
**Cut in priority order:**
1. Nice to Have: Better Lamp, Coffee Machine, visual polish
2. Should Have: Examination phase, UV Light, negotiation effects
3. Must Have (LAST RESORT): Story integration, relationship tracking

**Minimum viable prototype (7 hours):**
Features 1-10 (foundation + puzzle loop) + 13-14 (capacity) + 21-22 (multi-day) + 28 (win screen)
Tests Q1 (puzzles) and Q2 (capacity) only.

---

## Story & Narrative Arc

### 7-Day Progression
- **Days 1-2:** Family histories, mundane texts (build comfort)
- **Day 3:** First mention of "old ways" (ominous shift)
- **Days 4-5:** References to "old god," something sleeping
- **Day 6:** Agent Williams arrives (government knows about occult)
- **Day 7:** The Stranger's final text: "They are returning soon" (cliffhanger)

### Story Delivery (70/30 Split)
- **70% from translated text content:** Solutions themselves reveal lore
  - "the old way was forgotten" → magic existed?
  - "the old god sleeps" → something beneath the city?
- **30% from customer dialogue:** Reactions to translations
  - Dr. Chen Day 6: "This confirms my fears... they're waking up"

**Total dialogue budget:** ~20 unique lines (4 lines × 5 customers)

---

## Godot-Specific Conventions

### UI Layout (1280×720 viewport)
- **Top bar (60px):** Day tracker (left), Capacity counter (center), Cash (right)
- **Left panel (280px):** Customer queue, 7-10 cards vertically stacked
- **Right panel (280px):** Dictionary, 20 symbol entries, scrollable
- **Center workspace (720px):** Translation display, book examination
- **Bottom dialogue (200px):** Customer messages, negotiation text

### Color Palette (from design doc)
- **Beige desk:** #D4B896
- **Dark brown text:** #3A2518
- **Cream parchment:** #F4E8D8
- **Green (money/success):** #2D5016
- **Red (failure/refuse):** #8B0000
- **Gold (highlight):** #FFD700

### Symbol Alphabet (20 Unicode characters)
∆◊≈⊕⊗⬡∞◈⊟⊞⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩

**Usage:** Display at 32pt for readability, ensure font supports these characters.

---

## Key Files & Documentation

### Essential Documents (READ THESE FIRST)
1. **`Glyphic - Prototype Design Document.md`** - Complete game design specification
   - Section 2: 5 critical questions being tested
   - Section 3: Core mechanics with exact numbers
   - Section 4: Prototype scope (what's IN vs OUT)

2. **`DEVELOPMENT_ROADMAP.md`** - Phase-by-phase feature breakdown
   - 29 atomic features with build order dependencies
   - Testable acceptance criteria for each feature
   - Time estimates (30-90 min per feature)

### Future Files (Created During Development)
- **`/scenes/`** - Godot scene files (.tscn)
- **`/scripts/`** - GDScript files (.gd)
- **`/assets/`** - Sprites, textures, fonts
- **`/data/`** - JSON/GD data files (translation texts, customer definitions)

---

## Common Patterns & Anti-Patterns

### ✅ DO
- **Hard-code for speed:** Prototype values can be hard-coded (e.g., `var rent = 200`). Refactor later if greenlit.
- **Skip yellow state:** Dictionary goes gray → green immediately (skip tentative state for testing).
- **Fake constraints:** "Fast" and "Accurate" negotiation can be dialogue-only (no mechanical enforcement).
- **Test visually:** Take screenshots after each phase to verify pixel-perfect layout.
- **Break scenes up:** One scene per UI component (CustomerCard, DictionaryEntry, etc.).

### ❌ DON'T
- **Add time pressure:** No countdown timers, no rush mechanics. This breaks core design pillar #1.
- **Build complex upgrade trees:** Prototype has exactly 3 upgrades. More is scope creep.
- **Add tutorials/tooltips:** Mrs. Kowalski's first job IS the tutorial. Learn by doing.
- **Implement save/load:** 7-day run is 60-90 minutes. Just restart if needed.
- **Add multiple weeks:** Prototype is exactly 7 days (Mon-Sun). Week 2+ is full game content.

### 🎯 Validate Design Assumptions
If something feels wrong while implementing:
1. Check design doc Section 4 (Prototype Scope)
2. Verify against 5 critical questions (are you testing the right thing?)
3. Reference pivot triggers (design doc Section 6)
4. Ask: "Does this test a core mechanic or add scope creep?"

---

## Playtesting & Iteration

### Sunday Evening Evaluation Protocol
1. **Complete full 7-day run** (Monday → Sunday)
2. **Score each critical question 1-5** honestly
3. **Record quantitative metrics:**
   - Refused X customers per day (target: 2-5)
   - Translation accuracy: X% correct first try (target: >60%)
   - Friday rent: Paid successfully? Cash balance at end?
4. **Note qualitative observations:**
   - Which refusals felt hardest? (proves emotional weight)
   - Did examination help or feel like busywork?
   - Did you care about customer relationships?

### Pivot Decision Tree
**If total score ≥20:** Build full game (5-week expansion, moral choices, multiple endings)
**If score 15-19:** Iterate weak mechanics, retest next weekend
**If score <15:** Major pivot required:
- Pivot A: Remove examination (pure translation + choice)
- Pivot B: Remove negotiation (simplify to capacity only)
- Pivot C: Add light time pressure (soft daily deadline)
- Pivot D: Pure puzzle game (cut shop management)
- Pivot E: Visual novel with puzzles (cut money system)
- Pivot F: Different puzzle type (keep shop, change core activity)

---

## Performance & Optimization

**Not a concern for prototype.** This is a 2D UI-driven game with <100 nodes on screen. If you encounter performance issues, it's a bug (e.g., infinite loop), not an optimization problem.

---

## Glossary

**Limited Capacity:** Core constraint - can only serve 5 customers/day from 7-10 arrivals
**Recurring Customer:** Appears multiple days, relationship tracks refusals (Mrs. K, Dr. Chen, Stranger)
**One-Time Customer:** Random scholar/collector/student, never returns if refused
**Negotiation Priorities:** Fast/Cheap/Accurate framework (customer wants 3, gets 2)
**Dictionary Auto-Fill:** Symbol-to-word reference panel that fills as you learn (permanent progression)
**Examination Phase:** Optional pre-puzzle investigation using zoom/UV light tools
**Symbol Alphabet:** 20 Unicode glyphs (∆◊≈⊕⊗⬡∞◈⊟⊞⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩)
**7-Day Arc:** Monday → Sunday narrative progression (mundane → occult → cliffhanger)

---

## Getting Help

**Primary references (in priority order):**
1. This file (CLAUDE.md) - High-level architecture and workflow
2. Design document - Game mechanics and exact numbers
3. Development roadmap - Feature breakdown and dependencies
4. Godot 4.5 docs - Engine-specific implementation details

**If stuck:** Cross-reference design doc Section 4 (Prototype Scope) to verify you're building what's actually IN the prototype, not features explicitly cut.
