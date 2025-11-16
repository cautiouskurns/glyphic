# PHASE 5: Progression & Polish - Feature Specifications

## Context
- **Game:** Glyphic - Translation Shop Puzzle Game
- **Phase Goal:** Full 7-day loop works, upgrades purchasable and functional, story beats appear, win condition reached
- **Estimated Duration:** 4 hours (Hours 12-16 of prototype)
- **Features in Phase:** 
  1. Upgrade Shop Menu (5.1)
  2. Better Lamp Upgrade (5.2)
  3. Coffee Machine Upgrade (5.3)
  4. Story Integration: Text Content (5.4)
  5. Story Integration: Customer Dialogue (5.5)
  6. Win Condition: Day 7 Completion (5.6)
  7. Balance Tweaking & Bug Fixes (5.7)

---

## Feature 5.1: Upgrade Shop Menu

**Priority:** MEDIUM - Optional enhancement system, can be simplified if time runs short

**Tests Critical Question:** Q3 (Book examination adds engaging texture) - Upgrades enhance examination tools

**Estimated Time:** 1.0 hours

**Dependencies:** 
- Feature 4.4 (Negotiation Constraint Effects) - Money system tracks cash for purchases
- Feature 1.1 (Game State Manager) - Stores owned upgrades

---

### Overview

A "SHOP" button in the top bar opens an overlay menu showing 3 upgrades: Better Lamp ($300), UV Light ($500), Coffee Machine ($150). Clicking an upgrade deducts cash if affordable, marks it as owned, and activates the effect immediately. This tests whether players value tools enough to spend limited cash on them instead of saving for rent.

---

### What Player Sees

**Shop Button (Top Bar):**

