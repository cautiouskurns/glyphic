# GLYPHIC - Phase-by-Phase Development Roadmap

---

## ROADMAP OVERVIEW

**Prototype Name:** Glyphic - Translation Shop Prototype
**Total Development Time:** 12-16 hours (one weekend)
**Core Innovation Being Tested:** Translation puzzles without time pressure + limited capacity shop management creating strategic tension through meaningful choice

**Critical Questions:**
1. **Is decoding symbols satisfying as core 2-5 minute loop?** (Tests puzzle engagement without time pressure)
2. **Does limited capacity create meaningful strategic tension?** (Tests choice weight: money vs. story vs. morality)
3. **Does book examination add engaging texture before puzzles?** (Tests depth vs. busywork trade-off)
4. **Does customer negotiation (fast/cheap/accurate) create variety?** (Tests constraint impact on same content)
5. **Does story emerge naturally from translations + customer choices?** (Tests narrative integration)

---

## PHASE 1: FOUNDATION (Hours 0-2)
**Goal:** Core data structures exist, UI layout visible, game can track state.

### 1.1 Game State Manager
- Tracks current day (1-7, Monday-Sunday), player cash ($100 start), capacity used (0/5)
- Handles day transitions, utility deductions ($30/day), rent deadline (Friday $200)
- Stores global state accessible to all systems

**Why first:** Every other system queries or modifies game state—this is the single source of truth.

**Testable:** Launch game, verify day=Monday, cash=$100, capacity=0/5 displayed on screen.

### 1.2 Symbol Data System
- 20-symbol alphabet (∆◊≈⊕⊗⬡∞◈⊟⊞⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩) mapped to English words
- 5 text definitions with symbols, solutions, difficulty (Easy/Medium/Hard), payment ($50-$200)
- Dictionary data structure: symbol → word mapping, confidence level (unknown/tentative/confirmed)

**Why first:** Translation system needs symbol-to-word lookup before any puzzle can be displayed.

**Testable:** Print first text data, verify "∆ ◊≈ ⊕⊗◈" maps to solution "the old way".

### 1.3 UI Workspace Layout
- Main workspace (center): text display area, input field, submit button
- Dictionary panel (right): scrollable symbol list (20 entries, all "???" initially)
- Customer queue panel (left): space for 7-10 customer cards
- Status bar (top): day tracker, cash counter, capacity counter
- Dialogue box (bottom): customer messages area

**Why first:** Provides visual foundation for all interactive elements—everything else renders into these panels.

**Testable:** Launch game, see all panels positioned correctly with no overlap or layout errors.

### 1.4 Customer Data Structures
- 3 recurring customer types: Mrs. Kowalski (Days 1-3, $50, Cheap+Accurate), Dr. Chen (Days 2-7, $100-150, Fast+Accurate), The Stranger (Days 5-7, $200, Fast+Accurate)
- Customer properties: name, payment, difficulty, priorities (Fast/Cheap/Accurate), dialogue lines (greeting/negotiation/success/failure)
- Random customer generator: creates one-time customers with randomized payment $40-$120

**Why before selection:** Queue system needs customer data to display cards and details.

**Testable:** Generate daily queue of 7 customers, verify mix of 3 recurring + 4 random with correct properties.

---

## PHASE 2: CORE PUZZLE LOOP (Hours 2-6)
**Goal:** Player can translate one text, submit answer, see success/failure, earn money, dictionary updates.

### 2.1 Translation Display System
- Shows symbol text from current puzzle (e.g., "∆ ◊≈ ⊕⊗◈") in center workspace with large readable font
- Input field accepts typed English text (max 50 characters)
- Submit button triggers validation when clicked

**Why after foundation:** Needs symbol data + UI workspace panels to render into.

**Testable:** Type "the old way" in input field, click submit, see validation trigger (even if response is placeholder).

### 2.2 Translation Validation Engine
- Compares player input to solution (case-insensitive, whitespace-normalized)
- Returns success (exact match) or failure (wrong answer)
- Allows infinite retries (no failure penalty for prototype)

**Why after display:** Needs input system to receive player answer before validating.

**Testable:** Submit correct answer "the old way" → see success state, submit wrong answer "wrong" → see failure state.

