# Glyphic - Prototype Design Document

**Version:** 0.2 - Weekend Prototype (Revised)  
**Goal:** Test if translation puzzles + limited capacity shop management creates engaging moment-to-moment loop with narrative payoff  
**Timeline:** One weekend (12-16 hours)  
**Date:** November 16, 2025

---

## 1. CONCEPT

### Elevator Pitch
Run a translation shop where you decode mysterious texts for strange customers—choose who to help each day while uncovering an occult conspiracy hidden in ancient languages.

### Design Pillars

**1. Satisfying Puzzle Cracking (No Time Pressure)**
- Each translation is a self-contained cipher/logic puzzle (take as long as you need)
- Visual progress: dictionary fills in as you learn symbols, creating permanent advancement
- "Aha!" moments from pattern recognition (realizing ∆ = "the" unlocks understanding)
- Difficulty scales naturally: Text 1 = simple substitution, Text 5 = multi-concept synthesis
- Solve at your own pace: No countdown, no stress, just pure puzzle satisfaction

**2. Meaningful Strategic Choices**
- Limited capacity: Can only serve 5 customers per day, but 7-10 arrive (must choose who to help)
- Opportunity cost: Easy $50 job takes slot you could use for $200 hard job
- Character relationships: Refuse Dr. Chen too often, she stops coming back
- Moral weight: Government wants you to translate evidence against your customers
- Resource tension: Need rent money ($200 Friday) but also want to help people, advance story

**3. Interactive Book Examination**
- Before translating, examine each book (zoom, UV light, check condition)
- Tools reveal clues: UV light shows hidden ownership marks, magnifying glass reveals age
- Gather context: Know if it's occult/academic/personal before starting puzzle
- Customer negotiation: They want fast/cheap/accurate—pick 2 of 3
- Every job feels different: Same translation difficulty, different constraints/stakes

**4. Occult Mystery Through Work**
- Story emerges FROM the translations (not separate cutscenes)
- Each decoded text reveals lore: "the old way was forgotten" → magic was real?
- Customers ARE the plot: Scholar researching → Government investigating → Stranger recruiting
- No grinding: Every translation advances narrative or teaches new mechanic
- Your choices shape story: Who you help determines what you learn

### Primary Influences