**Button Appearance:**
- **Position:** Top bar, right side (1400, 30) - between capacity counter and cash counter
- **Size:** 120px width × 50px height
- **Background:** #3A2518 (dark brown)
- **Text:** "SHOP" (20pt, #FFD700 gold, bold)
- **Icon:** Small shopping bag icon (24×24px) to left of text
- **Border:** 2px solid #FFD700 (gold)
- **Corner Radius:** 4px

**Visual States:**
- **Default:** Dark brown background, gold text and border
- **Hover:** Background lightens to #4A3828, border glows (3px), cursor becomes pointer
- **Disabled (During examination/translation):** Grayed out (#888888), text 50% opacity, tooltip: "Finish current task to access shop"

**Shop Menu Overlay:**

**Overlay Background:**
- **Position:** Centered on screen (510, 240)
- **Size:** 900px width × 600px height
- **Background:** #F4E8D8 (cream parchment)
- **Border:** 6px solid #3A2518 (dark brown)
- **Corner Radius:** 8px
- **Shadow:** 12px offset, 24px blur, #000000 at 50% opacity
- **Z-Index:** Renders above all UI except debug console

**Overlay Header:**
- **Position:** Top of overlay (510, 260)
- **Size:** 900px width × 80px height
- **Background:** #2B2520 (dark brown panel)
- **Title:** "SHOP - Upgrades" (36pt, #F4E8D8 cream, bold, centered)
- **Close Button:**
  - Position: Top-right corner (1350, 260)
  - Size: 60px × 60px
  - Background: #8B0000 (red)
  - Text: "✕" (32pt, white, bold)
  - Hover: Background brightens to #B30000

**Upgrade Cards (3 cards vertically stacked):**

**Card Layout:**
```
┌────────────────────────────────────────────────┐
│  [Icon]  BETTER LAMP              $300  [BUY]  │ ← Card 1
│          Reveals 1 letter per word during      │
│          examination (e.g., "t__ o__ w__")     │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│  [Icon]  UV LIGHT                 $500  [BUY]  │ ← Card 2
│          Toggle UV mode in examination to      │
│          reveal hidden ownership marks         │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│  [Icon]  COFFEE MACHINE           $150  [BUY]  │ ← Card 3
│          Increases daily capacity from 5 to 6  │
│          customers permanently                 │
└────────────────────────────────────────────────┘
```

**Card Dimensions:**
- **Size:** 860px width × 120px height
- **Spacing:** 20px vertical gap between cards
- **Position:** First card at (530, 360), second at (530, 500), third at (530, 640)
- **Background:** #FFFFFF (white)
- **Border:** 2px solid #3A2518 (dark brown)
- **Corner Radius:** 6px

**Card Content Layout:**

1. **Icon (Left):**
   - Position: x: 20 from left edge of card
   - Size: 80×80px
   - Better Lamp: Light bulb icon (yellow/gold)
   - UV Light: UV lamp icon (purple)
   - Coffee Machine: Coffee cup icon (brown)

2. **Name (Top-Center):**
   - Position: x: 120 from left edge, y: 20 from top
   - Font: 24pt, #3A2518 (dark brown), bold, uppercase

3. **Price (Top-Right):**
   - Position: x: 640 from left edge, y: 20 from top
   - Font: 28pt, #2D5016 (green), bold
   - Format: "$300" (with dollar sign)

4. **Description (Bottom-Center):**
   - Position: x: 120 from left edge, y: 50 from top
   - Font: 18pt, #666666 (gray), regular weight
   - Max width: 500px (wraps to 2 lines if needed)

5. **BUY Button (Top-Right):**
   - Position: x: 730 from left edge, y: 35 from top
   - Size: 100px × 50px
   - Background: #2D5016 (green)
   - Text: "BUY" (20pt, white, bold)
   - Border: 2px solid #1A3009 (dark green)
   - Corner Radius: 4px

**Card Visual States:**

- **Affordable (Cash ≥ Price):**
  - BUY button: Green background, white text, enabled
  - Price: Green color (#2D5016)
  - Card border: Dark brown (#3A2518)

- **Not Affordable (Cash < Price):**
  - BUY button: Grayed out (#888888), text 50% opacity, disabled
  - Price: Red color (#8B0000)
  - Card border: Red (#8B0000, 2px)
  - Tooltip on hover: "Not enough cash (need $[amount] more)"

- **Already Owned:**
  - BUY button: Hidden, replaced with green checkmark (✓) and "OWNED" text (18pt, green)
  - Card background: Light green tint (#E8F5E0)
  - Border: Green (#2D5016, 3px)
  - Icon: 20% opacity (faded, indicates already purchased)

**Player Cash Display (Shop Menu Footer):**
- **Position:** Bottom of overlay (510, 780)
- **Size:** 900px width × 60px height
- **Background:** #2B2520 (dark brown panel)
- **Text:** "Your Cash: $250" (24pt, #2D5016 green if affordable, #8B0000 red if insufficient, bold, centered)

---

### What Player Does

**Opening Shop:**

**Input:** Click "SHOP" button in top bar

**Immediate Response:**
1. **T+0.0s:** Button flashes gold
2. **T+0.1s:** Screen dims (semi-transparent black overlay 40% opacity)
3. **T+0.2s:** Shop menu scales in from 80% to 100% (0.2s ease-out animation)
4. **T+0.4s:** Shop menu fully visible, cards displayed
5. **Player reads:** 3 upgrade cards with prices, descriptions, BUY buttons
6. **Player checks:** Cash display at bottom shows current cash ($250)

**Purchasing Upgrade:**

**Scenario: Buy Coffee Machine ($150) with $250 cash**

**Input:** Click "BUY" button on Coffee Machine card

**Immediate Response:**
1. **T+0.0s:** BUY button flashes white
2. **T+0.1s:** Cash display updates: "$250" → "$100" (red flash on decrement)
3. **T+0.2s:** BUY button disappears, replaced with "✓ OWNED" (green)
4. **T+0.3s:** Card background changes to light green tint (#E8F5E0)
5. **T+0.4s:** Card border changes to green (#2D5016, 3px)
6. **T+0.5s:** Icon fades to 20% opacity
7. **T+0.6s:** Other cards update affordability (if cash now < price, BUY buttons disable)
8. **Player sees:** Coffee Machine owned, cash = $100, other upgrades now unaffordable

**Closing Shop:**

**Input:** Click close button (✕) or press Escape

**Immediate Response:**
1. **T+0.0s:** Close button flashes white
2. **T+0.1s:** Shop menu scales out from 100% to 80% (0.15s ease-in animation)
3. **T+0.25s:** Screen overlay fades out
4. **T+0.3s:** Game resumes, player can interact with main UI

**Feedback Loop:**

1. **Player action:** Clicks "SHOP" button (has $500 cash)
2. **Visual change:** Shop menu opens, shows 3 upgrades
3. **Player observation:** UV Light costs $500, exactly what I have
4. **Player decision:** Buy UV Light now for examination help, or save for rent ($200 due Friday)?
5. **Player action:** Clicks "BUY" on UV Light
6. **Visual change:** Cash drops to $0, UV Light shows "OWNED", other upgrades disable (unaffordable)
7. **System response:** GameState.upgrades["UV Light"] = true, GameState.cash = 0
8. **Next player decision:** Close shop, accept next customer, UV button will appear in examination

**Example Interaction Flow:**
```
Day 2, player has $250 cash, considering upgrades
→ Player clicks "SHOP" button in top bar
→ Shop menu opens with 3 upgrade cards
→ Player reads:
   - Better Lamp: $300 (red price, unaffordable, BUY button grayed)
   - UV Light: $500 (red price, unaffordable, BUY button grayed)
   - Coffee Machine: $150 (green price, affordable, BUY button enabled)
→ Player thinks: "Coffee Machine lets me serve 6 customers = more money per day"
→ Player clicks "BUY" on Coffee Machine
→ BUY button flashes, cash updates: $250 → $100
→ Coffee Machine card shows "✓ OWNED" (green checkmark)
→ Player sees: Now have $100 left, other upgrades still unaffordable
→ Player clicks close button (✕)
→ Shop menu closes, returns to main game
→ Player continues Day 2 with Coffee Machine owned
→ Next day (Day 3): Capacity counter shows "0/6" instead of "0/5"
```

---

### Acceptance Criteria

**Visual Checks (Shop Button):**
- [ ] "SHOP" button appears in top bar at (1400, 30) with 120×50px dimensions
- [ ] Button has dark brown background (#3A2518), gold text (#FFD700), shopping bag icon
- [ ] Hover button → background lightens, border glows gold (3px)
- [ ] Button disabled during examination/translation (grayed out, tooltip explains why)

**Visual Checks (Shop Menu Overlay):**
- [ ] Shop menu appears centered (510, 240) with 900×600px dimensions
- [ ] Overlay has cream background (#F4E8D8), dark brown border (6px), shadow
- [ ] Header shows "SHOP - Upgrades" title (36pt cream, centered)
- [ ] Close button (✕) appears in top-right corner (60×60px, red background)
- [ ] Three upgrade cards displayed vertically with 20px gaps

**Visual Checks (Upgrade Cards):**
- [ ] Each card is 860×120px with white background, dark brown border
- [ ] Card shows: icon (80×80px left), name (24pt bold), price (28pt green), description (18pt gray), BUY button (100×50px green)
- [ ] Better Lamp card: Light bulb icon, "$300", "Reveals 1 letter per word during examination"
- [ ] UV Light card: UV lamp icon, "$500", "Toggle UV mode in examination to reveal hidden ownership marks"
- [ ] Coffee Machine card: Coffee cup icon, "$150", "Increases daily capacity from 5 to 6 customers permanently"

**Visual Checks (Affordability States):**
- [ ] If cash ≥ price: BUY button enabled (green), price in green (#2D5016)
- [ ] If cash < price: BUY button disabled (gray), price in red (#8B0000), card border red
- [ ] Tooltip on unaffordable card: "Not enough cash (need $[X] more)" where X = price - cash
- [ ] Example: $250 cash, $300 item → tooltip says "need $50 more"

**Visual Checks (Owned State):**
- [ ] After purchase: BUY button replaced with "✓ OWNED" (18pt green)
- [ ] Card background changes to light green (#E8F5E0)
- [ ] Card border changes to green (#2D5016, 3px)
- [ ] Icon fades to 20% opacity (grayed/faded effect)
- [ ] Owned upgrade cannot be purchased again (button gone)

**Interaction Checks:**
- [ ] Click "SHOP" button → menu opens within 0.4s (scale-in animation)
- [ ] Click "BUY" on affordable upgrade → cash deducts immediately, card shows "OWNED"
- [ ] Click "BUY" on unaffordable upgrade → nothing happens (button disabled)
- [ ] Purchase upgrade → other cards update affordability based on new cash amount
- [ ] Click close button (✕) → menu closes within 0.3s (scale-out animation)
- [ ] Press Escape → same result as clicking close button
- [ ] Click outside menu overlay (on dimmed game screen) → menu closes
- [ ] Rapid clicking BUY button doesn't cause double-purchase or negative cash

**Functional Checks:**
- [ ] Purchase calculation: `if GameState.cash >= upgrade.price → GameState.cash -= upgrade.price, GameState.upgrades[upgrade.name] = true`
- [ ] Better Lamp: Price = $300, effect activates in Feature 5.2
- [ ] UV Light: Price = $500, effect activates in Feature 4.2 (UV button appears)
- [ ] Coffee Machine: Price = $150, effect activates in Feature 5.3 (capacity becomes 6)
- [ ] Cash display updates in real-time: Purchase $150 item with $250 → display shows "$100" immediately
- [ ] Owned upgrades persist across days: Buy Coffee Machine Day 2 → still owned Day 3-7
- [ ] Edge case: Buy Coffee Machine with exactly $150 cash → cash becomes $0, other upgrades disable
- [ ] Edge case: Buy all 3 upgrades across multiple days → all show "OWNED", no BUY buttons visible
- [ ] Edge case: Open shop with $0 cash → all upgrades show red prices, all BUY buttons disabled
- [ ] Integration: GameState.upgrades dictionary stores owned upgrades (["Better Lamp": true, "UV Light": false, "Coffee Machine": false])
- [ ] Integration: Cash deduction uses same system as rent/utilities (GameState.cash -= amount)

**Polish Checks (if time permits):**
- [ ] Shop menu scale-in/out animation is smooth (ease curves, not linear)
- [ ] Cash decrement shows floating "-$150" red text briefly above cash display
- [ ] Purchase plays satisfying sound effect (cash register "ding")
- [ ] Owned upgrades have subtle checkmark bounce-in animation
- [ ] Card hover highlights slightly (brighten background 10%)

---

## Feature 5.2: Better Lamp Upgrade

**Priority:** LOW - Optional examination enhancement, can be cut if time runs short

**Tests Critical Question:** Q3 (Book examination adds engaging texture) - Tests if hints make examination more valuable

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 5.1 (Upgrade Shop Menu) - Better Lamp must be purchased first
- Feature 4.1 (Book Examination Phase) - Hints appear during examination

---

### Overview

After purchasing Better Lamp ($300), the examination phase shows faded text hints overlaid on the book texture. For solution "the old way", hints appear as "t__ o__ w__" (first letter of each word revealed, rest as underscores). This tests whether partial hints enhance puzzle-solving or make it too easy.

---

### What Player Sees

**Hint Overlay (During Examination):**

**Trigger:** Better Lamp purchased, player examines book

**Hint Text Appearance:**
- **Position:** Overlaid on book cover, center area (960, 540) - centered on book texture
- **Size:** Auto-sized based on solution length (scales to fit book width)
- **Font:** 32pt, #FFD700 (gold), semi-transparent (40% opacity), monospace (fixed-width for underscores)
- **Background:** Semi-transparent #000000 (20% opacity, 8px padding around text)
- **Shadow:** 2px offset, 4px blur, #000000 at 60% opacity (makes text readable on varying backgrounds)
- **Format:** First letter of each word visible, rest as underscores with spaces between words
  - Example: "the old way" → "t__ o__ w__"
  - Example: "they are returning soon" → "t___ a__ r________ s___"

**Visual Integration:**
- Hints appear faded/ghostly on book cover (not jarring or overly prominent)
- Zoom inset shows hints at 2× magnification (easier to read small letters)
- Hints do NOT appear if Better Lamp not purchased (clean book texture only)

**Visual States:**
- **Better Lamp Owned:** Hints visible (gold semi-transparent text)
- **Better Lamp Not Owned:** No hints (clean book texture, normal examination)
- **UV Mode + Better Lamp:** Both hints and UV hidden text visible simultaneously (layered)

---

### What Player Does

**Player Experience with Better Lamp:**

**Scenario: Player purchases Better Lamp, examines next book**

**Input:** Accept customer after purchasing Better Lamp

**Immediate Response:**
1. **T+0.0s:** Examination screen appears (normal book examination flow)
2. **T+0.3s:** Book texture loads
3. **T+0.5s:** Hint text fades in over book cover: "t__ o__ w__" (gold, semi-transparent)
4. **Player reads hints:** "First letters are t, o, w... solution starts with those letters"
5. **Player uses zoom:** Magnifies hint area, sees "t__ o__ w__" at 2× size (clearer)
6. **Player thinks:** "Three words starting with t, o, w... 'the old way' maybe?"
7. **Player clicks Skip:** Proceeds to translation workspace
8. **Player translates:** Uses hints as starting point, completes "the old way"

**Feedback Loop:**

1. **Player action:** Examines book with Better Lamp owned
2. **Visual change:** Faded gold hints appear: "t__ o__ w__"
3. **Player observation:** "First letter of each word revealed... helpful but not complete answer"
4. **System response:** Examination.show_hints(solution) generates hint format from solution text
5. **Next player decision:** Use hints as clues during translation, or ignore and solve independently

**Example Interaction Flow:**
```
Player purchases Better Lamp for $300 (Day 2)
→ Player accepts Dr. Chen (Text 2 solution: "ancient ritual words")
→ Examination screen appears
→ Hint text fades in on book cover: "a______ r_____ w____" (first letters visible)
→ Player uses zoom to magnify hint area
→ Zoom inset shows: "a______ r_____ w____" at 2× size
→ Player reads: "a, r, w... three words"
→ Player thinks: "Could be 'ancient ritual words' or 'arcane ritual ways'?"
→ Player clicks Skip, proceeds to translation
→ Translation workspace shows symbols: "⊕∞◈ ⊗⊤⊥ ⊢⊣⊨"
→ Player uses hints to narrow down possibilities
→ Player tests "ancient ritual words" → Correct!
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Hint text appears overlaid on book cover during examination (if Better Lamp owned)
- [ ] Hints display at (960, 540) centered on book texture
- [ ] Hints use 32pt gold font (#FFD700) at 40% opacity (semi-transparent/faded)
- [ ] Hints have semi-transparent black background (20% opacity, 8px padding)
- [ ] Hints show first letter of each word + underscores for remaining letters
- [ ] Spaces between words preserved: "t__ o__ w__" (not "t__o__w__")
- [ ] Zoom inset shows hints at 2× magnification (readable when zoomed)

**Visual Checks (Hint Format Examples):**
- [ ] "the old way" → "t__ o__ w__"
- [ ] "ancient ritual words" → "a______ r_____ w____"
- [ ] "they are returning soon" → "t___ a__ r________ s___"
- [ ] "the old god sleeps" → "t__ o__ g__ s_____"
- [ ] Single letter words preserved: "I am here" → "I a_ h___"

**Interaction Checks:**
- [ ] Purchase Better Lamp → next examination shows hints (effect activates immediately)
- [ ] Examine book without Better Lamp → no hints appear (clean book texture)
- [ ] Use zoom over hint area → hints visible at 2× magnification in inset panel
- [ ] Toggle UV mode (if UV Light also owned) → hints and UV text both visible (layered)
- [ ] Hints do not block book texture details (semi-transparent, can see through them)

**Functional Checks:**
- [ ] Hint generation: `hint = solution.split().map(word => word[0] + "_".repeat(word.length - 1)).join(" ")`
- [ ] Example: "the old way".split() = ["the", "old", "way"]
  - "the" → "t" + "__" = "t__"
  - "old" → "o" + "__" = "o__"
  - "way" → "w" + "__" = "w__"
  - Result: "t__ o__ w__"
- [ ] Hints only appear if GameState.upgrades["Better Lamp"] == true
- [ ] Hints derive from translation solution text stored in CustomerData.texts[text_id].solution
- [ ] Edge case: Solution with punctuation: "it's here!" → "i___ h____" (ignore punctuation in hint)
- [ ] Edge case: Solution with numbers: "7 days left" → "7 d___ l___" (preserve numbers)
- [ ] Edge case: Very long words: "incomprehensible" → "i______________" (14 underscores)
- [ ] Integration: Examination.show_hints() called only if Better Lamp owned
- [ ] Integration: Hints do not affect translation validation (purely visual aid)

**Polish Checks (if time permits):**
- [ ] Hints fade in smoothly (0.3s transition, not instant)
- [ ] Hints have subtle glow effect (makes gold text stand out)
- [ ] Monospace font ensures underscores align properly (not proportional spacing)
- [ ] Hint text scales dynamically for long solutions (doesn't overflow book area)

---

## Feature 5.3: Coffee Machine Upgrade

**Priority:** MEDIUM - Mechanical capacity increase, tests economic trade-off

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Tests if players value 6th slot

**Estimated Time:** 0.25 hours

**Dependencies:** 
- Feature 5.1 (Upgrade Shop Menu) - Coffee Machine must be purchased first
- Feature 3.4 (Capacity Enforcement) - Modifies max capacity from 5 to 6

---

### Overview

After purchasing Coffee Machine ($150), daily capacity increases from 5 to 6 customers permanently. The capacity counter updates to "0/6" instead of "0/5", and players can accept 6 customers before hitting the limit. This tests whether the 6th slot is valuable enough to justify the $150 cost (especially considering rent deadline).

---

### What Player Sees

**Capacity Counter Update:**

**Before Coffee Machine:**
- **Text:** "0/5 Customers Served" (24pt, gray)
- **Max Capacity:** 5 customers per day

**After Coffee Machine Purchased:**
- **Text:** "0/6 Customers Served" (24pt, gray)
- **Max Capacity:** 6 customers per day
- **Icon:** Small coffee cup icon (20×20px) appears next to counter (indicates upgrade active)
- **Tooltip (on hover):** "Coffee Machine active (+1 capacity)"

**Visual Changes at 5/6 vs 5/5:**

**Without Coffee Machine (5/5 capacity):**
- Counter shows: "5/5 Customers Served" (green)
- Lock icon appears (capacity full)
- Remaining customers auto-refuse

**With Coffee Machine (5/6 capacity):**
- Counter shows: "5/6 Customers Served" (orange - almost full, not green yet)
- No lock icon (still room for 1 more)
- Can accept 1 more customer
- At 6/6: Counter shows "6/6 Customers Served" (green), lock icon appears

**Color Logic (Capacity Counter):**
- **0-4/6:** Gray (#888888) - "plenty of room"
- **5/6:** Orange (#FF8C00) - "almost full"
- **6/6:** Green (#2D5016) - "capacity met"

---

### What Player Does

**Player Experience with Coffee Machine:**

**Scenario: Purchase Coffee Machine, test capacity increase**

**Day Before Purchase:**
1. Player serves 5 customers on Day 2
2. Capacity shows "5/5" (green), remaining customers auto-refuse
3. Player earns money, has $200 by end of day

**Purchase Day:**
1. Day 3 starts, player has $200 cash
2. Player opens shop, sees Coffee Machine ($150)
3. Player thinks: "6 customers = 1 extra job per day = +$50-200 per day"
4. Player buys Coffee Machine ($150), cash becomes $50
5. Player closes shop

**Next Day (Day 4):**
1. Day 4 starts, capacity counter shows: "0/6 Customers Served" (gray)
2. Coffee cup icon appears next to counter
3. Player accepts 5 customers → counter shows "5/6" (orange, not green)
4. Player can click 6th customer card, accept them
5. Counter updates: "6/6" (green), lock icon appears
6. Player completes 6 translations instead of 5
7. Player earns ~$100-300 more than without Coffee Machine (depending on customer mix)

**Feedback Loop:**

1. **Player action:** Purchases Coffee Machine for $150
2. **Visual change:** Capacity counter updates to "0/6" next day, coffee cup icon appears
3. **System response:** GameState.max_capacity = 6 (was 5)
4. **Player observation:** "I can serve 6 customers now instead of 5"
5. **Next player decision:** Accept 6 customers to maximize daily earnings, or stop at 5 to save time

**Example Interaction Flow:**
```
Day 3, player has $200 cash, considering Coffee Machine
→ Player opens shop, sees Coffee Machine: $150
→ Player calculates: "6 customers × $100 avg = $600/day vs 5 × $100 = $500/day"
→ Player calculates: "Extra $100/day × 4 days left = $400 total gain"
→ Player calculates: "Investment: $150, Return: $400, Profit: $250"
→ Player buys Coffee Machine, cash: $200 → $50
→ Day 4 starts, capacity shows "0/6" with coffee cup icon
→ Player accepts 6 customers (was limited to 5 before)
→ Customer 6: Dr. Chen ($100, Medium difficulty)
→ Player completes all 6 translations, earns $600 total (was $500 max before)
→ Day 5 (Friday), player has $650 cash (easily affords $200 rent)
→ Coffee Machine paid for itself: $150 cost, $300 extra earned (6th customer Days 4-5)
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] After purchasing Coffee Machine, capacity counter shows "X/6" instead of "X/5"
- [ ] Coffee cup icon (20×20px) appears next to capacity counter
- [ ] Icon tooltip: "Coffee Machine active (+1 capacity)"
- [ ] At 5/6 capacity: Counter is orange (#FF8C00), no lock icon (can accept 1 more)
- [ ] At 6/6 capacity: Counter is green (#2D5016), lock icon appears (capacity full)

**Interaction Checks:**
- [ ] Purchase Coffee Machine → next day starts with "0/6" capacity (not "0/5")
- [ ] Accept 5 customers → counter shows "5/6" (orange), can accept 1 more
- [ ] Accept 6th customer → counter shows "6/6" (green), remaining customers auto-refuse
- [ ] Try accepting 7th customer → popup opens, ACCEPT button disabled (capacity full tooltip)
- [ ] Coffee Machine effect persists across all remaining days (doesn't reset)

**Functional Checks:**
- [ ] GameState.max_capacity = 6 after Coffee Machine purchased (was 5)
- [ ] Capacity enforcement: `if GameState.capacity_used >= GameState.max_capacity → disable accept`
- [ ] Auto-refuse logic triggers at 6/6 (not 5/5) with Coffee Machine
- [ ] Revenue calculation: 6 customers × $100 avg = $600/day (vs 5 × $100 = $500 without Coffee Machine)
- [ ] Edge case: Purchase Coffee Machine mid-day (after accepting 3 customers) → max_capacity updates immediately, can accept 3 more (6 total)
- [ ] Edge case: Purchase Coffee Machine on Day 7 (last day) → still works, can accept 6 customers on Day 7
- [ ] Edge case: Buy Coffee Machine with exactly $150 → cash becomes $0, effect still activates
- [ ] Integration: Feature 3.4 (Capacity Enforcement) reads GameState.max_capacity (not hardcoded 5)
- [ ] Integration: Feature 3.3 (Accept Logic) increments capacity_used, checks against max_capacity

**Polish Checks (if time permits):**
- [ ] Coffee cup icon has subtle steam animation (3-frame loop)
- [ ] Purchasing Coffee Machine plays coffee brewing sound effect
- [ ] At 5/6, counter pulses orange briefly (indicates "almost full, 1 more slot")
- [ ] Tooltip explains economic benefit: "Serve 6 customers = +$100-200 per day"

---

## Feature 5.4: Story Integration: Text Content

**Priority:** MEDIUM - Enhances narrative experience, but can be simplified if time runs short

**Tests Critical Question:** Q5 (Story emerges naturally from translations) - Tests if lore snippets create engagement

**Estimated Time:** 0.75 hours

**Dependencies:** 
- Feature 2.4 (Translation Validation) - Lore snippets appear after successful translation
- Feature 1.4 (Customer Data Structures) - Translation texts include lore metadata

---

### Overview

After successfully translating a text, a lore snippet (30-50 words) appears in the dialogue box, revealing story context. Text 1-2 show mundane family history, Text 3 introduces ominous "old god" references, Text 5 ends with cliffhanger: "they are returning soon". This tests whether story emerges naturally from puzzle solutions or feels tacked-on.

---

### What Player Sees

**Lore Snippet Display (Dialogue Box):**

**Trigger:** Player submits correct translation

**Visual Sequence:**
1. **T+0.0s:** Validation success → green checkmark appears
2. **T+0.2s:** Current dialogue fades out
3. **T+0.3s:** Lore snippet fades in (0.2s transition)
4. **T+0.5s:** Lore snippet fully visible in dialogue box

**Dialogue Box Layout:**

**Before Lore Snippet:**
- **Text:** "Translation correct! Customer pays you $50." (18pt, #2D5016 green)

**After Lore Snippet:**
- **Customer Reaction (First Line):**
  - Text: "[Customer Name] reads the translation..." (20pt, #3A2518 dark brown, italic)
  - Example: "Mrs. Kowalski reads the translation, eyes widening..."
- **Lore Snippet (Main Content):**
  - Text: 30-50 word lore paragraph (18pt, #3A2518 dark brown, regular weight)
  - Background: Light cream highlight (#F4E8D8 at 50% opacity behind text)
  - Border: Subtle 1px solid #3A2518 (left border only, 4px from text edge)
  - Format: 2-3 sentences, double-spaced lines for readability

**Lore Snippet Content Examples:**

**Text 1 (Day 1, Mrs. Kowalski - "the old way"):**
```
Mrs. Kowalski reads the translation, eyes misty with nostalgia...

"My grandmother's journal... she wrote about the old family traditions. 
Simple rituals passed down through generations. Nothing unusual, just 
memories of simpler times."
```

**Text 2 (Day 2, Dr. Chen - "ancient ritual words"):**
```
Dr. Chen studies the translation carefully, making notes...

"Fascinating. This references pre-colonial ceremonial practices. The 
wording suggests these weren't mere superstitions—people believed these 
rituals had real power. I need to investigate further."
```

**Text 3 (Day 3, Random Customer - "the old god sleeps"):**
```
The customer's hands tremble as you read the translation aloud...

"This mentions an 'old god'... something sleeping beneath the city? The 
text is fragmentary, but it implies something was deliberately put to 
rest long ago. What were our ancestors trying to contain?"
```

**Text 4 (Days 4-6, Dr. Chen - "symbols of awakening"):**
```
Dr. Chen gasps, dropping the book in shock...

"These are awakening symbols! The old texts warned of signs that precede 
the god's return. If these symbols are appearing now... we may be running 
out of time. The city is in danger."
```

**Text 5 (Day 7, The Stranger - "they are returning soon"):**
```
The Stranger reads your translation, then looks directly into your eyes...

"Just as I feared. They are returning soon. The old god stirs beneath us, 
and its servants awaken. You've done your part—now you must decide: flee 
the city, or stay and face what comes."

*He leaves without another word, disappearing into the night.*
```

**Visual States:**
- **Mundane Lore (Texts 1-2):** Normal dialogue box colors, calm tone
- **Ominous Lore (Text 3):** Dialogue box border subtly darkens to #8B4513 (saddle brown)
- **Urgent Lore (Text 4):** Customer name in red (#8B0000), exclamation points
- **Cliffhanger Lore (Text 5):** Dialogue box border flashes dark red (0.5s pulse), italic final line

---

### What Player Does

**Player Experience - Story Progression:**

**Day 1 (Text 1):**
1. Player translates "the old way" correctly
2. Lore snippet appears: Mrs. K's grandmother's journal, old family traditions
3. Player thinks: "Okay, mundane family history. Nothing weird yet."

**Day 2 (Text 2):**
1. Player translates "ancient ritual words" correctly
2. Lore snippet: Dr. Chen notes "people believed rituals had real power"
3. Player thinks: "Starting to sound interesting... magic was real?"

**Day 3 (Text 3 - Ominous Shift):**
1. Player translates "the old god sleeps" correctly
2. Lore snippet: "Something sleeping beneath the city... deliberately put to rest"
3. Dialogue box border darkens slightly (visual cue: tone shift)
4. Player thinks: "Whoa, this just got creepy. Old god? Beneath the city?"

**Days 4-6 (Text 4):**
1. Player translates "symbols of awakening" correctly
2. Dr. Chen gasps in shock, warns "city is in danger"
3. Player thinks: "This is escalating. The god is waking up?!"

**Day 7 (Text 5 - Cliffhanger):**
1. Player translates "they are returning soon" correctly
2. The Stranger reveals: "Old god stirs, servants awaken"
3. Final line: "Flee or stay and face what comes" (italic, mysterious)
4. Dialogue box border flashes dark red
5. Player thinks: "WHAT?! That's the ending? I need to know what happens!"

**Feedback Loop:**

1. **Player action:** Submits correct translation
2. **Visual change:** Lore snippet fades into dialogue box
3. **Player observation:** Reads customer reaction + lore paragraph
4. **System response:** TranslationWorkspace.show_lore(text_id) fetches lore from CustomerData
5. **Next player decision:** Continue translating (curious about next story reveal), or focus purely on money

**Example Interaction Flow:**
```
Player completes Text 3 translation: "the old god sleeps"
→ Green checkmark appears (validation success)
→ Current dialogue fades out
→ New dialogue fades in:
   "The customer's hands tremble as you read the translation aloud..."
   "This mentions an 'old god'... something sleeping beneath the city?"
→ Player reads lore, notices dialogue box border darkened (subtle ominous cue)
→ Player thinks: "This went from family histories to ancient gods sleeping under the city"
→ Player clicks next customer to continue day
→ Later, player reflects: "I wonder if the next translations reveal more about this god..."
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] After correct translation, lore snippet appears in dialogue box (fades in over 0.2s)
- [ ] Customer reaction line appears first (20pt italic): "[Name] reads the translation..."
- [ ] Lore snippet paragraph appears below (18pt regular, 30-50 words)
- [ ] Lore text has light cream highlight background (50% opacity)
- [ ] Subtle left border (1px solid dark brown, 4px from text) frames lore snippet

**Visual Checks (Story Progression):**
- [ ] Text 1 lore: Mundane family history, "old family traditions", calm tone
- [ ] Text 2 lore: Ritual references, "people believed rituals had real power"
- [ ] Text 3 lore: "Old god sleeps beneath the city", dialogue box border darkens (#8B4513)
- [ ] Text 4 lore: Dr. Chen gasps, "awakening symbols", "city is in danger", urgent tone
- [ ] Text 5 lore: The Stranger, "they are returning soon", cliffhanger, dialogue box border flashes dark red

**Interaction Checks:**
- [ ] Submit correct translation → lore snippet appears within 0.5s
- [ ] Submit incorrect translation → no lore snippet (only failure message)
- [ ] Lore snippet remains visible until next customer accepted or day ends (doesn't auto-dismiss)
- [ ] Accepting next customer clears lore snippet, shows new customer greeting

**Functional Checks:**
- [ ] Lore snippets stored in CustomerData.texts[text_id].lore field
- [ ] Text 1 lore: "My grandmother's journal... old family traditions. Nothing unusual."
- [ ] Text 2 lore: "Pre-colonial ceremonial practices... people believed rituals had real power."
- [ ] Text 3 lore: "This mentions an 'old god'... something sleeping beneath the city?"
- [ ] Text 4 lore: "These are awakening symbols! The old god stirs... city is in danger."
- [ ] Text 5 lore: "They are returning soon. The old god stirs... flee or stay and face what comes."
- [ ] Lore snippet length: 30-50 words (2-3 sentences)
- [ ] Edge case: Same text completed multiple times (different customers, same text) → same lore snippet appears each time
- [ ] Edge case: Skip translation (fail and move on) → no lore snippet shown (only on success)
- [ ] Integration: TranslationValidation.on_success() triggers lore display
- [ ] Integration: Lore content references customer who provided the text (Mrs. K for Text 1, Dr. Chen for Text 2, etc.)

**Polish Checks (if time permits):**
- [ ] Text 3+ lore snippets have subtle darkening effect on dialogue box (visual tone shift)
- [ ] Text 5 final line in italic + darker color (emphasizes cliffhanger)
- [ ] Customer reaction animations: Mrs. K "eyes misty", Dr. Chen "gasps", Stranger "looks into your eyes"
- [ ] Lore text uses varying sentence structures (not all identical format)

---

## Feature 5.5: Story Integration: Customer Dialogue

**Priority:** MEDIUM - Adds relationship depth, but can be simplified to generic dialogue

**Tests Critical Question:** Q5 (Story emerges naturally) + Q2 (Relationship consequences) - Dynamic dialogue reflects player choices

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 3.5 (Customer Relationship Tracking) - Dialogue references acceptance/refusal history
- Feature 3.6 (Daily Queue Generation) - Recurring customers remember past interactions

---

### Overview

Customer dialogue changes based on relationship history and current day. Mrs. Kowalski's Day 2 greeting references "wonderful work yesterday" if accepted Day 1, or generic greeting if first meeting. Dr. Chen's Day 6 dialogue escalates urgency: "We're running out of time." This tests whether dynamic dialogue creates emotional connection to recurring customers.

---

### What Player Sees

**Dynamic Dialogue Examples:**

**Mrs. Kowalski - Day 1 (First Meeting):**
- **Greeting:** "Hello dear, I found this old family book in my attic. Can you help me read it?"
- **Tone:** Polite, unfamiliar, generic

**Mrs. Kowalski - Day 2 (If Accepted Day 1):**
- **Greeting:** "Oh, it's you! You did such wonderful work on grandmother's journal yesterday. I found another heirloom that needs translating."
- **Tone:** Warm, familiar, references past success

**Mrs. Kowalski - Day 2 (If Refused Day 1):**
- **Greeting:** "I had to find someone else for that first book, but they weren't very good. Would you be willing to help me this time?"
- **Tone:** Hopeful, slight disappointment, second chance

**Mrs. Kowalski - Day 3 (If Refused Twice):**
- **Does NOT Appear:** Relationship broken, removed from queue
- **Alternative:** If only refused once, she appears with: "This is my last heirloom. I hope you can help this time."

**Dr. Chen - Day 2 (First Meeting):**
- **Greeting:** "I'm researching pre-colonial texts. I need this translated urgently for my thesis. Can you help?"
- **Tone:** Professional, urgent, business-like

**Dr. Chen - Day 3 (If Accepted Day 2):**
- **Greeting:** "Your translation yesterday was excellent. I have more texts from the same source—this research is becoming quite alarming."
- **Tone:** Appreciative, escalating concern

**Dr. Chen - Day 6 (Story Escalation):**
- **Greeting:** "This confirms my fears. The symbols are appearing faster now. We're running out of time. I need you to translate this immediately."
- **Tone:** Panicked, urgent, high stakes

**The Stranger - Day 5 (First Appearance):**
- **Greeting:** "*A hooded figure places an ancient tome on your desk without a word.*"
- **Tone:** Mysterious, silent, ominous

**The Stranger - Day 7 (Final Text):**
- **Greeting:** "*He returns, eyes burning with intensity. This is the last text.*"
- **Success Lore:** "They are returning soon. You've done your part—now decide: flee or stay."
- **Tone:** Apocalyptic, cliffhanger

**Dialogue Variants Based on Relationship:**

| Customer | Day | Condition | Greeting |
|----------|-----|-----------|----------|
| Mrs. K | 1 | First meeting | "Hello dear, I found this old family book..." |
| Mrs. K | 2 | Accepted Day 1 | "You did wonderful work yesterday! Another heirloom..." |
| Mrs. K | 2 | Refused Day 1 | "I found someone else, but they weren't good. Will you help?" |
| Mrs. K | 3 | Refused 2× | *Does not appear* (relationship broken) |
| Dr. Chen | 2 | First meeting | "I'm researching pre-colonial texts. Need this urgently..." |
| Dr. Chen | 3 | Accepted Day 2 | "Your translation was excellent. More alarming texts..." |
| Dr. Chen | 6 | Story beat | "Confirms my fears. Symbols appearing faster. Running out of time!" |
| Stranger | 5 | First appearance | "*Hooded figure places ancient tome without a word.*" |
| Stranger | 7 | Final text | "*He returns, eyes burning. This is the last text.*" |

---

### What Player Does

**Player Experience - Relationship-Based Dialogue:**

**Scenario A: Accept Mrs. Kowalski Consistently**

**Day 1:**
1. Mrs. K appears: "Hello dear, I found this old family book..."
2. Player accepts, translates successfully
3. Mrs. K pays $25 (Cheap priority): "Thank you so much, dear!"

**Day 2:**
1. Mrs. K appears again: "You did wonderful work yesterday! Another heirloom..."
2. Player thinks: "She remembers me! This feels personal."
3. Player accepts again (building relationship)

**Day 3:**
1. Mrs. K appears: "You've been so helpful. This is my last family book."
2. Player thinks: "I've helped her through all her family heirlooms. Nice closure."

**Scenario B: Refuse Mrs. Kowalski Once, Accept Later**

**Day 1:**
1. Mrs. K appears: "Hello dear, I found this old family book..."
2. Player refuses (prioritizing higher-paying customers)

**Day 2:**
1. Mrs. K appears: "I found someone else, but they weren't very good. Will you help?"
2. Player thinks: "She's giving me a second chance. I feel a bit guilty for refusing before."
3. Player accepts (redemption opportunity)

**Day 3:**
1. Mrs. K appears: "I'm glad you helped last time. Here's another..."
2. Relationship continues (forgiven for Day 1 refusal)

**Scenario C: Dr. Chen Story Escalation**

**Day 2:**
1. Dr. Chen: "I'm researching pre-colonial texts. Need this urgently for my thesis."
2. Player translates: "ancient ritual words"
3. Lore snippet: "People believed rituals had real power"

**Day 3:**
1. Dr. Chen: "Your translation was excellent. More alarming texts..."
2. Player translates: "the old god sleeps"
3. Lore snippet: "Something sleeping beneath the city?"
4. Dr. Chen's dialogue shifts from academic curiosity to concern

**Day 6:**
1. Dr. Chen: "Confirms my fears. Symbols appearing faster. Running out of time!"
2. Dialogue tone: Panic, urgency
3. Player thinks: "The story is escalating. Dr. Chen went from calm researcher to panicked whistleblower."

**Feedback Loop:**

1. **Player action:** Accepts/refuses customer
2. **Visual change:** Customer dialogue updates to reference past interaction
3. **System response:** CustomerData.get_dialogue(customer_id, day, relationship_status)
4. **Player observation:** "They remember what I did before. My choices matter."
5. **Next player decision:** Continue building relationships, or prioritize profit over familiarity

---

### Acceptance Criteria

**Visual Checks (Dialogue Display):**
- [ ] Customer dialogue appears in dialogue box when customer popup opens
- [ ] Greeting text is 20pt, dark brown (#3A2518), regular weight
- [ ] Dialogue wraps correctly (no overflow or truncation)
- [ ] Recurring customers show different dialogue on subsequent days (not repeated)

**Functional Checks (Mrs. Kowalski Dialogue):**
- [ ] Day 1, first meeting: "Hello dear, I found this old family book..."
- [ ] Day 2, accepted Day 1: "You did wonderful work yesterday! Another heirloom..."
- [ ] Day 2, refused Day 1: "I found someone else, but they weren't good. Will you help?"
- [ ] Day 3, refused 2×: Mrs. K does not appear (relationship broken)

**Functional Checks (Dr. Chen Dialogue):**
- [ ] Day 2, first meeting: "I'm researching pre-colonial texts. Need this urgently..."
- [ ] Day 3, accepted Day 2: "Your translation was excellent. More alarming texts..."
- [ ] Day 6, story beat: "Confirms my fears. Symbols appearing faster. Running out of time!"

**Functional Checks (The Stranger Dialogue):**
- [ ] Day 5, first appearance: "*Hooded figure places ancient tome without a word.*"
- [ ] Day 7, final text: "*He returns, eyes burning. This is the last text.*"
- [ ] Text 5 success lore: "They are returning soon. Flee or stay and face what comes."

**Functional Checks (Dialogue System):**
- [ ] Dialogue stored in CustomerData.customers[id].dialogue[day][relationship_state]
- [ ] Relationship states: "first_meeting", "accepted_before", "refused_once", "broken"
- [ ] Dialogue selection: `get_dialogue(customer_id, current_day, relationship_history)`
- [ ] Edge case: Accept Mrs. K Days 1-2, refuse Day 3 → refusal count = 1, warning triangle appears
- [ ] Edge case: Refuse all customers every day → only random customers appear (all recurring relationships broken)
- [ ] Integration: Feature 3.5 (Relationship Tracking) provides relationship_history for dialogue lookup
- [ ] Integration: Dialogue appears in Feature 3.2 (Customer Selection Popup) greeting field

**Polish Checks (if time permits):**
- [ ] Dialogue typing effect (text appears character-by-character, not instant)
- [ ] Character-specific speech patterns: Mrs. K uses "dear", Dr. Chen uses formal language, Stranger uses italics
- [ ] Day 6+ dialogue has urgency markers: exclamation points, ellipses, bold words
- [ ] The Stranger's dialogue is always italic (mysterious, otherworldly tone)

---

## Feature 5.6: Win Condition: Day 7 Completion

**Priority:** CRITICAL - Defines prototype endpoint and evaluation criteria

**Tests Critical Question:** All 5 questions - Final evaluation determines if prototype succeeded

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 4.5 (Multi-Day Progression) - Reaches Day 7 via day advancement
- All previous features - Full game loop must work to reach Day 7

---

### Overview

After completing Sunday (Day 7) successfully, a "Week Complete" victory screen appears with The Stranger's cliffhanger message: "They are returning soon. TO BE CONTINUED..." Below, a playtest evaluation prompts the player to rate 1-5 on each of the 5 critical questions. This is the prototype's endpoint and evaluation mechanism.

---

### What Player Sees

**Victory Screen:**

**Trigger:** Day 7 ends successfully (all accepted customers' translations completed)

**Screen Layout:**

**Overlay Background:**
- **Position:** Full screen (0, 0) to (1920, 1080)
- **Background:** Black (#000000) with subtle vignette effect (darker at edges)
- **Z-Index:** Above all other UI

**Victory Panel:**
- **Position:** Centered (460, 140)
- **Size:** 1000px width × 800px height
- **Background:** #F4E8D8 (cream parchment)
- **Border:** 6px solid #3A2518 (dark brown)
- **Corner Radius:** 8px
- **Shadow:** 16px offset, 32px blur, #000000 at 60% opacity

**Panel Content:**

```
┌──────────────────────────────────────────────────┐
│                                                   │
│              ✓ WEEK COMPLETE ✓                   │ ← Title (48pt, green, bold, centered)
│                                                   │
│  ─────────────────────────────────────────────   │ ← Divider
│                                                   │
│  The Stranger's warning echoes in your mind:     │ ← Subtitle (24pt, dark brown, italic, centered)
│                                                   │
│  "They are returning soon. The old god stirs     │ ← Cliffhanger (22pt, dark brown, centered)
│   beneath the city, and its servants awaken.     │
│   You've done your part—now you must decide."    │
│                                                   │
│            TO BE CONTINUED...                     │ ← (28pt, gold, bold, centered)
│                                                   │
│  ─────────────────────────────────────────────   │ ← Divider
│                                                   │
│            PROTOTYPE EVALUATION                   │ ← Section header (32pt, dark brown, bold, centered)
│                                                   │
│  Rate your experience (1-5):                     │ ← Instructions (20pt, dark brown)
│                                                   │
│  Q1: Symbol decoding satisfying?    [1][2][3][4][5] │ ← Question + rating buttons
│  Q2: Capacity created tension?      [1][2][3][4][5] │
│  Q3: Examination added texture?     [1][2][3][4][5] │
│  Q4: Negotiation created variety?   [1][2][3][4][5] │
│  Q5: Story emerged naturally?       [1][2][3][4][5] │
│                                                   │
│           [ SUBMIT EVALUATION ]                   │ ← Submit button (250×50px, green, centered)
│                                                   │
└──────────────────────────────────────────────────┘
```

**Title Section:**
- **Title:** "✓ WEEK COMPLETE ✓" (48pt, #2D5016 green, bold)
- **Position:** Top of panel (y: 160)

**Cliffhanger Section:**
- **Subtitle:** "The Stranger's warning echoes in your mind:" (24pt, #3A2518 dark brown, italic)
- **Position:** y: 240
- **Cliffhanger Text:** 3 lines, 22pt, #3A2518 dark brown, centered
- **Position:** y: 280-340
- **"TO BE CONTINUED...":** 28pt, #FFD700 gold, bold, centered
- **Position:** y: 380

**Evaluation Section:**
- **Header:** "PROTOTYPE EVALUATION" (32pt, #3A2518 dark brown, bold, centered)
- **Position:** y: 460
- **Instructions:** "Rate your experience (1-5):" (20pt, #3A2518 dark brown)
- **Position:** y: 520

**Rating Buttons (Per Question):**
- **Question Text:** 20pt, #3A2518 dark brown, left-aligned
- **Position:** x: 500, y: 560, 600, 640, 680, 720 (5 questions vertically stacked, 40px gaps)
- **Button Size:** 40px × 40px (square)
- **Button Spacing:** 10px gap between buttons
- **Button Position:** Right of question text, horizontally aligned
- **Button Colors:**
  - Unselected: #CCCCCC (gray) background, #666666 (dark gray) text
  - Hover: #FFD700 (gold) border (3px)
  - Selected: #2D5016 (green) background, white text, 3px border

**Submit Button:**
- **Position:** Bottom of panel (605, 850), centered
- **Size:** 250px × 50px
- **Background:** #2D5016 (green)
- **Text:** "SUBMIT EVALUATION" (20pt, white, bold)
- **Border:** 2px solid #1A3009 (dark green)
- **Hover:** Background brightens to #3FB023

**Visual States:**
- **Default:** Victory panel visible, rating buttons unselected (gray)
- **Rating Selected:** Clicked button turns green, previous selection (if any) returns to gray
- **All Rated:** All 5 questions have green selected button (submit enabled)
- **Submit Hover:** Submit button brightens, cursor becomes pointer
- **After Submit:** Panel fades out (0.3s), "Thank you for playtesting!" message appears (3s), then returns to main menu

---

### What Player Does

**Player Experience - Victory & Evaluation:**

**Day 7 Completion:**
1. Player completes last translation on Sunday
2. Day 7 ends (no more customers, all served)
3. Screen fades to black (0.3s)
4. Victory screen fades in (0.5s)

**Reading Cliffhanger:**
1. Player reads: "The Stranger's warning echoes in your mind..."
2. Player reads cliffhanger: "They are returning soon... you must decide."
3. Player sees: "TO BE CONTINUED..." (gold text)
4. Player thinks: "Wait, that's it?! I need to know what happens next!"

**Rating Experience:**
1. Player reads: "PROTOTYPE EVALUATION - Rate your experience (1-5)"
2. Player sees 5 critical questions with rating buttons
3. Player reflects on gameplay:
   - Q1: "Symbol decoding was fun, felt like real puzzle-solving" → clicks [4]
   - Q2: "Capacity limit forced tough choices, stressful in good way" → clicks [5]
   - Q3: "Examination was skippable, didn't add much" → clicks [2]
   - Q4: "Negotiation priorities created variety, liked Cheap vs Accurate trade-offs" → clicks [4]
   - Q5: "Story build-up from family histories to apocalypse was cool" → clicks [5]
4. All 5 questions rated (all have green selected buttons)
5. Submit button enabled (was grayed until all rated)
6. Player clicks "SUBMIT EVALUATION"

**After Submission:**
1. Submit button flashes white
2. Victory panel fades out (0.3s)
3. "Thank you for playtesting!" message appears (24pt, white, centered, 3s)
4. Message fades out, returns to main menu (or exits game)

**Feedback Loop:**

1. **Player action:** Completes Day 7 translations
2. **Visual change:** Victory screen appears with cliffhanger + evaluation
3. **Player observation:** Reads story conclusion, reflects on experience
4. **System response:** Victory.show_evaluation(), captures ratings
5. **Next player decision:** Rate honestly, submit evaluation, consider if full game worth building

**Example Interaction Flow:**
```
Day 7, player completes final translation: "they are returning soon"
→ The Stranger's lore snippet appears: "Flee or stay and face what comes."
→ Player clicks "END DAY" (no more customers)
→ Screen fades to black
→ Victory screen fades in: "✓ WEEK COMPLETE ✓"
→ Cliffhanger text: "They are returning soon... TO BE CONTINUED..."
→ Player reads: "Wait, the prototype ends on a cliffhanger?!"
→ Evaluation section visible: "Rate your experience (1-5)"
→ Player clicks ratings:
   Q1: [4] - Decoding was satisfying
   Q2: [5] - Capacity created great tension
   Q3: [2] - Examination felt skippable
   Q4: [4] - Negotiation added variety
   Q5: [5] - Story escalation worked well
→ Submit button enabled (all questions rated)
→ Player clicks "SUBMIT EVALUATION"
→ Panel fades out: "Thank you for playtesting!"
→ Returns to main menu
→ Developer sees ratings: Total = 20/25, build full game!
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Victory screen appears after Day 7 ends (fades in over 0.5s)
- [ ] Victory panel is 1000×800px, centered (460, 140), cream background, dark brown border
- [ ] Title: "✓ WEEK COMPLETE ✓" (48pt green, bold, centered)
- [ ] Cliffhanger text: "They are returning soon..." (22pt dark brown, centered, 3 lines)
- [ ] "TO BE CONTINUED..." (28pt gold, bold, centered)
- [ ] Evaluation header: "PROTOTYPE EVALUATION" (32pt dark brown, bold, centered)
- [ ] 5 critical questions listed with rating buttons [1][2][3][4][5]

**Visual Checks (Rating Buttons):**
- [ ] Unselected buttons: Gray background (#CCCCCC), dark gray text (#666666)
- [ ] Hover button: Gold border (3px, #FFD700)
- [ ] Selected button: Green background (#2D5016), white text, 3px border
- [ ] Only 1 button selected per question (clicking new rating deselects previous)

**Visual Checks (Submit Button):**
- [ ] Submit button: 250×50px, green background, white text "SUBMIT EVALUATION"
- [ ] Button disabled (grayed) until all 5 questions rated
- [ ] Button enabled (green) when all questions have selections
- [ ] Hover enabled button → background brightens (#3FB023)

**Interaction Checks:**
- [ ] Day 7 ends → victory screen appears within 0.5s
- [ ] Click rating button → button turns green, previous selection (if any) returns gray
- [ ] Click all 5 questions → submit button enables (changes from gray to green)
- [ ] Click submit with incomplete ratings → nothing happens (button disabled)
- [ ] Click submit with all ratings → panel fades out, "Thank you" message appears
- [ ] After submit → returns to main menu after 3s

**Functional Checks:**
- [ ] Victory screen triggers only when Day 7 completes successfully (not on Game Over)
- [ ] Cliffhanger text matches The Stranger's final lore from Text 5
- [ ] Rating buttons store selections: `ratings = {Q1: 4, Q2: 5, Q3: 2, Q4: 4, Q5: 5}`
- [ ] Submit calculates total: `total = Q1 + Q2 + Q3 + Q4 + Q5` (max 25)
- [ ] Decision thresholds:
  - Total ≥ 20: "Build full game" (strong prototype)
  - Total 15-19: "Iterate weak mechanics" (mixed results)
  - Total < 15: "Core loop broken, pivot required"
- [ ] Edge case: Close victory screen without submitting (Escape key) → confirmation dialog: "Submit evaluation before exiting?"
- [ ] Edge case: Rate all 5s → total = 25 (perfect score)
- [ ] Edge case: Rate all 1s → total = 5 (failed prototype)
- [ ] Integration: Victory.save_evaluation(ratings) logs to file for developer review
- [ ] Integration: After submit, GameState.reset() called before returning to main menu

**Polish Checks (if time permits):**
- [ ] Cliffhanger text has subtle fade-in effect (words appear sequentially)
- [ ] "TO BE CONTINUED..." pulses gold glow effect (mysterious)
- [ ] Rating button selection has satisfying click sound
- [ ] Submit button flash + fade-out is smooth and professional
- [ ] "Thank you for playtesting!" has typewriter effect

---

## Feature 5.7: Balance Tweaking & Bug Fixes

**Priority:** CRITICAL - Ensures prototype is completable and demonstrates intended design

**Tests Critical Question:** All 5 questions - Balance affects all mechanics

**Estimated Time:** 1.0 hours

**Dependencies:** 
- All previous features - Requires complete game loop to test balance

---

### Overview

Final testing phase: complete 3 full 7-day runs with different strategies (profit-focused, story-focused, mixed), verify rent is payable by Friday with reasonable play, fix edge cases (refuse all → stuck?, $0 cash → softlock?), adjust payment amounts if too harsh or too easy. This ensures the prototype demonstrates intended design tensions.

---

### What Player Sees

**Balance Testing Scenarios:**

**Scenario 1: Profit-Focused Strategy**
- **Goal:** Maximize cash, prioritize high-paying customers
- **Strategy:**
  - Always accept Hard ($200) and Medium ($100) customers
  - Refuse Easy ($50) and Cheap (50% reduction) customers
  - Purchase Coffee Machine early (Day 2) to maximize capacity
  - Skip all examinations (no time/value in examination)
- **Expected Outcome:**
  - Friday cash: $600-800 (well above $200 rent)
  - Rent paid easily, surplus cash for upgrades
- **Balance Check:** If cash > $1000 by Friday, too easy (reduce base payments)

**Scenario 2: Story-Focused Strategy**
- **Goal:** Accept all recurring customers (Mrs. K, Dr. Chen, Stranger) for story, fill remaining slots with any customers
- **Strategy:**
  - Always accept Mrs. K (even Cheap $25), Dr. Chen, The Stranger
  - Accept random customers to fill 5 slots
  - Purchase Better Lamp + UV Light (examine all books for lore)
  - Read all lore snippets carefully
- **Expected Outcome:**
  - Friday cash: $200-300 (tight, but rent payable)
  - Story experience rich, upgrades purchased
- **Balance Check:** If cash < $150 by Friday, too harsh (increase base payments or reduce utilities)

**Scenario 3: Mixed Strategy**
- **Goal:** Balance profit and story, typical average play
- **Strategy:**
  - Accept 3 high-pay customers ($100-200) + 2 story customers (Mrs. K, Dr. Chen)
  - Purchase Coffee Machine Day 3
  - Skip examination unless UV Light owned
  - Read lore snippets when they appear
- **Expected Outcome:**
  - Friday cash: $300-500 (comfortable rent payment)
  - Story experienced, capacity upgrade purchased
- **Balance Check:** Target range for average play

**Balance Target Numbers:**

| Metric | Too Easy | Balanced | Too Harsh |
|--------|----------|----------|-----------|
| Friday Cash (Mixed Strategy) | > $600 | $300-500 | < $200 |
| Days to Afford Coffee Machine | Day 1 | Day 2-3 | Day 5+ |
| Days to Afford UV Light | Day 2 | Day 4-5 | Never |
| Total Earnings Week (Max) | > $1500 | $1000-1200 | < $800 |
| Rent Stress | None | Mild tension | Impossible |

**Bug Fix Checklist:**

**Critical Bugs (Must Fix):**
- [ ] Refuse all customers → Can still click "END DAY" (doesn't softlock)
- [ ] $0 cash on Day 1 → Can still accept customers and earn money
- [ ] Negative cash (overspend) → Shop purchase buttons disable correctly
- [ ] Dictionary overflow (20+ symbols) → Scrollable, no UI break
- [ ] Accept 6+ customers (Coffee Machine bug) → Capacity enforcement at 6/6 works
- [ ] Relationship broken (refuse 2×) → Customer actually doesn't appear next day
- [ ] Day 7 complete → Victory screen appears (not stuck on Day 7 forever)

**Edge Case Bugs (Fix if Time):**
- [ ] Rapid click "END DAY" → Only advances 1 day (not multiple)
- [ ] Spam click "BUY" upgrade → Only purchases once (no double-deduct)
- [ ] Close shop during purchase → Transaction completes or rolls back (not partial state)
- [ ] Accept customer, refuse via examination → Customer removed from accepted list correctly
- [ ] Translation symbols overflow input box → Scrollable or wraps correctly

---

### What Player Does

**Testing Protocol:**

**Playthrough 1: Profit-Focused (30 minutes)**
1. Start new game
2. Refuse Mrs. Kowalski ($25 Cheap), accept all Medium/Hard customers
3. Buy Coffee Machine Day 2 ($150)
4. Serve 6 customers per day (Days 3-7)
5. Skip all examinations
6. Track cash at end of each day:
   - Day 1: ~$170 (5 customers × $100 avg - $30 utilities)
   - Day 2: ~$290 (buy Coffee Machine -$150, then earn back)
   - Day 3: ~$570 (6 customers × $150 avg - $30)
   - Day 4: ~$840 (6 customers × $150 avg - $30)
   - Day 5 (Friday): ~$1110 (pay rent -$200, left with $910)
   - Day 6: ~$1180
   - Day 7: ~$1450
7. Verify: Rent paid easily, surplus cash $900+
8. **Result:** If cash > $1000 by Friday, reduce base payments by 20% ($200 Hard → $160, $100 Medium → $80)

**Playthrough 2: Story-Focused (30 minutes)**
1. Start new game
2. Accept all recurring customers (Mrs. K $25, Dr. Chen $100, Stranger $200)
3. Fill remaining slots with any customers
4. Buy Better Lamp Day 3 ($300), UV Light Day 5 ($500)
5. Examine all books, read all lore snippets
6. Track cash at end of each day:
   - Day 1: ~$120 (Mrs. K $25 + 4 × $75 avg - $30)
   - Day 2: ~$190 (Mrs. K + Dr. Chen + 3 others - $30)
   - Day 3: ~$160 (buy Better Lamp -$300, earn ~$270)
   - Day 4: ~$230 (5 customers × $90 avg - $30)
   - Day 5 (Friday): ~$50 (pay rent -$200, tight!)
   - Day 6: Buy UV Light if cash allows, or skip
   - Day 7: Complete story
7. Verify: Rent payable but tight ($200-250 range)
8. **Result:** If cash < $150 by Friday, increase base payments or reduce utilities to $20/day

**Playthrough 3: Mixed Strategy (30 minutes)**
1. Start new game
2. Accept mix: 3 high-pay ($100-200) + 2 story (Mrs. K, Dr. Chen)
3. Buy Coffee Machine Day 2 or 3
4. Read lore snippets, skip examination (no Better Lamp/UV)
5. Track cash at end of each day:
   - Day 1: ~$150
   - Day 2: ~$270 (buy Coffee Machine -$150)
   - Day 3: ~$490 (6 customers)
   - Day 4: ~$710
   - Day 5 (Friday): ~$510 (pay rent -$200, left with $310)
   - Day 6: ~$530
   - Day 7: ~$750
6. Verify: Rent paid comfortably, cash $300-500 buffer
7. **Result:** Target balanced range achieved

**Bug Testing (15 minutes):**
1. Test refuse all customers Day 1 → Verify "END DAY" enabled, Day 2 starts
2. Test spend all cash on Coffee Machine → Verify shop disables other upgrades
3. Test relationship breaking: Refuse Mrs. K Days 1-2 → Verify Day 3 she doesn't appear
4. Test capacity overflow: Accept 6 with Coffee Machine → Verify 7th ACCEPT disabled
5. Test Day 7 completion → Verify victory screen appears, not stuck
6. Test rapid clicks: Spam "END DAY" → Verify only advances 1 day
7. Test shop spam: Spam "BUY" on upgrade → Verify only purchases once

---

### Acceptance Criteria

**Balance Checks (Profit-Focused):**
- [ ] Friday cash: $600-1000 range (comfortable, not excessive)
- [ ] Coffee Machine purchasable by Day 2
- [ ] UV Light purchasable by Day 4-5 (not Day 2)
- [ ] Total weekly earnings: $1000-1200 max

**Balance Checks (Story-Focused):**
- [ ] Friday cash: $200-300 range (tight but payable)
- [ ] Can afford Better Lamp by Day 3
- [ ] Can afford UV Light by Day 5-6 (stretch goal)
- [ ] Rent payable with careful planning (not impossible)

**Balance Checks (Mixed Strategy):**
- [ ] Friday cash: $300-500 range (balanced)
- [ ] Coffee Machine purchasable by Day 2-3
- [ ] Rent paid with comfortable buffer ($100-300 left over)
- [ ] Total weekly earnings: $700-900

**Bug Fixes (Critical):**
- [ ] Refuse all customers → "END DAY" enabled, no softlock
- [ ] $0 cash → Can still accept customers, earn money
- [ ] Negative cash → Shop upgrades disable correctly (can't purchase with -$50)
- [ ] Dictionary overflow → Scrollable, no UI break (tested with 30+ symbols)
- [ ] Coffee Machine capacity → Enforces 6/6 limit (not 7+)
- [ ] Relationship broken → Customer removed from future queues correctly
- [ ] Day 7 complete → Victory screen appears, no infinite loop

**Bug Fixes (Edge Cases):**
- [ ] Rapid "END DAY" clicks → Only advances 1 day
- [ ] Spam "BUY" upgrade → Only purchases once, no double-deduct
- [ ] Close shop mid-purchase → Transaction completes or rolls back (atomic)
- [ ] Accept then refuse (via back button) → Customer removed from accepted list
- [ ] Long translation text → Input box scrolls, no overflow

**Functional Checks (Balance Adjustments):**
- [ ] If Playthrough 1 cash > $1000 by Friday → Reduce base payments:
  - Easy: $50 → $40
  - Medium: $100 → $80
  - Hard: $200 → $160
- [ ] If Playthrough 2 cash < $150 by Friday → Reduce utilities:
  - Daily utilities: $30 → $20
  - OR increase base payments by 20%
- [ ] If Playthrough 3 cash not in $300-500 range → Adjust rent deadline:
  - Too easy: Rent increases to $250
  - Too hard: Rent decreases to $150

**Polish Checks (if time permits):**
- [ ] Add tooltips explaining economic calculations: "Coffee Machine pays for itself in 3 days ($50/day × 3 = $150)"
- [ ] Add warning messages: "Cash low! You have $50 and rent is $200 on Friday."
- [ ] Add congratulations message on good economic play: "Ended week with $500 surplus!"

---

## INTEGRATION CHECKLIST

These features complete the prototype. Verify end-to-end integration:

- [ ] **5.1 → 5.2, 5.3:** Shop upgrades (Better Lamp, Coffee Machine) purchased correctly
- [ ] **5.2 → 4.1:** Better Lamp hints appear during examination (if owned)
- [ ] **5.3 → 3.4:** Coffee Machine increases capacity from 5 to 6 (enforcement works)
- [ ] **5.4 → 2.4:** Lore snippets appear after successful translation validation
- [ ] **5.5 → 3.5:** Customer dialogue references relationship history (accepted/refused)
- [ ] **5.6 → 4.5:** Victory screen appears after Day 7 completion (end of progression)
- [ ] **5.7 → All features:** Balance tweaks affect all systems (payments, utilities, rent)

---

## TESTING PROTOCOL (FULL PROTOTYPE)

**Complete 7-Day Playthrough (60-90 minutes):**

**Day 1 (Monday):**
1. Start new game, cash = $100
2. Accept 5 customers (mix Easy/Medium), earn ~$400-500
3. End day, utilities -$30, cash = $370-470

**Day 2 (Tuesday):**
1. Accept Mrs. K + Dr. Chen + 3 others
2. Buy Coffee Machine ($150), cash = $220-320
3. End day, utilities -$30, cash = $190-290

**Day 3 (Wednesday):**
1. Accept 6 customers (Coffee Machine active)
2. Complete Text 3: "the old god sleeps" (ominous lore appears)
3. Earn ~$450-600, end day, cash = $610-860

**Day 4 (Thursday):**
1. Accept 6 customers
2. Earn ~$450-600, end day, cash = $1030-1430

**Day 5 (Friday - Rent Deadline):**
1. Accept 6 customers
2. Earn ~$450-600, end day
3. Rent check: Cash ≥ $200 → Rent paid (-$200)
4. Remaining cash: $1280-1830

**Day 6 (Saturday):**
1. Accept The Stranger + 5 others
2. Complete translations, end day
3. Cash: $1630-2180

**Day 7 (Sunday - Final Day):**
1. Accept The Stranger (Text 5: "they are returning soon")
2. Complete final translation, lore cliffhanger appears
3. End day → Victory screen appears
4. Rate evaluation: Q1-Q5 (1-5 each)
5. Submit evaluation, see total score

**Expected Total Score:**
- **≥20:** Build full game (prototype succeeded)
- **15-19:** Iterate weak mechanics (mixed results)
- **<15:** Core loop broken, pivot required

---

## VISUAL REFERENCE - NEW COLORS (PHASE 5)

**Existing colors:**
- Cream parchment: `#F4E8D8`
- Dark brown: `#3A2518`
- Green (success): `#2D5016`
- Red (failure): `#8B0000`
- Gold (highlights): `#FFD700`
- Gray (disabled): `#888888`

**Phase 5 additions:**
- Orange (almost full): `#FF8C00`
- White (card backgrounds): `#FFFFFF`
- Light green (owned upgrades): `#E8F5E0`
- Saddle brown (ominous): `#8B4513`

---

## TIME ESTIMATES SUMMARY

| Feature | Estimated Time | Critical Path |
|---------|----------------|---------------|
| 5.1 Upgrade Shop Menu | 1.0 hours | No (can simplify) |
| 5.2 Better Lamp Upgrade | 0.5 hours | No (optional) |
| 5.3 Coffee Machine Upgrade | 0.25 hours | No (optional) |
| 5.4 Story Integration: Text Content | 0.75 hours | Yes (core story) |
| 5.5 Story Integration: Customer Dialogue | 0.5 hours | No (enhances story) |
| 5.6 Win Condition: Day 7 Completion | 0.5 hours | Yes (prototype endpoint) |
| 5.7 Balance Tweaking & Bug Fixes | 1.0 hours | Yes (playability) |
| **TOTAL** | **4.5 hours** | |

**Buffer:** +1.5 hours for full playthroughs, polish = **6 hours total** (fits within 12-16 hour window if previous phases on schedule)

**Simplification if over time:**
- **Cut Features 5.1-5.3** (Shop + Upgrades) → Focus on core story + balance (saves 1.75 hours)
- **Simplify Feature 5.5** → Generic customer dialogue (no relationship references) (saves 0.5 hours)
- **Minimum viable:** Features 5.4, 5.6, 5.7 only → Story + win condition + balance (2.25 hours)

---

## PROTOTYPE COMPLETE

After Phase 5, the prototype is feature-complete:
- **7-day game loop** works end-to-end
- **5 critical questions** testable via victory screen evaluation
- **Economic pressure** (utilities + rent) creates strategic tension
- **Story arc** escalates from mundane → ominous → cliffhanger
- **Upgrade system** (optional) enhances examination tools
- **Balance tested** across 3 playstyles (profit, story, mixed)

**Next Step:** Conduct 3-5 external playtests, collect evaluation scores, calculate average ratings, decide:
- **Score ≥20:** Build full game (5-week expansion)
- **Score 15-19:** Iterate weak mechanics, retest
- **Score <15:** Pivot to different core loop or game concept