### 2.3 Success/Failure Feedback
- Success: Green flash on input field, "+$50" message in dialogue box, cash counter updates
- Failure: Red flash on input field, "Try again" message in dialogue box, input field clears
- Customer reaction dialogue shows (1-line success/failure message)

**Why after validation:** Visual feedback responds to validation result—can't show success before knowing if answer is correct.

**Testable:** Successful translation shows green flash + cash increases by payment amount ($100 → $150 for $50 job).

### 2.4 Dictionary Auto-Fill System
- After successful translation, updates dictionary panel with learned symbols
- Maps symbols to words: ∆ → "the" (green), ◊≈ → "old" (green), ⊕⊗◈ → "way" (green)
- For prototype: immediate confirmation after 1 use (skips 3-use rule for simplicity)
- Known symbols highlight green in dictionary panel

**Why after validation:** Dictionary updates only happen on successful translation completion.

**Testable:** Complete Text 1, verify dictionary shows 3 green entries (∆="the", ◊≈="old", ⊕⊗◈="way"), remaining 17 show "???".

### 2.5 Money Tracking System
- Cash counter updates after successful translation (+$50 to +$200 based on difficulty)
- Displays current cash in top-right corner at all times
- No deductions yet (utilities/rent added in Phase 4)

**Why after validation:** Payment amount depends on translation success state.

**Testable:** Start with $100, complete Easy translation ($50), verify cash updates to $150.

### 2.6 Five Translation Texts
- Text 1: "the old way" (3 words, symbols: ∆ ◊≈ ⊕⊗◈, payment $50, simple substitution)
- Text 2: "the old way was forgotten" (5 words, reuses 3 symbols + adds 2 new, payment $100)
- Text 3: "the old god sleeps" (4 words, reuses 2 symbols + adds 2 new, payment $100)
- Text 4: "magic was once known" (4 words, reuses 1 symbol + adds 3 new, payment $150)
- Text 5: "they are returning soon" (4 words, adds 4 new symbols, payment $200, finale)

**Why after validation:** Tests full difficulty progression from simple to complex puzzles.

**Testable:** Complete all 5 texts in sequence, verify dictionary grows from 3 → 6 → 8 → 11 → 15 symbols learned.

---

## PHASE 3: STRATEGIC CHOICE LAYER (Hours 6-9)
**Goal:** Player chooses 5 customers from 7-10 arrivals, refusals have consequences, capacity creates tension.

### 3.1 Customer Queue Display
- Left panel shows 7-10 customer cards stacked vertically (3 recurring + 4-7 random)
- Each card shows: name, payment amount, difficulty (Easy/Medium/Hard), one-line description
- Cards are clickable (highlight on hover to indicate interactivity)

**Why after core loop:** Needs customer data + workspace layout to render queue panel.

**Testable:** Start day, see 7 customer cards in left panel with correct info, hover highlights individual cards.

### 3.2 Customer Selection Popup
- Click customer card → modal popup appears with full details (name, payment, dialogue, priorities)
- Shows negotiation priorities: "Cheap + Accurate" (Mrs. K), "Fast + Accurate" (Dr. Chen)
- Two buttons: ACCEPT (green) / REFUSE (red)

**Why after queue display:** Popup responds to customer card click events.

**Testable:** Click Mrs. Kowalski card, see popup with "$50, Easy, Cheap+Accurate, 'Take your time, dear'" details.

### 3.3 Accept/Refuse Logic
- ACCEPT: Customer moves to "accepted" list, capacity counter increments (0/5 → 1/5), loads translation workspace with their text
- REFUSE: Customer card grays out with 50% opacity, shows red X icon, customer removed from queue
- At 5/5 capacity: Remaining customers auto-refuse with "Shop is full for today" message

**Why after popup:** Executes player's accept/refuse choice from popup buttons.

**Testable:** Accept 5 customers, verify capacity shows 5/5, remaining 2-5 customers gray out automatically with message.

### 3.4 Capacity Enforcement
- Daily limit: 5 translation slots (hard cap)
- Once 5 accepted, cannot accept more (ACCEPT buttons disabled on remaining cards)
- Refused customers don't return (one-time) or damage relationship (recurring)

**Why after accept/refuse:** Enforces the core strategic constraint limiting player choices.

**Testable:** Try clicking 6th customer after 5/5, verify ACCEPT button disabled or shows "Shop full" tooltip.