**Papers, Please (Lucas Pope)**
- Mechanic: Limited capacity (can't process everyone), moral choices under resource pressure, daily structure
- Application: Choose 5 customers from 10 arrivals, balance money vs. morality vs. story, same desk view, same daily loop. Tension from CHOICE not SPEED.

**Return of the Obra Dinn (Lucas Pope)**
- Mechanic: Deductive logic from incomplete information, examination phase before conclusions
- Application: Examine books with tools (zoom, UV light) before translating. Cross-reference previous texts. Build understanding of language system through detective work.

**Dave the Diver (Mintrocket)**
- Mechanic: Action phase (diving) → Management phase (restaurant) → Story phase (sea people) loop
- Application: Examination phase (investigate book) → Translation phase (solve puzzle) → Shop phase (choose next customer, buy upgrades) → Story phase (customer revelations). Same "one more day" compulsion.

**Chants of Sennaar (Rundisc)**
- Mechanic: Decipher unknown languages through context, visual association, experimentation at own pace
- Application: Learn symbol meanings by seeing them in different contexts, dictionary auto-fills when you confirm translations, grammar patterns emerge organically. No timers—contemplative puzzle-solving.

---

## 2. WHAT WE'RE TESTING

### Critical Questions

**Q1: Is decoding symbols satisfying as core 2-5 minute loop?**
- Success = Player feels smart when cracking code, wants to translate next text immediately, enjoys working without time pressure
- Failure = Frustration from unclear logic, boredom from too-easy substitution, or wants timer for excitement

**Q2: Does limited capacity create meaningful strategic tension?**
- Success = Player agonizes over which 5 customers to accept from 10 arrivals, makes trade-offs (money vs. story vs. morality), refuses customers reluctantly
- Failure = Choices feel arbitrary, capacity never matters (always enough slots), or decision is always obvious (just pick highest paying)

**Q3: Does book examination add engaging texture before puzzles?**
- Success = Player uses UV light/zoom to gather clues, examination reveals useful context (language type, difficulty preview), tools feel interactive not cosmetic
- Failure = Examination is busywork (skip it immediately), clues are irrelevant to translation, or tools don't matter

**Q4: Does customer negotiation (fast/cheap/accurate) create variety?**
- Success = Same text feels different under different constraints, negotiation reveals character personality, player makes strategic choices based on needs
- Failure = Constraints don't matter (always pick same option), negotiation is tedious, or character personality doesn't come through

**Q5: Does story emerge naturally from translations + customer choices?**
- Success = Player pieces together occult mystery from decoded texts + who they chose to help, feels like detective, cares about character arcs
- Failure = Story is confusing, choices don't affect narrative, or customers feel interchangeable despite refusing some

### Success Criteria

After Sunday night playtest, score each question 1-5:
- **1** = Doesn't work at all
- **3** = Works but needs improvement  
- **5** = Works great, build full game

**Decision Threshold:**
- **20-25 points** (4-5 avg): Build full game, expand to 5-week arc with deeper choices
- **15-19 points** (3-4 avg): Iterate on weak mechanics, retest next weekend
- **<15 points** (<3 avg): Core loop broken, pivot to different framing or simplify further

---

## 3. CORE MECHANICS

### Translation Puzzle System

**Overview:**  
Player receives text in unknown symbols, must decode into English by pattern recognition and context clues. Text appears as string of Unicode symbols (∆◊≈ ⊕⊗◈ ⬡∞◊), player types English translation, submits for validation. **No time pressure—solve at your own pace.**

**Specifics:**
- Alphabet size: 20 symbols for prototype (∆◊≈⊕⊗⬡∞◈⊟⊞⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩)
- Text length: 3-8 words per translation (15-40 characters)
- Difficulty progression:
  - Text 1: Simple substitution (1 symbol = 1 word, e.g., ∆="the")
  - Text 2: Grammar patterns (word order matters: ⊕⊗◈ ∆ ⬡∞◊ = "old the way" must become "the old way")
  - Text 3-4: New vocabulary builds on previous (∆="the" established, learn ⊞="god")
  - Text 5: Synthesis (uses 10+ symbols from all previous texts)
- Dictionary auto-completes: Once symbol confirmed correct 3 times, always shows in reference panel
- No randomization: Same input always same solution (allows learning)
- Pause anytime: Can walk away, return later, think as long as needed

**Interactions:**
- Success → Earns $50-$200 based on negotiated difficulty
- Failure → Customer disappointed, pays 50%, reputation -1
- Dictionary fills → Future puzzles easier (known symbols highlighted)
- Upgrades (lamp, UV light) reveal hints during examination phase

---

### Limited Capacity System

**Overview:**  
Each day, 7-10 customers arrive seeking translations. You can only serve 5 customers per day (limited capacity). Must choose which 5 to accept, refuse the rest. Refused customers may not return.

**Specifics:**
- Daily capacity: 5 translation slots
- Morning arrivals: 7-10 customers appear in queue
- Selection phase: Review each customer's request, choose 5 to accept
- Customer info shown before accepting:
  - Name + relationship level (Mrs. K: Friendly, Agent W: Suspicious)
  - Payment offered: $50-$200
  - Difficulty estimate: Easy/Medium/Hard
  - Special notes: "Urgent," "Story-critical," "Moral choice"
- Refusal consequences:
  - One-time customers: Gone forever (lose potential income)
  - Recurring customers: Relationship damage (refuse 2x = they stop coming)
  - Story customers: Miss narrative thread (refuse Stranger = don't learn conspiracy)

**Interactions:**
- Accept 5 → Work on them throughout day at own pace
- Refuse 2-5 → They leave disappointed
- Reputation affects future arrivals: Low rep = fewer high-paying customers
- Strategic tension: Need rent money vs. want to advance story vs. moral choices

**Example Daily Queue:**
```
MONDAY MORNING (Choose 5 from 7):

1. Mrs. Kowalski: Easy, $50, "Family heirloom, dear" [RECURRING - Tutorial]
2. Dr. Chen: Medium, $100, "Critical for research" [RECURRING - Story]
3. Marcus: Easy, $75, "Quick job, just need it done" [RECURRING - Volume]
4. Random Scholar: Medium, $120, "Academic text" [ONE-TIME]
5. Random Collector: Hard, $180, "Rare find" [ONE-TIME]
6. The Stranger: Hard, $200, "Translate this." [RECURRING - Main Plot]
7. Random Student: Easy, $40, "Homework help..." [ONE-TIME]

WHO DO YOU REFUSE?
- Refuse students/randoms = Maximize income but lose variety
- Refuse Marcus = Lose steady income but avoid moral choices
- Refuse Stranger = Stay safe but miss conspiracy reveal
- Refuse Mrs. K = Maximize profit but feel guilty (she's sweet)
```

---

### Book Examination Phase

**Overview:**  
Before translating, examine the physical book using interactive tools. Gather clues about language type, difficulty, context. This phase is optional but helpful—skip if confident, or investigate thoroughly if cautious.

**Specifics:**
- Examination tools available:
  - **Zoom/Pan:** Click-drag to examine cover, spine, pages closely
  - **UV Light** (upgrade $500): Reveals hidden marks (ownership stamps, margin notes, invisible ink)
  - **Magnifying Glass** (default): Check paper quality, ink type, binding style
  - **Reference Catalog** (upgrade $400): Compare symbols to known language families
- Clues revealed:
  - **Age:** "Cracked leather, circa 1800s" = Old language likely
  - **Symbols on spine:** Recognize occult vs. academic vs. personal diary
  - **UV reveals:** "Previous owner: [Name]" = Context for who wrote it
  - **Condition:** Pristine = recent/fake, Damaged = authentic old
- Time investment: 30-60 seconds if thorough, 5 seconds if skip
- Not mandatory: Expert players can skip to translation immediately

**Interactions:**
- Clues inform translation strategy (know it's occult = expect ritual language)
- UV light upgrade unlocks hidden context ("Beware third passage" = warning)
- Better lamp upgrade makes examination easier (auto-highlights key details)
- Failed examination = Harder puzzle (missed clue that would've helped)

**Example Examination:**
```
[Marcus brings old book]

EXAMINE PHASE:
→ Zoom on cover: "Worn leather, symbol matches grimoire style"
→ UV light: "Ownership stamp: Aleister Crowley, 1910"
→ Magnifying glass: "Handwritten, ink consistent with early 1900s"

CONCLUSION: Occult ritual text, authentic, expect magical terminology

[Start translation knowing context]
```

---

### Customer Negotiation Phase

**Overview:**  
Before accepting a job, customer states their priorities. They want 3 things (Fast, Cheap, Accurate) but can only have 2. You negotiate which 2 they get, which affects payment, difficulty, and consequences.

**Specifics:**
- **Fast:** They need it today (you must complete before accepting next customer)
- **Cheap:** They pay 50% less ($100 becomes $50)
- **Accurate:** They demand perfection (one mistake = failed job, reputation damage)

**Negotiation options (customer picks 2):**
- **Fast + Cheap:** Low pay, must finish quickly, mistakes forgiven (easiest mode)
- **Fast + Accurate:** Normal pay, must finish quickly AND perfectly (hard mode)
- **Cheap + Accurate:** Low pay, take your time, but must be perfect (strategic mode)

**Character-driven priorities:**
```
MRS. KOWALSKI: "Take your time, dear. I just want it done right."
→ Cheap + Accurate (pays little, but patient and forgiving)

DR. CHEN: "Accuracy is critical for my research. Money isn't an issue."
→ Fast + Accurate (pays well, but high stakes)

MARCUS: "I need this fast and I'm not paying much. Client doesn't care about quality."
→ Fast + Cheap (quick job, low pay, can make mistakes)

THE STRANGER: "Fast and accurate. Money is no object."
→ Fast + Accurate (highest pay, hardest constraints—nightmare mode)
```

**Interactions:**
- Customer personality shows in priorities (Scholar cares about accuracy, Dealer cares about speed)
- Player strategy: Accept "Fast + Cheap" when low on time, "Cheap + Accurate" when need to be careful
- Moral choices: Marcus sometimes asks "Fast + Cheap + Lie" (mistranslate intentionally)
- Reputation: Consistent accuracy builds rep, mistakes damage it

---

### Money & Rent System

**Overview:**  
Track cash balance. Pay daily utilities ($30) and weekly rent ($200, due Friday). Game over if can't pay rent. Income from translation jobs, expenses from upgrades/operations.

**Specifics:**
- Starting cash: $100
- Daily expenses: $30 utilities (auto-deducted at day end)
- Weekly rent: $200 (due Friday 5pm, manual payment)
- Income per translation: 
  - Easy: $50 (normal), $25 (cheap)
  - Medium: $100 (normal), $50 (cheap)
  - Hard: $200 (normal), $100 (cheap)
- Daily capacity: 5 translations
- Daily income potential: $250-$500 (if accept high-paying jobs)
- Weekly income potential: $1,750-$3,500 (7 days × avg $250-500)
- Bankruptcy: If cash < $200 when rent due Friday → Game over

**Budget pressure:**
- Day 1 (Monday): Start with $100, earn ~$300, spend $30 utilities = $370
- Day 2-4 (Tue-Thu): Earn ~$900, spend $90 utilities = $1,180 total
- Day 5 (Friday): Must have $200 for rent, leaves $980 for upgrades
- Days 6-7 (Sat-Sun): Post-rent survival, build funds for next week

**Interactions:**
- Cash display always visible (top-right corner)
- Rent reminder appears Wednesday: "Rent due in 2 days: $200"
- Must balance: Accept high-paying jobs (but maybe wrong customers) vs. story priorities
- Upgrade timing: Buy lamp early (easier translations = faster earning) vs. save for rent?

---

### Customer Relationship System

**Overview:**  
Five recurring customer types with distinct personalities, payment rates, priorities, and story roles. Minimal dialogue (2-3 lines per appearance) but consistent characterization through negotiation choices.

**Specifics:**
- **Mrs. Kowalski** (Tutorial/Heart):
  - Appears: Days 1-3
  - Pays: $50 (always Cheap)
  - Priorities: Cheap + Accurate ("Take your time, dear")
  - Patient, sweet, gentle introduction
  - Story: Grandmother was in secret society
  
- **Dr. Sarah Chen** (Scholar/Plot):
  - Appears: Days 2-7
  - Pays: $100-150
  - Priorities: Accurate + Fast ("Critical for research")
  - Curious, intense, driven
  - Story: Researching lost civilization, realizes something is waking up

- **Marcus** (Dealer/Money):
  - Appears: Days 3-7
  - Pays: $75 (volume jobs)
  - Priorities: Fast + Cheap ("Client doesn't care about quality")
  - Rushed, businesslike, morally flexible
  - Story: Offers black market jobs, asks you to mistranslate
  
- **The Stranger** (Mystery/Finale):
  - Appears: Days 5-7
  - Pays: $200
  - Priorities: Fast + Accurate ("Everything depends on this")
  - Mysterious, terse, ominous
  - Story: Tests you, reveals conspiracy, delivers final text

- **Agent Williams** (Authority/Antagonist):
  - Appears: Days 6-7
  - Pays: $100
  - Priorities: Accurate ("Evidence for investigation")
  - Professional, pressuring, suspicious
  - Story: Government monitoring occult activity, wants you to report customers

**Dialogue per customer:**
- Greeting: 1 line (e.g., "Hello dear, I found this old book")
- Negotiation: 1 line (e.g., "Take your time, I just want it done right")
- Success: 1 line (e.g., "Oh wonderful! Thank you!")
- Failure: 1 line (e.g., "Are you sure? Doesn't seem right...")
- Story beat: 1-2 lines total per character arc

**Total dialogue:** ~4 lines per character × 5 characters = **20 unique lines**

**Interactions:**
- Refusing customer → They don't return (lose income source + story thread)
- Consistent accuracy → Tips increase, relationship improves
- Moral choice (refuse Agent Williams) → Affects ending options
- Relationship quality affects: Payment, patience, story reveals

---

### Upgrade Shop System

**Overview:**  
Buy permanent tools/services that make examination easier, reveal more clues, or increase capacity. One-time purchases (no consumables).

**Specifics:**
- **Better Lamp** ($300): 
  - Examination phase shows faded text hints (1 letter per word revealed during book exam)
  - Visual: Brighter lighting on desk
  
- **UV Light** ($500): 
  - Reveals hidden ink during examination (ownership marks, margin notes, warnings)
  - Can unlock secret text layers (plot-critical clues)
  
- **Dictionary Subscription** ($400): 
  - Auto-fills 5 most common words instantly (∆="the", ◊="old", etc. pre-filled)
  - Saves time on every translation
  
- **Coffee Machine** ($150): 
  - +1 customer capacity per day (5 slots → 6 slots)
  - More income potential, but also more work
  
- **Reference Catalog** ($600):
  - During examination, auto-identifies language family ("This matches known grimoire style")
  - Gives context before translating

**Purchase timing strategic:**
- Early lamp ($300) = Easier puzzles all week, compounds value
- Late UV light ($500) = Unlock late-game plot clues
- Coffee machine ($150) = Cheap but immediate income boost
- Save for Friday rent vs. invest in tools?

**Interactions:**
- Buy from menu between customers (doesn't consume time/slots)
- Effects immediate (buy lamp → next examination shows hints)
- Stacking synergies: Lamp + UV Light + Catalog = Maximum context before translating
- Strategic choices: Volume (coffee) vs. Quality (lamp/UV) vs. Speed (dictionary)?

---

### Dictionary Reference System

**Overview:**  
Side panel showing symbol-to-word mappings you've learned. Fills automatically when symbol used correctly 3+ times. Permanent knowledge base.

**Specifics:**
- Display: Scrollable list, left column = symbol, right column = English word
- Auto-population: After 3 correct uses of ∆ = "the", entry locks in permanently
- Hover hint: Mouse over symbol in new text → shows dictionary entry if known (green highlight)
- Confidence levels: 
  - Green = Confirmed (3+ uses, locked in)
  - Yellow = Tentative (1-2 uses, might be wrong)
  - Gray = Unknown (never seen before)
- Capacity: Holds all 20 symbols + 50 common words
- Cross-reference: Click symbol in dictionary → shows all past texts where it appeared

**Interactions:**
- Using known symbol → Instant confidence (you KNOW ∆="the")
- Unknown symbol → Must deduce from context, previous patterns
- Late-game advantage: 80% of symbols known, only decode new vocabulary
- Upgrade synergy: Dictionary Subscription pre-fills top 5, accelerates early learning
- Feels like permanent skill progression (unlike money which fluctuates)

---

### Story Progression System

**Overview:**  
Narrative revealed through translated text content + customer interactions. Each successful translation unlocks lore. Customer choices determine which story threads you follow.

**Specifics:**
- Story delivery:
  - 70% from translated text content ("the old way was forgotten" → magic existed)
  - 30% from customer dialogue (Dr. Chen: "This confirms they're waking up")
- Journal: Accessible menu, shows completed translations + connected lore
- Linear unlocks: Must serve Dr. Chen to get scholar thread, must serve Stranger for conspiracy
- Day 7 finale: The Stranger brings final text, reveals truth, sets up continuation
- Branching based on refusals: 
  - Refuse Dr. Chen → Miss civilization lore
  - Refuse Stranger → Miss conspiracy reveal
  - Refuse Agent Williams → Different ending tone

**7-Day Narrative Arc:**
- Days 1-2: Family histories, mundane texts (build comfort)
- Day 3: First mention of "old ways," hints at magic
- Days 4-5: References to "old god," something sleeping
- Day 6: Agent Williams arrives, government knows about occult activity
- Day 7: The Stranger's final text: "They are returning soon" (cliffhanger)

**Interactions:**
- Translated texts ARE the story (not separate cutscenes)
- Customer choices matter: Help scholar = learn one truth, help stranger = learn different truth
- Cross-referencing: Player can read previous translations to connect dots
- Ending setup: Day 7 creates "To be continued..." moment for full game

---

## 4. PROTOTYPE SCOPE

### What's IN (Minimum Viable)

**Core Systems:**
- Translation puzzle mechanic (type to match symbols to English, no timer)
- Limited capacity system (5 slots/day, choose from 7-10 customers)
- Book examination phase (zoom, UV light if purchased, gather clues)
- Customer negotiation (Fast/Cheap/Accurate, pick 2 of 3)
- Money tracking (cash, daily expenses $30, weekly rent $200 Friday)
- Dictionary auto-fill (symbols learned appear in reference)

**Content:**
- **7 days** (Monday through Sunday, one full week)
- **5 core texts** to translate (increasing difficulty):
  - Text 1: "the old way" (3 words, simple substitution)
  - Text 2: "the old way was forgotten" (5 words, adds grammar)
  - Text 3: "the old god sleeps" (4 words, new vocabulary)
  - Text 4: "magic was once known" (4 words, synthesis)
  - Text 5: "they are returning soon" (4 words, ominous finale)
- **3 customer types** (test relationship/choice variety):
  - Mrs. Kowalski (Days 1-3, tutorial, Cheap+Accurate)
  - Dr. Chen (Days 2-7, scholar, Accurate+Fast)
  - The Stranger (Days 5-7, mystery, Fast+Accurate, high pay)
- **7-10 customers per day** (mix of 3 recurring + random one-timers)
  - Random customers: Generic scholars, collectors, students
  - Pay $40-$120, various priorities, fill out daily queue
  - Test capacity pressure (must refuse 2-5 per day)
- **3 upgrades** (test shop progression):
  - Better Lamp ($300): Shows hints during examination
  - UV Light ($500): Reveals hidden clues
  - Coffee Machine ($150): +1 customer slot
- **20 symbol alphabet** (Unicode: ∆◊≈⊕⊗⬡∞◈⊟⊞⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩)
- **1 location** (your desk, static view, never changes)

**UI Elements:**
- Main workspace: 
  - Text display (shows symbols)
  - Input field (type English translation)
  - Submit button
  - Examination tools (zoom, UV light button if owned)
- Dictionary panel (right side): Symbol reference list
- Customer queue (left side): Today's arrivals, click to view details
- Customer dialogue box (bottom): Negotiation + reactions
- Shop UI (top bar):
  - Cash counter (top-right)
  - Day tracker (top-left, "Monday" through "Sunday")
  - Capacity used (top-center, "3/5 customers served")
- Upgrade menu (accessible between customers)

**Win Condition:**
- Survive 7 days (Monday → Sunday)
- Pay rent on Friday ($200)
- Translate the final text (Day 7)
- See "To be continued..." cliffhanger

**Lose Condition:**
- Can't pay rent Friday (cash < $200)
- Reputation drops to 0% (refuse all story customers, fail all jobs)

---

### What's OUT (Not for Prototype)

❌ **Time pressure/customer timers** (Reason: Anti-puzzle, creates stress not strategy. Tested capacity system instead)

❌ **Multiple weeks/5-week arc** (Reason: Testing core loop only, 1 week proves mechanic. Full game adds Weeks 2-5)

❌ **Marcus moral choice system** (Reason: Need to validate base loop before adding mistranslation branch. Full game adds "lie for money" choices)

❌ **Agent Williams investigation** (Reason: Introduce in prototype Day 6 but don't branch. Full game adds government pressure consequences)

❌ **Multiple endings** (Reason: Prototype ends Day 7 with cliffhanger. Full game adds 4 ending branches based on choices)

❌ **Detailed customer portraits** (Reason: Text names + minimal description sufficient for prototype. Add character art if greenlit)

❌ **Complex upgrade tree** (Reason: 3 upgrades test impact, 6+ is scope creep. Full game adds Assistant, Larger Desk, Reference Catalog)

❌ **Animation/juice** (Reason: Functional prototype first, polish later. No screen shake, particles, transitions)

❌ **Sound/music** (Reason: Focus on gameplay validation. Audio is enhancement, not proof-of-concept)

❌ **Advanced puzzle types** (Reason: Encrypted texts, multi-language mixing are later content. Prototype tests substitution + grammar)

❌ **Cross-referencing mechanic** (Reason: Requires larger text library. Full game adds "use Text A to solve Text B" puzzles)

❌ **Preservation mini-game** (Reason: Additional complexity. Full game adds fragile text restoration)

❌ **Authentication layer** (Reason: Real vs. fake detection is full game feature. Prototype assumes all texts authentic)

❌ **Ritual casting system** (Reason: Using translated spells is expansion content. Prototype focuses on translation as reward)

❌ **Hint system** (Reason: If playtesters stuck, verbal hints sufficient. Don't build help UI until puzzles validated)

❌ **Save/load** (Reason: 7-day playthrough is 60-90 minutes. Just restart if needed. Full game adds save system)

❌ **Speedrun timer** (Reason: Not testing replayability yet, just initial engagement)

❌ **Detailed reputation breakdown** (Reason: Track reputation as simple 0-100% number. Full game adds per-customer relationship meters)

❌ **Journal/codex with full lore** (Reason: Completed translations visible in list, no need for elaborate archive UI in prototype)

❌ **Client vetting phase** (Reason: See customer details before accepting, but can't refuse before seeing job. Full game adds blind refusal)

❌ **Tutorial overlays/tooltips** (Reason: Mrs. Kowalski's first job IS tutorial. Learn by doing, minimal hand-holding)

❌ **Pause menu/settings** (Reason: Can walk away from game anytime—no timers. No settings needed for prototype)

❌ **Localization** (Reason: English only for prototype, validate concept before translating)

❌ **Accessibility features** (Reason: Font size, colorblind modes are full game polish. Prototype uses default readable text)

---

## 5. SUCCESS METRICS (Post-Playtest)

### Quantitative Goals

**Capacity Management:**
- Refuse 2-5 customers per day (proves capacity matters)
- Make at least 3 "difficult" refusal choices across 7 days (proves emotional weight—refusing someone you want to help)
- Accept mix of story + money customers (proves strategic balance)

**Translation Engagement:**
- Complete 7-day run (35 total translations: 5 per day × 7 days)
- Translation accuracy: >60% correct on first try (proves puzzles solvable)
- Average time per translation: 2-5 minutes (proves difficulty balanced—not too easy/hard)
- Use dictionary reference 5+ times (proves it's useful tool)

**Shop Progression:**
- Pay Friday rent successfully (proves economy balanced)
- Purchase at least 1 upgrade by Day 5 (proves resource management engaging)
- Cash balance between $0-$500 most days (proves tension—not too easy/impossible)

**Examination Phase:**
- Use examination tools 3+ times (proves phase has value)
- Skip examination 2+ times (proves it's optional, not mandatory busywork)
- UV light upgrade purchase if comfortable (proves tools feel impactful)

### Qualitative Observations

**Translation puzzles:**
- Do you feel smart when cracking symbol meanings?
- Is solving without time pressure more satisfying than stressful?
- Do you want to translate the next text immediately after finishing one?
- Does dictionary filling feel like progression?

**Limited capacity:**
- Do you agonize over which customers to refuse?
- Do refusals feel meaningful (lose story/money/relationships)?
- Is 5 slots the right number (too few = frustrating, too many = not enough tension)?
- Do you care about individual customers beyond their payment?

**Book examination:**
- Do examination clues help with translation strategy?
- Does UV light reveal interesting context (not just cosmetic)?
- Is examination engaging texture or skippable busywork?
- Do tools feel interactive (zoom, light) or passive?

**Customer negotiation:**
- Does Fast/Cheap/Accurate framework create variety?
- Do character personalities come through in their priorities?
- Do you make different strategic choices based on your needs (rent coming vs. have money)?
- Does same text feel different under different constraints?

**Story engagement:**
- Do you care what the texts say (beyond puzzle-solving)?
- Do customer personalities emerge with minimal dialogue (<5 lines each)?
- Does Day 7 cliffhanger make you want Week 2?
- Do your customer choices affect which story threads you follow?

### Post-Playtest Questions (Ask yourself)

**After completing 7-day run, honestly answer:**

1. **Is decoding symbols satisfying without time pressure?**
   - Did you enjoy solving at your own pace?
   - Or did you wish for a timer to add urgency?
   - Score: 1-5

2. **Does limited capacity create strategic tension?**
   - Did you struggle with which 5 customers to accept?
   - Did refusals feel meaningful (not arbitrary)?
   - Score: 1-5

3. **Does book examination add engaging texture?**
   - Did you use tools to gather clues?
   - Did examination reveal useful context?
   - Score: 1-5

4. **Does negotiation (Fast/Cheap/Accurate) create variety?**
   - Did constraints make jobs feel different?
   - Did character personalities show in priorities?
   - Score: 1-5

5. **Does story emerge naturally from work?**
   - Did you piece together the occult mystery?
   - Did you care about customer relationships?
   - Score: 1-5

**Total Score: ___/25**

---

## 6. PIVOT TRIGGERS

**If prototype scores <15/25, consider:**

### **Pivot A: Remove examination phase (pure translation + choice)**
- Keep: Translation puzzles, limited capacity, negotiation
- Remove: Examination tools, UV light, clue-gathering
- Test: If examination is busywork, focus on core puzzle + customer choice

### **Pivot B: Remove negotiation (simplify to straight capacity management)**
- Keep: Translation puzzles, limited capacity, examination
- Remove: Fast/Cheap/Accurate framework
- Test: If negotiation is confusing, just focus on "who do you help" choice

### **Pivot C: Add light time pressure (hybrid)**
- Keep: Everything
- Add: Soft deadline (complete all 5 accepted jobs before end of day, not per-customer timer)
- Test: If no-timer feels too relaxed, add gentle urgency without per-puzzle stress

### **Pivot D: Pure puzzle game (no shop management)**
- Keep: Translation puzzles, story reveals
- Remove: Money, rent, capacity, refusals
- Test: If shop management is tedious, make it pure puzzle narrative game

### **Pivot E: Visual novel with puzzles**
- Keep: Translation, story, customer relationships
- Remove: Money management, daily structure
- Add: More dialogue, branching conversations
- Test: If narrative is the draw, lean into character-driven story

### **Pivot F: Different puzzle type entirely**
- Keep: Shop structure, capacity, negotiation, story
- Replace: Translation with different core activity (authentication? restoration? something else?)
- Test: If symbol-matching isn't engaging, try different puzzle mechanic

---

## 7. DEVELOPMENT PRIORITIES

### **Saturday (8 hours total):**

**Morning (4h): Translation Core**
- Symbol system (20 Unicode glyphs mapped to English words)
- 5 texts written with solutions
- Input validation (correct/incorrect checking)
- Basic dictionary display (symbols you've learned)

**Afternoon (4h): Capacity + Choice**
- Customer queue system (7-10 arrivals, choose 5)
- Customer profiles (name, payment, difficulty, priorities)
- Refusal consequences (track who you rejected)
- Money tracking (cash, expenses, rent)

### **Sunday (8 hours total):**

**Morning (4h): Examination + Negotiation**
- Book examination UI (zoom, UV light button)
- Clue reveal system (hints during examination)
- Negotiation framework (Fast/Cheap/Accurate, pick 2)
- Constraint effects (accurate = must be perfect, cheap = 50% pay)

**Afternoon (4h): Integration + Testing**
- Upgrade shop (lamp, UV, coffee machine)
- Story beats (customer dialogue, text lore reveals)
- Win/lose states (rent payment, Day 7 ending)
- Full playthrough + balance tweaks

---

**END OF PROTOTYPE DESIGN DOCUMENT**

---

**Critical Success Indicator:**  
If choosing which 5 customers to help feels agonizing (meaningful choice), and if solving puzzles without time pressure feels satisfying (contemplative not stressful), and if Day 7 cliffhanger makes you want to build Week 2—the prototype works. Build the full game.