### 3.5 Customer Relationship Tracking
- Recurring customers track acceptance/refusal history across days
- Mrs. Kowalski: Refuse 2× → she stops appearing in queue (Days 1-3 appearance window)
- Dr. Chen: Refuse 2× → she stops appearing (Days 2-7 appearance window)
- The Stranger: Refuse 1× → he stops appearing (Days 5-7 appearance window, very sensitive)

**Why after refusal logic:** Tracks consequences over multiple days—needs refusal system working first.

**Testable:** Refuse Mrs. K on Day 1 and Day 2, advance to Day 3, verify she doesn't appear in Day 3 queue.

### 3.6 Daily Queue Generation
- Each morning (start of day), generate 7-10 customers based on current day number
- Days 1-3: Mrs. K appears if relationship intact (not refused 2×)
- Days 2-7: Dr. Chen appears if relationship intact (not refused 2×)
- Days 5-7: Stranger appears if relationship intact (not refused 1×)
- Fill remaining 4-7 slots with random one-time customers ($40-$120 payment range)

**Why after relationship tracking:** Uses refusal history to determine which recurring customers return.

**Testable:** Start Day 2, verify Mrs. K + Dr. Chen both appear in queue (if both accepted Day 1), plus 5-8 random customers.

---

## PHASE 4: ENGAGING TEXTURE (Hours 9-12)
**Goal:** Book examination tools work, negotiation affects constraints, multi-day progression functions, rent pressure exists.

### 4.1 Book Examination Phase
- After accepting customer, "Examine Book" screen appears before translation puzzle
- Shows book image (cover texture) with interactive zoom tool (click-drag to magnify 2× in inset panel)
- "Skip Examination" button jumps directly to translation (examination is optional)

**Why after customer selection:** Triggered after accepting customer, serves as intermediate step before translation.

**Testable:** Accept customer, see examination screen, use zoom tool to magnify book cover, click skip to proceed to translation.

### 4.2 UV Light Tool (Upgrade)
- If UV Light purchased ($500 from shop), UV button appears in examination phase toolbar
- Click UV → book texture changes to purple-tinted version, hidden text overlays appear
- Reveals clues: "Previous owner: Margaret K.", "Warning: Handle with care"

**Why after basic examination:** Optional enhancement requiring upgrade purchase—examination must work first.

**Testable:** Purchase UV Light, examine next book, click UV button, see hidden ownership marks appear on book texture.

### 4.3 Customer Negotiation Display
- In selection popup, show customer's preset priorities: "Cheap + Accurate" (Mrs. K), "Fast + Accurate" (Dr. Chen)
- Display constraint descriptions: "Low payment, no time limit, must be perfect" (Cheap+Accurate)
- Priorities are preset per customer (not player-negotiated for prototype simplicity)

**Why after selection popup:** Adds detail layer to customer info shown before acceptance decision.

**Testable:** View Mrs. K popup, verify shows "Cheap + Accurate" priorities badge and constraint description text.

### 4.4 Negotiation Constraint Effects
- Cheap priority: Payment reduced 50% (Mrs. K pays $25 instead of $50 base for Easy job)
- Accurate priority: Failure message warns "Customer disappointed—accuracy was critical!" (no mechanical penalty in prototype)
- Fast priority: No mechanical effect in prototype (mentioned in dialogue flavor only)

**Why after negotiation display:** Enforces what customer priorities mean mechanically in the game.

**Testable:** Accept Mrs. K (Cheap), complete translation, verify payment is $25 (50% of $50 Easy base rate).

### 4.5 Multi-Day Progression System
- "End Day" button appears after 5 customers served (or all refused/queue exhausted)
- Click End Day → deduct utilities (-$30 from cash), advance day counter (Monday → Tuesday), generate new queue
- Day transitions clear accepted customer list and reset capacity to 0/5

**Why after choice layer:** Needs capacity system to know when daily quota is complete.

**Testable:** Complete Day 1 (serve 5 customers), click End Day, verify Day 2 starts with cash reduced by $30 and new queue appears.

### 4.6 Rent Deadline & Game Over
- Friday 5pm (end of Day 5): Check if cash ≥ $200 for rent payment
- If cash < $200: Show "Cannot afford rent - GAME OVER" screen with restart button
- If cash ≥ $200: Deduct $200, show "Rent paid successfully" message, continue to Saturday (Day 6)

**Why after multi-day:** Tests economic pressure across full week—requires day progression working.

**Testable:** Reach Friday with $150 cash, verify Game Over triggers; restart and reach Friday with $250, verify rent deducts and Saturday starts.

---

## PHASE 5: PROGRESSION & POLISH (Hours 12-16)
**Goal:** Full 7-day loop works, upgrades purchasable and functional, story beats appear, win condition reached.

### 5.1 Upgrade Shop Menu
- Accessible between customers via "SHOP" button in top bar
- Shows 3 upgrades with cost: Better Lamp ($300), UV Light ($500), Coffee Machine ($150)
- Click upgrade → deduct cash if affordable, mark as owned, effect activates immediately for next use

**Why after money system:** Requires cash tracking for purchases and spending logic.

**Testable:** Earn $500, open shop, buy UV Light, verify cash becomes $0 and UV button appears in next examination phase.

### 5.2 Better Lamp Upgrade
- Cost: $300
- Effect: During examination phase, book image shows faded text hints (1 letter per word revealed)
- Example: Solution "the old way" shows as "t__ o__ w__" overlaid on book texture

**Why after examination phase:** Enhances examination with visual hints—examination must exist first.

**Testable:** Buy lamp ($300), examine next book, verify hints appear as faded letters on book image (e.g., "t__ o__ w__").

### 5.3 Coffee Machine Upgrade
- Cost: $150
- Effect: Increases daily capacity from 5 to 6 customers permanently
- Capacity counter updates to show "0/6" instead of "0/5" after purchase

**Why after capacity system:** Modifies core capacity limit—capacity enforcement must work first.

**Testable:** Buy coffee machine, start new day, verify can accept 6 customers instead of 5, capacity shows X/6.

### 5.4 Story Integration: Text Content
- Translation solutions ARE the story: "the old way was forgotten" → implies magic existed
- After successful translation, show lore snippet in dialogue box (30-50 words)
- Text 1-2 (Days 1-2): Mundane family history flavor ("grandmother's journal mentions old traditions")
- Text 3 (Day 3): First ominous shift ("mentions an 'old god'... something sleeping?")
- Text 5 (Day 7): Cliffhanger finale ("they are returning soon"—who? when?)

**Why after translation validation:** Story reveals are tied to successful puzzle completion.

**Testable:** Complete Text 3, verify dialogue box shows "Dr. Chen gasps: 'This mentions an old god... something sleeping beneath the city.'"

### 5.5 Story Integration: Customer Dialogue
- Customer dialogue changes based on relationship history + current day
- Mrs. K Day 1: "Hello dear, I found this old family book"
- Mrs. K Day 2 (if accepted Day 1): "You did such wonderful work yesterday! Another heirloom..."
- Dr. Chen Day 6: "This confirms my fears... they're waking up. We're running out of time."

**Why after relationship tracking:** Dialogue references acceptance/refusal history tracked by relationship system.

**Testable:** Accept Mrs. K Day 1, see her Day 2, verify greeting dialogue references "wonderful work yesterday" instead of generic first-time greeting.

### 5.6 Win Condition: Day 7 Completion
- After completing Sunday (Day 7) successfully, show "Week Complete" victory screen
- Display final message: "The Stranger's warning echoes in your mind: 'They are returning soon.' TO BE CONTINUED..."
- Show playtest evaluation: "Rate your experience 1-5 for each critical question"

**Why last:** Requires full 7-day loop working end-to-end to reach finale.

**Testable:** Play through Monday → Sunday, complete Day 7 translations, verify win screen appears with cliffhanger text and evaluation prompts.

### 5.7 Balance Tweaking & Bug Fixes
- Adjust payment amounts if rent pressure too harsh (can't reach $200) or too easy (always have $500+)
- Fix edge cases: refuse all customers → game stuck?, no cash Day 1 → softlock?, dictionary overflow?
- Test full playthrough: verify $200 rent payable by Friday with average play (mix of Easy/Medium jobs)

**Why last:** Requires complete game loop to test balance across all systems interacting.

**Testable:** Complete 3 full 7-day runs with different strategies (all high-pay, all story, mixed), verify rent always payable with reasonable play.

---

## DEPENDENCY MAP

```
Game State Manager (1.1)
    ↓
    ├─→ UI Workspace Layout (1.3) ────→ Customer Queue Display (3.1)
    │                                         ↓
    ├─→ Symbol Data (1.2) ────→ Translation Display (2.1)
    │                                         ↓
    │                              Translation Validation (2.2)
    │                                         ↓
    │                              Success/Failure Feedback (2.3)
    │                                    ↓         ↓
    │                         Dictionary (2.4)  Money (2.5)
    │                                               ↓
    └─→ Customer Data (1.4) ────→ Selection Popup (3.2)
                                          ↓
                              Accept/Refuse Logic (3.3)
                                     ↓         ↓
                         Capacity (3.4)  Relationships (3.5)
                                     ↓         ↓
                              Daily Queue Gen (3.6)
                                          ↓
                              ┌───────────┴───────────┐
                              ↓                       ↓
                    Examination (4.1)      Negotiation Display (4.3)
                              ↓                       ↓
                        UV Light (4.2)    Constraint Effects (4.4)
                              ↓
                      Multi-Day Progression (4.5)
                              ↓
                      Rent Deadline (4.6)
                              ↓
                      ┌───────┴───────┐
                      ↓               ↓
              Upgrade Shop (5.1)  Story Integration (5.4, 5.5)
                      ↓               ↓
            Lamp/UV/Coffee (5.2-5.3)  Win Condition (5.6)
                                      ↓
                              Balance Tweaks (5.7)
```

---

## CRITICAL PATH PRIORITY

### **Must Have (Core Loop - Tests Q1, Q2, Q5)**
Priority 1 features that directly test the 5 critical questions:

- **Translation validation (2.2)** - Tests Q1: Is puzzle-solving satisfying?
- **Dictionary auto-fill (2.4)** - Tests Q1: Does progression feel meaningful?
- **Customer selection (3.2-3.3)** - Tests Q2: Are choices agonizing?
- **Capacity enforcement (3.4)** - Tests Q2: Does limitation create tension?
- **Relationship tracking (3.5)** - Tests Q2: Do refusals have weight?
- **Multi-day progression (4.5)** - Tests Q2: Does economic pressure build?
- **Story integration (5.4-5.5)** - Tests Q5: Does narrative emerge naturally?
- **Win condition (5.6)** - Completes 7-day arc for full evaluation

### **Should Have (Depth - Tests Q3, Q4)**
Priority 2 features that test secondary questions and add strategic depth:

- **Examination phase (4.1)** - Tests Q3: Texture vs. busywork trade-off
- **UV Light tool (4.2)** - Tests Q3: Are tools worthwhile?
- **Negotiation display (4.3-4.4)** - Tests Q4: Do constraints create variety?
- **Upgrade shop (5.1-5.3)** - Tests progression investment feel
- **Rent deadline (4.6)** - Tests economic pressure timing

### **Nice to Have (Polish)**
Priority 3 features that enhance experience but aren't critical for validation:

- **Better Lamp upgrade (5.2)** - Enhances examination with hints
- **Coffee Machine upgrade (5.3)** - Provides capacity relief valve
- **Balance tweaks (5.7)** - Fine-tunes difficulty curve
- **Visual feedback polish** - Green/red flashes, smooth animations
- **Five translation texts (2.6)** - Full difficulty progression (could test with 3 texts minimum)

---

## TESTING MILESTONES

- **After Phase 1:** "Can I see the complete workspace layout and verify game state tracks correctly?"
  - Validates foundation exists for all other systems

- **After Phase 2:** "Can I solve one translation puzzle and receive satisfying feedback?"
  - **Tests Q1 (puzzle satisfaction)** - Core mechanic works at smallest scale

- **After Phase 3:** "Do I agonize over which 5 customers to accept from 7-10 arrivals?"
  - **Tests Q2 (strategic tension)** - Choice constraint creates meaningful decisions

- **After Phase 4:** "Does examination feel worthwhile or like skippable busywork?"
  - **Tests Q3 (texture depth)** - Optional layer adds value vs. friction

- **After Phase 4:** "Do negotiation constraints make the same puzzle feel different?"
  - **Tests Q4 (variety)** - Cheap vs. Accurate changes experience

- **After Phase 5:** "Did the story emerge naturally from translations and customer choices?"
  - **Tests Q5 (narrative integration)** - Lore discovered through gameplay

**The final question determines if prototype succeeded:**
Score all 5 critical questions 1-5 after full 7-day playthrough.
- **Total ≥20:** Build full game (5-week expansion)
- **Total 15-19:** Iterate on weak mechanics, retest
- **Total <15:** Core loop broken, pivot to alternative design

---

## QUICK REFERENCE: BUILD ORDER

**Phase 1: Foundation (Hours 0-2)**
1. Game State Manager (day, cash, capacity tracking) - 30 min
2. Symbol Data System (20 symbols, 5 text definitions) - 45 min
3. UI Workspace Layout (panels, status bar, dialogue box) - 30 min
4. Customer Data Structures (3 recurring + random generator) - 15 min

**Phase 2: Core Puzzle Loop (Hours 2-6)**
5. Translation Display System (show symbols, input, submit) - 45 min
6. Translation Validation Engine (check answer correctness) - 30 min
7. Success/Failure Feedback (visual + message) - 30 min
8. Dictionary Auto-Fill System (learn symbols on success) - 45 min
9. Money Tracking System (cash updates on success) - 15 min
10. Five Translation Texts (difficulty progression content) - 45 min

**Phase 3: Strategic Choice Layer (Hours 6-9)**
11. Customer Queue Display (7-10 cards visible) - 30 min
12. Customer Selection Popup (full details, buttons) - 45 min
13. Accept/Refuse Logic (move to accepted, increment capacity) - 30 min
14. Capacity Enforcement (5-slot limit, auto-refuse) - 30 min
15. Customer Relationship Tracking (refusal consequences) - 45 min
16. Daily Queue Generation (recurring + random mix) - 30 min

**Phase 4: Engaging Texture (Hours 9-12)**
17. Book Examination Phase (zoom tool, skip button) - 45 min
18. UV Light Tool (upgrade-gated, reveals clues) - 30 min
19. Customer Negotiation Display (show priorities) - 30 min
20. Negotiation Constraint Effects (cheap = 50% payment) - 30 min
21. Multi-Day Progression System (end day, utilities, advance) - 45 min
22. Rent Deadline & Game Over (Friday check, win/lose) - 30 min

**Phase 5: Progression & Polish (Hours 12-16)**
23. Upgrade Shop Menu (buy lamp/UV/coffee) - 45 min
24. Better Lamp Upgrade (examination hints) - 30 min
25. Coffee Machine Upgrade (capacity +1) - 15 min
26. Story Integration: Text Content (lore in translations) - 60 min
27. Story Integration: Customer Dialogue (relationship-aware) - 45 min
28. Win Condition: Day 7 Completion (cliffhanger screen) - 30 min
29. Balance Tweaking & Bug Fixes (full playthrough testing) - 60 min

---

**Total Features:** 29 atomic features
**Estimated Time:** 14 hours (within 12-16 hour target)
**Critical Path:** Features 1→2→3→5→6→7→8→11→12→13→14→15→21→22→26→27→28 (17 features, ~9.5 hours minimum)
**Success Metric:** Complete 7-day run, score 5 critical questions, achieve ≥20/25 points to greenlight full game

---

## IMPLEMENTATION NOTES

**Scope Management:**
- If running over time, cut features in reverse priority: Nice to Have → Should Have → Must Have (last resort)
- Minimum viable prototype: Features 1-10, 13-14, 21-22, 28 (12 features, ~7 hours)
- This tests Q1 (puzzles) and Q2 (capacity) which are most critical

**Testing Strategy:**
- Test each feature immediately after implementation (don't batch testing)
- Keep a playtest journal noting friction points and "aha!" moments
- Sunday evening: Full 7-day playthrough + score 5 critical questions honestly

**Pivot Triggers (from design doc):**
- If Q1 scores <3: Puzzles aren't fun → try different puzzle type
- If Q2 scores <3: Capacity doesn't matter → adjust limit or consequences
- If Q3 scores <3: Examination is busywork → cut it entirely
- If Q4 scores <3: Negotiation is tedious → simplify to binary accept/refuse
- If Q5 scores <3: Story is confusing → increase exposition or cut narrative

**Post-Prototype Next Steps:**
- **Score ≥20:** Expand to 5-week game (35 days, 15+ texts, 8+ customers, moral choice branches)
- **Score 15-19:** Iterate weak mechanics, add missing hooks, retest next weekend
- **Score <15:** Major pivot required—consider alternatives from Section 6 of design doc
