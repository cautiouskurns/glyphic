# PHASE 3: Strategic Choice Layer - Feature Specifications

## Context
- **Game:** Glyphic - Translation Shop Puzzle Game
- **Phase Goal:** Player chooses 5 customers from 7-10 arrivals, refusals have consequences, capacity creates tension
- **Estimated Duration:** 3 hours (Hours 6-9 of prototype)
- **Features in Phase:** 
  1. Customer Queue Display (3.1)
  2. Customer Selection Popup (3.2)
  3. Accept/Refuse Logic (3.3)
  4. Capacity Enforcement (3.4)
  5. Customer Relationship Tracking (3.5)
  6. Daily Queue Generation (3.6)

---

## Feature 3.1: Customer Queue Display

**Priority:** CRITICAL - This is the visual representation of the core strategic choice mechanic

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Displays 7-10 customers when player can only choose 5

**Estimated Time:** 1.0 hours

**Dependencies:** 
- Feature 1.2 (Symbol Data System) - Uses customer data structures
- Feature 1.3 (UI Workspace Layout) - Left panel must exist
- Feature 1.4 (Customer Data Structures) - Customer definitions loaded

---

### Overview

The customer queue displays 7-10 customer cards in the left panel, each showing name, payment, difficulty, and description. Players see more customers than they can serve, creating the core scarcity tension. Hover feedback indicates cards are clickable, leading to the selection popup.

---

### What Player Sees

**Screen Layout:**
- **Position:** Left panel (x: 0, y: 90) - full left side of screen below top bar
- **Size:** 420px width × 990px height (from top bar to dialogue box)
- **Card Container:** 
  - Position: x: 20, y: 80 (below "Today's Customers" title)
  - Size: 380px width × 880px available height
  - Scrollable if queue exceeds 7 customers

**Customer Card Visual Appearance:**
- **Card Dimensions:** 360px width × 110px height
- **Spacing:** 10px vertical gap between cards
- **Background Color:** #F4E8D8 (cream parchment)
- **Border:** 2px solid #3A2518 (dark brown)
- **Corner Radius:** 4px

**Card Content Layout:**
```
┌─────────────────────────────────────────┐
│ Mrs. Kowalski             $50   [Easy]  │ ← Row 1: Name (left), Payment (right), Difficulty badge
│ "I found this old family book..."       │ ← Row 2: One-line description (italic, gray)
│                                          │
│ Priorities: Cheap + Accurate            │ ← Row 3: Negotiation priorities (small text)
└─────────────────────────────────────────┘
```

**Text Styles:**
- **Name:** 24pt, #3A2518 (dark brown), bold
- **Payment:** 22pt, #2D5016 (green), bold, right-aligned
- **Difficulty Badge:** 
  - Easy: 18pt, white text on #2D5016 (green) background, 60×28px rounded rectangle
  - Medium: 18pt, white text on #FF8C00 (orange) background, 80×28px rounded rectangle
  - Hard: 18pt, white text on #8B0000 (red) background, 60×28px rounded rectangle
- **Description:** 18pt, #666666 (gray), italic
- **Priorities:** 16pt, #3A2518 (dark brown), regular weight

**Visual States:**
- **Default:** Cream background (#F4E8D8), dark brown border (#3A2518)
- **Hover:** Background changes to #FFD700 (gold) with 30% opacity, border thickens to 3px, cursor changes to pointer
- **Clicked:** Border flashes #FFD700 (gold) briefly (0.2s), then popup appears
- **Disabled (after refusal):** 50% opacity, background grayed to #CCCCCC, red X icon overlaid in top-right corner

**Panel Header:**
- **Title:** "Today's Customers"
- **Position:** x: 20, y: 20
- **Font:** 30pt, #F4E8D8 (cream), bold
- **Background:** Dark brown panel (#2B2520)

**Visual Feedback:**
- **On card hover:** Entire card highlights with gold tint, border thickens
- **On queue update:** New cards fade in from top (0.3s transition)
- **On capacity full:** Remaining un-selected cards pulse red border once (0.5s)

---

### What Player Does

**Input Methods:**
- **Mouse:** Hover over cards to see interactive feedback, click to open selection popup
- **Scroll:** If queue exceeds 7 customers, mouse wheel scrolls the list

**Immediate Response:**
- **Hover over card** → Card highlights with gold tint within 0.1s, cursor becomes pointer
- **Move mouse away** → Card returns to default state within 0.1s
- **Click card** → Card border flashes gold (0.2s), selection popup appears centered on screen
- **Scroll wheel** → Queue scrolls smoothly (if 8+ customers present)

**Feedback Loop:**
1. **Player action:** Mouse hovers over "Mrs. Kowalski" card
2. **Visual change:** Card background tints gold, border thickens to 3px
3. **System response:** Card becomes "hot" state, ready for click
4. **Next player decision:** Click to see full details, or hover over other cards to compare

**Example Interaction Flow:**
```
Player starts Day 1
→ Left panel shows 7 customer cards stacked vertically
→ Player hovers over "Mrs. Kowalski ($50, Easy)"
→ Card highlights with gold tint
→ Player moves mouse to "Dr. Chen ($100, Medium)"
→ First card returns to normal, second card highlights
→ Player clicks Dr. Chen card
→ Card border flashes gold briefly
→ Customer selection popup appears (Feature 3.2)
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Left panel displays "Today's Customers" title at top (30pt cream text)
- [ ] 7-10 customer cards appear stacked vertically below title
- [ ] Each card shows: name (left), payment amount (right, green), difficulty badge, description, priorities
- [ ] Cards have cream background (#F4E8D8) and dark brown border (#3A2518)
- [ ] Difficulty badges display correct color: Easy (green), Medium (orange), Hard (red)
- [ ] 10px vertical spacing between cards is consistent
- [ ] If 8+ customers, scroll bar appears on right side of panel

**Interaction Checks:**
- [ ] Hover over card → gold tint appears within 0.1s, border thickens to 3px
- [ ] Move mouse away → card returns to default state within 0.1s
- [ ] Click card → border flashes gold (0.2s), popup opens (Feature 3.2 dependency)
- [ ] Scroll wheel moves queue smoothly if 8+ customers present
- [ ] Multiple rapid hovers don't cause visual glitches

**Functional Checks:**
- [ ] Queue contains exactly 7-10 customers (never fewer, never more)
- [ ] Recurring customers appear if eligible: Mrs. K (Days 1-3), Dr. Chen (Days 2-7), Stranger (Days 5-7)
- [ ] Random customers fill remaining slots (4-7 one-time customers)
- [ ] Customer data displays correctly: name matches CustomerData entry, payment = base_payment × difficulty multiplier
- [ ] Edge case: Day 1 with 0 refusals shows Mrs. K + 6 random customers (7 total)
- [ ] Integration: CustomerData singleton provides customer definitions
- [ ] Integration: GameState provides current day number to filter eligible customers

**Polish Checks (if time permits):**
- [ ] Cards fade in smoothly when queue first appears (0.3s transition)
- [ ] Hover transition is smooth (not instant snap)
- [ ] Card click provides satisfying tactile feedback (flash + popup)

---

## Feature 3.2: Customer Selection Popup

**Priority:** CRITICAL - Core decision point where player commits to accepting or refusing customers

**Tests Critical Question:** Q2 (Limited capacity) + Q4 (Negotiation creates variety) - Shows full customer details including negotiation priorities

**Estimated Time:** 0.75 hours

**Dependencies:** 
- Feature 3.1 (Customer Queue Display) - Popup triggered by card click
- Feature 1.4 (Customer Data Structures) - Displays customer dialogue and priorities

---

### Overview

A modal popup appears when player clicks a customer card, displaying full details: name, payment, difficulty, dialogue quote, and negotiation priorities. Two large buttons (ACCEPT/REFUSE) let the player make the strategic choice. The popup blocks interaction with the rest of the UI until dismissed.

---

### What Player Sees

**Screen Layout:**
- **Position:** Centered on screen (x: 660, y: 290) - 500px from left edge, 200px from top
- **Size:** 600px width × 500px height
- **Overlay:** Semi-transparent black (#000000 at 60% opacity) covers entire screen behind popup
- **Z-Index:** Renders above all other UI elements

**Popup Visual Appearance:**
- **Background:** #F4E8D8 (cream parchment)
- **Border:** 4px solid #3A2518 (dark brown)
- **Corner Radius:** 8px
- **Shadow:** 8px offset, 16px blur, #000000 at 40% opacity

**Popup Content Layout:**
```
┌──────────────────────────────────────────────────┐
│  Mrs. Kowalski                      $50   [Easy] │ ← Header: Name, Payment, Difficulty
├──────────────────────────────────────────────────┤
│                                                   │
│  "Hello dear, I found this old family book       │ ← Greeting dialogue (centered, italic)
│   in my attic. Can you help me read it?"        │
│                                                   │
│  ─────────────────────────────────────────────   │ ← Divider line
│                                                   │
│  Translation: Text 1 - Family History            │ ← Which translation text
│  Difficulty: Easy (15 words, simple pattern)     │ ← Difficulty explanation
│                                                   │
│  Customer Priorities:                            │ ← Negotiation section
│  ✓ Cheap (will pay 50% if you agree)            │
│  ✓ Accurate (no mistakes allowed)               │
│  ✗ Fast (patient, no rush)                      │
│                                                   │
├──────────────────────────────────────────────────┤
│  [      ACCEPT      ]  [      REFUSE      ]      │ ← Action buttons (bottom)
└──────────────────────────────────────────────────┘
```

**Text Styles:**
- **Name:** 28pt, #3A2518 (dark brown), bold
- **Payment:** 26pt, #2D5016 (green), bold
- **Difficulty Badge:** Same as Feature 3.1 (color-coded rounded rectangle)
- **Dialogue Quote:** 22pt, #3A2518 (dark brown), italic, center-aligned, 520px max width
- **Translation Info:** 20pt, #3A2518 (dark brown), regular weight
- **Priorities Header:** 22pt, #3A2518 (dark brown), bold
- **Priority Items:** 20pt, #3A2518 (dark brown), regular weight
  - ✓ = Selected priority (green checkmark #2D5016)
  - ✗ = Not selected (red X #8B0000)

**Button Appearance:**
- **ACCEPT Button:**
  - Size: 250px width × 60px height
  - Position: x: 50, y: 420 (bottom-left of popup)
  - Background: #2D5016 (green)
  - Text: "ACCEPT" in 24pt white, bold, center-aligned
  - Border: 2px solid #1A3009 (dark green)
  - Corner Radius: 6px
- **REFUSE Button:**
  - Size: 250px width × 60px height
  - Position: x: 310, y: 420 (bottom-right of popup)
  - Background: #8B0000 (red)
  - Text: "REFUSE" in 24pt white, bold, center-aligned
  - Border: 2px solid #5A0000 (dark red)
  - Corner Radius: 6px

**Visual States:**
- **Default:** Popup visible, overlay darkens background, buttons show default colors
- **Button Hover (ACCEPT):** Background brightens to #3FB023, border glows, cursor becomes pointer
- **Button Hover (REFUSE):** Background brightens to #B30000, border glows, cursor becomes pointer
- **Button Pressed:** Button depresses slightly (2px offset), background darkens
- **Disabled (capacity full):** ACCEPT button grays out (#888888), shows "Shop Full" tooltip on hover

**Visual Feedback:**
- **On popup open:** Popup scales in from 80% to 100% size (0.2s ease-out), overlay fades in (0.2s)
- **On button hover:** Button brightens, subtle glow effect around border
- **On button click:** Button flashes bright white (0.1s), popup closes with scale-out animation (0.15s)
- **On refuse:** Red X icon briefly appears over customer card in queue (0.3s fade-in)

---

### What Player Does

**Input Methods:**
- **Mouse:** Hover over ACCEPT/REFUSE buttons, click to make choice
- **Keyboard:** 
  - Enter key = ACCEPT (if capacity available)
  - Escape key = REFUSE
  - Spacebar = close popup without action (returns to queue view)

**Immediate Response:**
- **Hover ACCEPT button** → Button brightens to lighter green within 0.1s, cursor becomes pointer
- **Hover REFUSE button** → Button brightens to lighter red within 0.1s, cursor becomes pointer
- **Click ACCEPT** → Button flashes white (0.1s), popup closes (0.15s), customer added to accepted list, capacity increments
- **Click REFUSE** → Button flashes white (0.1s), popup closes (0.15s), customer card grays out in queue
- **Press Escape** → Popup closes immediately (0.15s scale-out), no state change

**Feedback Loop:**
1. **Player action:** Clicks ACCEPT button
2. **Visual change:** Button flashes white, popup scales out and disappears
3. **System response:** Customer added to accepted list, capacity counter updates (0/5 → 1/5), translation workspace loads customer's text
4. **Next player decision:** Accept more customers (up to 5), or refuse remaining, or click another card

**Example Interaction Flow:**
```
Player clicks "Dr. Chen" card in queue
→ Popup appears centered, showing "$100, Medium, 'I need this urgently'"
→ Player reads priorities: Fast + Accurate
→ Player hovers over ACCEPT button
→ Button brightens to lighter green
→ Player clicks ACCEPT
→ Button flashes white briefly
→ Popup closes with scale-out animation
→ Capacity counter updates: 0/5 → 1/5
→ Dr. Chen's card remains in queue but shows "ACCEPTED" badge
→ Translation workspace loads "Text 2 - Ancient Ritual" for Dr. Chen
→ Player can click another card to continue accepting customers
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Popup appears centered at (660, 290) with 600×500px dimensions
- [ ] Semi-transparent black overlay (60% opacity) darkens background
- [ ] Popup displays: name, payment (green), difficulty badge, dialogue quote, translation info, priorities
- [ ] Priorities show ✓ (green) for selected, ✗ (red) for not selected (2 selected, 1 not per customer)
- [ ] ACCEPT button is green (#2D5016), REFUSE button is red (#8B0000)
- [ ] Buttons are 250×60px, positioned at bottom of popup with 10px gap between
- [ ] Popup has cream background (#F4E8D8), 4px dark brown border, 8px shadow

**Interaction Checks:**
- [ ] Click customer card in queue → popup opens within 0.2s with scale-in animation
- [ ] Hover ACCEPT → button brightens within 0.1s, cursor becomes pointer
- [ ] Hover REFUSE → button brightens within 0.1s, cursor becomes pointer
- [ ] Click ACCEPT → button flashes white, popup closes (0.15s), capacity increments (Feature 3.3 dependency)
- [ ] Click REFUSE → button flashes white, popup closes (0.15s), customer card grays out (Feature 3.3 dependency)
- [ ] Press Escape → popup closes immediately without state change
- [ ] Press Enter → same as clicking ACCEPT (if capacity available)
- [ ] Click overlay (outside popup) → popup closes without action

**Functional Checks:**
- [ ] Popup displays correct customer data from CustomerData singleton
- [ ] Payment amount matches: base_payment (Easy: $50, Medium: $100, Hard: $200)
- [ ] Difficulty explanation matches text complexity (Easy: 10-15 words, Medium: 20-30 words, Hard: 40+ words)
- [ ] Priorities display correctly: Mrs. K shows "Cheap + Accurate", Dr. Chen shows "Fast + Accurate", Stranger shows "Fast + Accurate"
- [ ] Edge case: If capacity is 5/5, ACCEPT button is disabled (grayed out, shows tooltip "Shop is full")
- [ ] Edge case: Clicking REFUSE on The Stranger marks him as permanently unavailable (relationship tracking)
- [ ] Integration: Popup data pulled from CustomerData.get_customer(customer_id)
- [ ] Integration: ACCEPT triggers Feature 3.3 accept logic

**Polish Checks (if time permits):**
- [ ] Popup scale-in animation is smooth (ease-out curve)
- [ ] Button hover transitions are smooth (not instant)
- [ ] Button flash effect is satisfying and quick (0.1s)
- [ ] Overlay fade-in creates professional modal effect

---

## Feature 3.3: Accept/Refuse Logic

**Priority:** CRITICAL - Executes the core strategic choice and updates game state

**Tests Critical Question:** Q2 (Limited capacity) - Enforces 5-customer limit through state management

**Estimated Time:** 0.75 hours

**Dependencies:** 
- Feature 3.2 (Customer Selection Popup) - Triggered by ACCEPT/REFUSE button clicks
- Feature 1.1 (Game State Manager) - Updates capacity counter and accepted customer list
- Feature 2.3 (Translation Workspace) - Loads accepted customer's translation text

---

### Overview

When player clicks ACCEPT, the customer is added to the accepted list, capacity increments (0/5 → 1/5 → ... → 5/5), and their translation text loads in the workspace. When player clicks REFUSE, the customer card grays out with a red X, and they are removed from the queue. At 5/5 capacity, remaining customers auto-refuse with a message.

---

### What Player Sees

**Accept Flow - Visual Changes:**

1. **Customer Card Update (in Left Panel):**
   - **Position:** Same position in queue list
   - **Visual Change:** 
     - Green checkmark badge (✓) appears in top-right corner (40×40px)
     - Badge background: #2D5016 (green), white checkmark icon
     - Card background lightens to #E8F5E0 (light green tint)
     - Card border changes to #2D5016 (green), 3px width
     - "ACCEPTED" text appears below description (18pt, green, bold)

2. **Capacity Counter Update (Top Bar):**
   - **Position:** Center of top bar (735, 30)
   - **Visual Change:** Number increments with quick scale animation (1.2× → 1.0× over 0.2s)
   - **Color Logic:**
     - 0-3 customers: #888888 (gray - "you can take more")
     - 4 customers: #FF8C00 (orange - "almost full")
     - 5 customers: #2D5016 (green - "capacity met")
   - **Text:** "0/5" → "1/5" → "2/5" → ... → "5/5 Customers Served"

3. **Translation Workspace Update:**
   - **Position:** Center workspace (420, 90) to (1500, 780)
   - **Visual Change:** 
     - Current text (if any) fades out (0.2s)
     - New translation text fades in (0.3s)
     - Customer name appears at top: "Translating for: Mrs. Kowalski" (24pt, dark brown)
     - Symbol text displays: "∆ ◊≈ ⊕⊗◈" (48pt, centered)

4. **Dialogue Box Update (Bottom):**
   - **Position:** Bottom panel (0, 780) to (1920, 1080)
   - **Visual Change:** Dialogue text updates to customer's "success" line
   - **Text:** "Wonderful! I'll wait patiently while you work on this." (Mrs. Kowalski)

**Refuse Flow - Visual Changes:**

1. **Customer Card Update (in Left Panel):**
   - **Position:** Same position in queue list (doesn't move or remove)
   - **Visual Change:**
     - Entire card fades to 50% opacity (0.3s transition)
     - Background changes to #CCCCCC (gray)
     - Red X icon appears in top-right corner (40×40px, #8B0000)
     - "REFUSED" text appears below description (18pt, red, bold)
     - Card becomes non-interactive (no hover effect)

2. **Dialogue Box Update (Bottom):**
   - **Position:** Bottom panel (0, 780) to (1920, 1080)
   - **Visual Change:** Dialogue text updates to customer's "refuse" line
   - **Recurring Customer Text Examples:**
     - Mrs. Kowalski: "Oh... I understand, dear. Perhaps another time." (first refusal)
     - Mrs. Kowalski: "I see. I'll find someone else to help." (second refusal - relationship breaks)
     - The Stranger: "*He nods silently and leaves, never to return.*" (one refusal = permanent)
   - **One-Time Customer Text:** "No problem, I'll try another shop. Good luck!" (generic)

3. **Auto-Refuse at 5/5 Capacity:**
   - **Trigger:** When capacity reaches 5/5, all remaining non-accepted cards auto-refuse
   - **Visual Sequence:**
     1. Capacity counter turns green (5/5)
     2. All remaining cards pulse red border once (0.5s)
     3. Cards gray out one-by-one with 0.2s delay between each (cascade effect)
     4. Red X icons appear on all refused cards
     5. Dialogue box updates: "*You've reached capacity for today. Remaining customers turn away.*"

---

### What Player Does

**Accept Flow - Player Actions:**

**Input:** Click ACCEPT button in popup (Feature 3.2)

**Immediate Response Sequence:**
1. **T+0.0s:** Button flashes white
2. **T+0.1s:** Popup closes with scale-out animation
3. **T+0.15s:** Customer card updates (green checkmark badge appears)
4. **T+0.2s:** Capacity counter increments with scale animation
5. **T+0.25s:** Translation workspace fades in new text
6. **T+0.4s:** Dialogue box updates to customer's success message
7. **T+0.5s:** System ready for next customer selection

**Refuse Flow - Player Actions:**

**Input:** Click REFUSE button in popup (Feature 3.2)

**Immediate Response Sequence:**
1. **T+0.0s:** Button flashes white
2. **T+0.1s:** Popup closes with scale-out animation
3. **T+0.15s:** Customer card grays out (50% opacity, red X appears)
4. **T+0.3s:** Dialogue box updates to customer's refusal message
5. **T+0.45s:** System ready for next customer selection

**Feedback Loop (Accept):**
1. **Player action:** Clicks ACCEPT on Dr. Chen popup
2. **Visual change:** Popup closes, Dr. Chen card shows green checkmark, capacity updates to 1/5
3. **System response:** Dr. Chen added to GameState.accepted_customers array, Text 2 loaded in workspace
4. **Next player decision:** Translate Text 2 now, or accept more customers first (up to 5 total)

**Feedback Loop (Refuse):**
1. **Player action:** Clicks REFUSE on random customer popup
2. **Visual change:** Popup closes, customer card grays out with red X
3. **System response:** Customer removed from queue, refusal tracked (if recurring customer)
4. **Next player decision:** Click another card to consider next customer

---

### Acceptance Criteria

**Visual Checks (Accept):**
- [ ] Accepted customer card shows green checkmark badge (✓) in top-right corner
- [ ] Card background lightens to #E8F5E0 (light green tint)
- [ ] Card border changes to #2D5016 (green), 3px width
- [ ] "ACCEPTED" text appears below description (18pt, green, bold)
- [ ] Capacity counter increments: "0/5" → "1/5" → ... → "5/5"
- [ ] Capacity counter color changes: gray (0-3) → orange (4) → green (5)
- [ ] Translation workspace loads new text with customer name at top
- [ ] Dialogue box updates to customer's success message

**Visual Checks (Refuse):**
- [ ] Refused customer card fades to 50% opacity
- [ ] Card background changes to #CCCCCC (gray)
- [ ] Red X icon (40×40px) appears in top-right corner
- [ ] "REFUSED" text appears below description (18pt, red, bold)
- [ ] Card no longer responds to hover (non-interactive)
- [ ] Dialogue box updates to customer's refusal message

**Visual Checks (Auto-Refuse at 5/5):**
- [ ] When capacity reaches 5/5, all remaining cards pulse red border once (0.5s)
- [ ] Remaining cards gray out in cascade (0.2s delay between each)
- [ ] Red X icons appear on all auto-refused cards
- [ ] Dialogue box shows: "*You've reached capacity for today. Remaining customers turn away.*"

**Interaction Checks:**
- [ ] Click ACCEPT → popup closes within 0.15s, card updates within 0.2s, capacity increments within 0.25s
- [ ] Click REFUSE → popup closes within 0.15s, card grays out within 0.3s
- [ ] Multiple rapid accepts (spam-clicking) don't break capacity counter (stays ≤5)
- [ ] Accepting 5th customer triggers auto-refuse on remaining cards
- [ ] Accepted customer's translation text loads in workspace (Feature 2.3 integration)

**Functional Checks:**
- [ ] ACCEPT adds customer to GameState.accepted_customers array
- [ ] ACCEPT increments GameState.capacity_used (0 → 1 → ... → 5)
- [ ] ACCEPT loads correct translation text: Mrs. K → Text 1, Dr. Chen → Text 2, Stranger → Text 5
- [ ] REFUSE adds customer to GameState.refused_customers array (for relationship tracking)
- [ ] REFUSE does NOT increment capacity counter
- [ ] Auto-refuse at 5/5 marks all remaining customers as refused
- [ ] Edge case: Accepting customer at 4/5 → increments to 5/5, auto-refuses remaining 2-5 customers
- [ ] Edge case: Refusing The Stranger on Day 5 → he doesn't appear on Days 6-7
- [ ] Integration: GameState.accept_customer(customer_id) called on ACCEPT
- [ ] Integration: GameState.refuse_customer(customer_id) called on REFUSE
- [ ] Integration: TranslationWorkspace.load_text(text_id) called after ACCEPT

**Polish Checks (if time permits):**
- [ ] Capacity counter scale animation (1.2× → 1.0×) is smooth and satisfying
- [ ] Translation workspace text fade transition is smooth (old out, new in)
- [ ] Auto-refuse cascade effect creates visual flow (not all at once)
- [ ] Dialogue box updates feel responsive and contextual

---

## Feature 3.4: Capacity Enforcement

**Priority:** HIGH - Ensures the strategic constraint is respected, prevents exploits

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Hard limit prevents accepting 6+ customers

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 3.3 (Accept/Refuse Logic) - Enforces capacity limit during accept flow
- Feature 1.1 (Game State Manager) - Reads GameState.capacity_used value

---

### Overview

A hard cap of 5 translation slots per day ensures players must make strategic choices about which customers to refuse. Once 5 customers are accepted, ACCEPT buttons disable on remaining cards, and attempting to click shows a tooltip. The Coffee Machine upgrade (if purchased) increases capacity to 6.

---

### What Player Sees

**At Capacity (5/5) - Visual Changes:**

1. **Remaining Customer Cards (in Left Panel):**
   - **Visual Change:**
     - All non-accepted cards show subtle red outline (2px, #8B0000, 50% opacity)
     - Cards remain clickable (can still open popup to view details)
     - Hover effect is dimmed (gold tint at 30% opacity instead of 100%)

2. **ACCEPT Button (in Popup):**
   - **Visual State:** Disabled/grayed out
   - **Background:** #888888 (gray) instead of #2D5016 (green)
   - **Text:** "ACCEPT" grayed out, 50% opacity
   - **Border:** #666666 (dark gray)
   - **Cursor:** Default cursor (not pointer) when hovering
   - **Tooltip:** "Shop is full (5/5 capacity)" appears on hover (white text on black background, 18pt)

3. **REFUSE Button (in Popup):**
   - **Visual State:** Remains active (red, normal functionality)
   - **No change** - player can still refuse customers even at capacity

4. **Capacity Counter (Top Bar):**
   - **Visual State at 5/5:**
     - Color: #2D5016 (green)
     - Text: "5/5 Customers Served" (bold)
     - Small lock icon appears next to counter (20×20px, #FFD700 gold)

**With Coffee Machine Upgrade - Visual Changes:**

1. **Capacity Counter (Top Bar):**
   - **Text:** "0/6 Customers Served" instead of "0/5"
   - **Small coffee cup icon** (20×20px) appears next to counter (indicates upgrade active)

2. **ACCEPT Button Behavior:**
   - **Disabled at 6/6** instead of 5/5
   - **Tooltip:** "Shop is full (6/6 capacity - Coffee Machine active)"

---

### What Player Does

**At Capacity (5/5) - Player Actions:**

**Scenario 1: Player tries to accept 6th customer**

**Input:** Click customer card in queue (after already accepting 5)

**Immediate Response:**
1. **T+0.0s:** Customer popup opens normally
2. **T+0.1s:** ACCEPT button appears grayed out (#888888)
3. **Player hovers ACCEPT** → Tooltip appears: "Shop is full (5/5 capacity)"
4. **Player clicks ACCEPT** → Nothing happens (button is non-interactive)
5. **Player clicks REFUSE** → Works normally (customer card grays out)

**Scenario 2: Player reaches 5/5 mid-queue**

**Input:** Accepts 5th customer (e.g., after accepting 4 others)

**Immediate Response:**
1. **T+0.0s:** 5th customer's card updates (green checkmark)
2. **T+0.2s:** Capacity counter turns green: "5/5 Customers Served"
3. **T+0.3s:** Lock icon appears next to counter
4. **T+0.5s:** All remaining customer cards pulse red border once
5. **T+0.7s:** Remaining cards begin cascade gray-out (auto-refuse)
6. **T+1.0s:** All non-accepted cards show red X and "REFUSED" badge

**Feedback Loop:**
1. **Player action:** Accepts 5th customer
2. **Visual change:** Capacity counter turns green (5/5), lock icon appears
3. **System response:** GameState.capacity_full flag set to true, auto-refuse remaining customers
4. **Next player decision:** Proceed to translate accepted customers' texts, or end day

---

### Acceptance Criteria

**Visual Checks (At 5/5 Capacity):**
- [ ] Capacity counter displays "5/5 Customers Served" in green (#2D5016)
- [ ] Lock icon (20×20px, gold) appears next to capacity counter
- [ ] Remaining non-accepted customer cards show subtle red outline (2px, 50% opacity)
- [ ] Hover effect on remaining cards is dimmed (gold tint at 30% opacity)
- [ ] ACCEPT button in popup is grayed out (#888888, 50% opacity)
- [ ] ACCEPT button shows tooltip on hover: "Shop is full (5/5 capacity)"
- [ ] REFUSE button remains active (red, normal functionality)

**Visual Checks (With Coffee Machine Upgrade):**
- [ ] Capacity counter displays "0/6 Customers Served" instead of "0/5"
- [ ] Coffee cup icon (20×20px) appears next to capacity counter
- [ ] ACCEPT button disabled at 6/6 instead of 5/5
- [ ] Tooltip at 6/6: "Shop is full (6/6 capacity - Coffee Machine active)"

**Interaction Checks:**
- [ ] Accept 5th customer → capacity counter turns green, lock icon appears
- [ ] At 5/5, remaining cards auto-refuse with cascade animation (0.2s delay between)
- [ ] Click customer card at 5/5 → popup opens, ACCEPT button is grayed out
- [ ] Hover ACCEPT at 5/5 → tooltip appears, cursor stays default (not pointer)
- [ ] Click ACCEPT at 5/5 → nothing happens (button non-interactive)
- [ ] Click REFUSE at 5/5 → works normally (customer card grays out)
- [ ] Spam-click ACCEPT on multiple popups rapidly → capacity never exceeds 5

**Functional Checks:**
- [ ] GameState.capacity_used increments correctly: 0 → 1 → 2 → 3 → 4 → 5
- [ ] GameState.capacity_used never exceeds GameState.max_capacity (default: 5)
- [ ] GameState.capacity_full flag set to true when capacity_used == max_capacity
- [ ] ACCEPT button disabled when GameState.capacity_full == true
- [ ] Auto-refuse logic triggers when GameState.capacity_full becomes true
- [ ] Edge case: Accepting exactly 5 customers → auto-refuses remaining 2-5 customers
- [ ] Edge case: Coffee Machine purchased → GameState.max_capacity = 6
- [ ] Edge case: Day 1 with 7 customers, accept 5 → 2 auto-refused
- [ ] Edge case: Day 3 with 10 customers, accept 5 → 5 auto-refused
- [ ] Integration: GameState.is_capacity_full() method returns true/false
- [ ] Integration: Popup checks GameState.is_capacity_full() before enabling ACCEPT button

**Polish Checks (if time permits):**
- [ ] Lock icon appearance is smooth (fade in 0.2s)
- [ ] Tooltip fade-in is smooth (0.15s)
- [ ] Auto-refuse cascade feels satisfying (rhythmic 0.2s delays)

---

## Feature 3.5: Customer Relationship Tracking

**Priority:** HIGH - Core consequence system that tests player strategic thinking across multiple days

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Refusal consequences force careful planning

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 3.3 (Accept/Refuse Logic) - Tracks refusals when player clicks REFUSE
- Feature 1.1 (Game State Manager) - Stores refusal history across days
- Feature 1.4 (Customer Data Structures) - Defines refusal tolerance per customer

---

### Overview

Recurring customers remember if you refuse them. Each recurring customer has a refusal tolerance: Mrs. Kowalski and Dr. Chen tolerate 2 refusals before disappearing permanently, The Stranger tolerates only 1. This system creates long-term consequences for daily decisions, forcing players to balance short-term profit with maintaining valuable customer relationships.

---

### What Player Sees

**Refusal Counter (Customer Card) - Visual Indicator:**

1. **First Refusal:**
   - **Visual Change:** Small yellow warning triangle (▲) appears next to customer name on card
   - **Position:** Right of name, before payment amount
   - **Size:** 24×24px
   - **Tooltip on hover:** "Refused once. Refuse again and they'll stop coming."
   - **Applies to:** Mrs. Kowalski, Dr. Chen only (not The Stranger or one-time customers)

2. **Second Refusal (Relationship Breaks):**
   - **Visual Change:** Card shows "RELATIONSHIP BROKEN" banner in red
   - **Position:** Diagonal banner across card (top-left to bottom-right)
   - **Text:** 20pt, white, bold, on #8B0000 (red) background
   - **Dialogue Box Message:** 
     - Mrs. Kowalski: "I see you're too busy for me. I won't bother you again."
     - Dr. Chen: "I'll find a more reliable translator. Goodbye."
   - **Future Days:** Customer no longer appears in queue

3. **The Stranger - One Refusal:**
   - **Visual Change:** No warning triangle (first refusal = immediate break)
   - **Dialogue Box Message:** "*He nods silently and leaves, never to return.*"
   - **Future Days:** The Stranger never appears again (Days 6-7)

**Relationship Status Panel (Optional Enhancement):**

If time permits, add a small "Relationships" panel to the right panel:

- **Position:** Right panel, below dictionary title
- **Size:** 380px width × 150px height
- **Content:**
  - Mrs. Kowalski: ❤❤ (2 hearts = healthy relationship)
  - Dr. Chen: ❤❤ (2 hearts)
  - The Stranger: ❤ (1 heart = fragile relationship)
- **Hearts Color:** #2D5016 (green) = intact, #8B0000 (red) = broken
- **Update:** Hearts turn red and cross out (❌) when customer is refused

---

### What Player Does

**Player Actions - Refusal Consequences:**

**Scenario 1: Refuse Mrs. Kowalski (Day 1)**

**Input:** Click REFUSE on Mrs. Kowalski popup

**Immediate Response:**
1. **T+0.0s:** Popup closes, Mrs. K card grays out
2. **T+0.15s:** Yellow warning triangle (▲) appears next to her name
3. **T+0.3s:** Dialogue box: "Oh... I understand, dear. Perhaps another time."
4. **T+0.5s:** GameState records: `relationships["Mrs. Kowalski"].refusals = 1`

**Day 2 Consequences:**
- Mrs. Kowalski appears in queue again (still eligible, Days 1-3 window)
- Card shows yellow warning triangle (▲) next to name
- Hover tooltip: "Refused once. Refuse again and they'll stop coming."

**Scenario 2: Refuse Mrs. Kowalski AGAIN (Day 2)**

**Input:** Click REFUSE on Mrs. Kowalski popup (second time)

**Immediate Response:**
1. **T+0.0s:** Popup closes, Mrs. K card grays out
2. **T+0.15s:** "RELATIONSHIP BROKEN" red banner appears diagonally across card
3. **T+0.3s:** Dialogue box: "I see you're too busy for me. I won't bother you again."
4. **T+0.5s:** GameState records: `relationships["Mrs. Kowalski"].broken = true`

**Day 3 Consequences:**
- Mrs. Kowalski does NOT appear in queue (relationship broken)
- Lost potential: $50 Easy job on Day 3 (opportunity cost)

**Scenario 3: Refuse The Stranger (Day 5)**

**Input:** Click REFUSE on The Stranger popup

**Immediate Response:**
1. **T+0.0s:** Popup closes, Stranger card grays out
2. **T+0.15s:** "RELATIONSHIP BROKEN" red banner appears immediately (no warning)
3. **T+0.3s:** Dialogue box: "*He nods silently and leaves, never to return.*"
4. **T+0.5s:** GameState records: `relationships["The Stranger"].broken = true`

**Days 6-7 Consequences:**
- The Stranger does NOT appear in queue (relationship broken after 1 refusal)
- Lost potential: $200 Hard job on Days 6-7 (high opportunity cost)

**Feedback Loop:**
1. **Player action:** Refuses Dr. Chen on Day 2 (first refusal)
2. **Visual change:** Yellow warning triangle appears on Dr. Chen's card
3. **System response:** GameState.relationships["Dr. Chen"].refusals = 1
4. **Next player decision (Day 3):** Accept Dr. Chen to maintain relationship, or refuse again and break it

---

### Acceptance Criteria

**Visual Checks (First Refusal):**
- [ ] After refusing Mrs. Kowalski or Dr. Chen once, yellow warning triangle (▲) appears next to name
- [ ] Triangle size: 24×24px, positioned right of name on card
- [ ] Hover tooltip on triangle: "Refused once. Refuse again and they'll stop coming."
- [ ] Dialogue box shows customer's first refusal message (see Customer Data)

**Visual Checks (Second Refusal - Relationship Breaks):**
- [ ] After refusing Mrs. Kowalski or Dr. Chen twice, "RELATIONSHIP BROKEN" red banner appears
- [ ] Banner is diagonal across card (top-left to bottom-right)
- [ ] Banner text: 20pt white bold on #8B0000 red background
- [ ] Dialogue box shows customer's relationship-broken message
- [ ] Customer no longer appears in future days' queues

**Visual Checks (The Stranger - One Refusal):**
- [ ] After refusing The Stranger once, "RELATIONSHIP BROKEN" banner appears immediately (no warning)
- [ ] Dialogue box: "*He nods silently and leaves, never to return.*"
- [ ] The Stranger does not appear on Days 6-7 (if refused on Day 5)

**Interaction Checks:**
- [ ] Refuse Mrs. K on Day 1 → she appears on Day 2 with warning triangle
- [ ] Refuse Mrs. K on Day 1 AND Day 2 → she does NOT appear on Day 3
- [ ] Refuse Dr. Chen on Day 2 → she appears on Day 3 with warning triangle
- [ ] Refuse Dr. Chen on Day 2 AND Day 3 → she does NOT appear on Day 4
- [ ] Refuse The Stranger on Day 5 → he does NOT appear on Days 6-7
- [ ] Accept Mrs. K on Day 1, refuse on Day 2 → refusal count = 1 (first refusal warning)

**Functional Checks:**
- [ ] GameState.relationships dictionary tracks refusal count per customer
- [ ] Mrs. Kowalski: `refusal_tolerance = 2` (breaks after 2 refusals)
- [ ] Dr. Chen: `refusal_tolerance = 2` (breaks after 2 refusals)
- [ ] The Stranger: `refusal_tolerance = 1` (breaks after 1 refusal)
- [ ] One-time customers: `refusal_tolerance = 0` (no tracking, never return anyway)
- [ ] Feature 3.6 (Daily Queue Generation) checks `relationships[customer].broken` before adding to queue
- [ ] Edge case: Refuse Mrs. K on Day 1, accept on Day 2, refuse on Day 3 → refusal count = 2, relationship breaks
- [ ] Edge case: Accept The Stranger on Day 5 → he appears on Days 6-7 (relationship intact)
- [ ] Edge case: Refuse The Stranger on Day 5, start new game → he appears on Day 5 (reset works)
- [ ] Integration: GameState.refuse_customer(customer_id) increments refusal count
- [ ] Integration: GameState.is_relationship_broken(customer_id) returns true/false

**Polish Checks (if time permits):**
- [ ] Warning triangle appears with subtle fade-in (0.2s)
- [ ] "RELATIONSHIP BROKEN" banner slides in diagonally (0.3s)
- [ ] Relationship status panel (if implemented) updates hearts in real-time
- [ ] Tooltip on warning triangle provides clear guidance

---

## Feature 3.6: Daily Queue Generation

**Priority:** CRITICAL - Generates the customer queue each morning, applying relationship filters

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Ensures 7-10 customers appear, testing capacity constraint

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 3.5 (Customer Relationship Tracking) - Filters out customers with broken relationships
- Feature 1.1 (Game State Manager) - Reads current day number and relationship data
- Feature 1.4 (Customer Data Structures) - Defines customer appearance windows

---

### Overview

Each morning (start of day), the game generates 7-10 customers based on the current day number and relationship status. Recurring customers appear if: (1) current day is within their appearance window, AND (2) relationship is not broken. Random one-time customers fill remaining slots to reach 7-10 total.

---

### What Player Sees

**Day Start - Queue Generation Sequence:**

1. **Day Transition Screen:**
   - **Visual:** "Day 2 - Tuesday" title card appears centered (0.5s)
   - **Fade Out:** Transition screen fades out (0.3s)
   - **Fade In:** Main UI fades in with new customer queue visible

2. **Left Panel - Customer Queue:**
   - **Visual:** 7-10 customer cards appear stacked vertically
   - **Animation:** Cards fade in from top to bottom (0.1s delay between each card)
   - **Composition Examples:**
     - **Day 1:** Mrs. Kowalski + 6 random customers (7 total)
     - **Day 2:** Mrs. Kowalski + Dr. Chen + 5-8 random customers (7-10 total)
     - **Day 5:** Mrs. Kowalski + Dr. Chen + The Stranger + 4-7 random customers (7-10 total)
     - **Day 3 (if Mrs. K refused 2×):** Dr. Chen + 6-9 random customers (7-10 total, Mrs. K absent)

3. **Queue Variety - Random Customer Types:**

Random customers have varied properties:
- **Names:** Generate from pool: "Scholar Martinez", "Collector Wu", "Student Ibrahim", "Historian Novak", etc.
- **Payment Range:** $40-$120 (randomized)
- **Difficulty Range:** Easy (40%), Medium (40%), Hard (20%) distribution
- **Priorities:** Randomized from: "Fast + Cheap", "Fast + Accurate", "Cheap + Accurate"
- **Dialogue:** Generic greetings like "I need help with this text" or "Can you translate this for me?"

---

### What Player Does

**Player Experience - Day Start Flow:**

**Scenario: Start of Day 2**

**Input:** Day 1 ends (complete 5 translations, pay utilities), Day 2 begins

**Immediate Response:**
1. **T+0.0s:** Day transition screen appears: "Day 2 - Tuesday"
2. **T+0.5s:** Transition screen fades out
3. **T+0.8s:** Main UI fades in
4. **T+1.0s:** Customer queue begins populating (cards fade in top-to-bottom)
5. **T+1.2s:** First card appears: Mrs. Kowalski (if relationship intact)
6. **T+1.3s:** Second card appears: Dr. Chen
7. **T+1.4s → T+1.9s:** Random customers fill remaining 5-8 slots (0.1s delay each)
8. **T+2.0s:** Queue complete, all 7-10 cards visible
9. **T+2.1s:** Capacity counter resets to "0/5 Customers Served" (gray)
10. **T+2.2s:** Player can click cards to begin selecting customers

**Feedback Loop:**
1. **System action:** Day 2 starts, queue generation runs
2. **Visual change:** 7-10 customer cards appear in left panel
3. **Player observation:** Sees Mrs. K and Dr. Chen (recurring) + 5-8 new faces (random)
4. **Next player decision:** Click cards to evaluate customers, choose which 5 to accept

---

### Acceptance Criteria

**Visual Checks (Queue Generation):**
- [ ] At day start, left panel displays 7-10 customer cards (never fewer, never more)
- [ ] Cards fade in from top to bottom with 0.1s delay between each
- [ ] Recurring customers appear first in queue, then random customers
- [ ] Each card shows: name, payment, difficulty badge, description, priorities

**Visual Checks (Recurring Customer Logic):**
- [ ] Day 1: Mrs. Kowalski appears (if relationship intact)
- [ ] Day 2: Mrs. Kowalski + Dr. Chen appear (if relationships intact)
- [ ] Day 3: Mrs. Kowalski + Dr. Chen appear (if relationships intact)
- [ ] Day 4: Dr. Chen appears (Mrs. K window ended, Days 1-3 only)
- [ ] Day 5: Dr. Chen + The Stranger appear (if relationships intact)
- [ ] Day 6: Dr. Chen + The Stranger appear (if relationships intact)
- [ ] Day 7: Dr. Chen + The Stranger appear (if relationships intact)

**Visual Checks (Relationship Filtering):**
- [ ] If Mrs. K refused 2× (Days 1-2), she does NOT appear on Day 3
- [ ] If Dr. Chen refused 2× (any 2 days), she does NOT appear in future queues
- [ ] If The Stranger refused 1× (Day 5), he does NOT appear on Days 6-7
- [ ] Broken relationship customers are replaced with random customers (queue still 7-10 total)

**Interaction Checks:**
- [ ] Day transition completes within 2.2s (from transition screen to clickable queue)
- [ ] Queue cards are clickable immediately after fade-in completes
- [ ] Capacity counter resets to "0/5" at day start (gray color)
- [ ] Previous day's accepted/refused customers are cleared (fresh queue)

**Functional Checks:**
- [ ] Queue generation checks GameState.current_day to determine which recurring customers are eligible
- [ ] Mrs. Kowalski: Appears on Days 1-3 only (if `relationships["Mrs. Kowalski"].broken == false`)
- [ ] Dr. Chen: Appears on Days 2-7 only (if `relationships["Dr. Chen"].broken == false`)
- [ ] The Stranger: Appears on Days 5-7 only (if `relationships["The Stranger"].broken == false`)
- [ ] Random customers fill remaining slots: `random_count = random(7, 10) - recurring_count`
- [ ] Random customer properties randomized:
  - Payment: `random_range(40, 120)` rounded to nearest $10
  - Difficulty: 40% Easy, 40% Medium, 20% Hard
  - Priorities: Random selection from ["Fast+Cheap", "Fast+Accurate", "Cheap+Accurate"]
- [ ] Edge case: Day 1, all relationships intact → 1 recurring (Mrs. K) + 6 random = 7 total
- [ ] Edge case: Day 5, all relationships intact → 3 recurring (Mrs. K, Dr. Chen, Stranger) + 4-7 random = 7-10 total
- [ ] Edge case: Day 7, all recurring refused → 0 recurring + 7-10 random = 7-10 total
- [ ] Edge case: Day 4, Mrs. K window ended → Dr. Chen + 6-9 random = 7-10 total (Mrs. K absent even if relationship intact)
- [ ] Integration: CustomerData.get_recurring_customers(day) returns eligible recurring customers
- [ ] Integration: CustomerData.generate_random_customer() creates random customer data
- [ ] Integration: GameState.is_relationship_broken(customer_id) filters broken relationships

**Polish Checks (if time permits):**
- [ ] Day transition screen is clean and professional
- [ ] Card fade-in cascade creates satisfying rhythm (0.1s delays)
- [ ] Queue feels fresh each day (different random customers, varied names)
- [ ] Random customer names feel believable (cultural variety)

---

## INTEGRATION CHECKLIST

These features work together as a system. Verify integration:

- [ ] **3.1 → 3.2:** Clicking customer card in queue opens selection popup with correct customer data
- [ ] **3.2 → 3.3:** Clicking ACCEPT/REFUSE buttons in popup executes accept/refuse logic
- [ ] **3.3 → 3.4:** Accepting 5th customer triggers capacity enforcement (ACCEPT buttons disable)
- [ ] **3.3 → 3.5:** Refusing recurring customer increments refusal count, tracks relationship
- [ ] **3.5 → 3.6:** Broken relationships prevent customer from appearing in future queues
- [ ] **3.6 → 3.1:** Daily queue generation populates left panel with 7-10 customer cards
- [ ] **3.3 → 2.3:** Accepting customer loads their translation text in workspace (Feature 2.3)
- [ ] **3.3 → 1.1:** Accept/refuse updates GameState (capacity_used, accepted_customers, refused_customers)

---

## TESTING PROTOCOL

**Day 1 Acceptance Test (15 minutes):**

1. Start new game, verify Day 1 queue has 7 customers (Mrs. K + 6 random)
2. Click Mrs. Kowalski card → popup opens with "$50, Easy, Cheap+Accurate"
3. Click ACCEPT → popup closes, Mrs. K card shows green checkmark, capacity: 1/5
4. Accept 4 more customers → capacity reaches 5/5, remaining 2 customers auto-refuse
5. Verify remaining 2 cards grayed out with red X, ACCEPTED cards show green checkmarks

**Refusal Consequence Test (10 minutes):**

1. Start Day 1, refuse Mrs. Kowalski → yellow warning triangle appears on card
2. Advance to Day 2 → Mrs. K appears in queue with warning triangle
3. Refuse Mrs. K again → "RELATIONSHIP BROKEN" banner appears
4. Advance to Day 3 → Mrs. K does NOT appear in queue (replaced with random customer)

**Capacity Enforcement Test (5 minutes):**

1. Start Day 2, accept 5 customers
2. Click 6th customer card → popup opens, ACCEPT button grayed out
3. Hover ACCEPT → tooltip: "Shop is full (5/5 capacity)"
4. Click ACCEPT → nothing happens (button non-interactive)
5. Click REFUSE → works normally (customer card grays out)

**The Stranger Sensitivity Test (5 minutes):**

1. Advance to Day 5 → The Stranger appears in queue
2. Refuse The Stranger → "RELATIONSHIP BROKEN" banner appears immediately (no warning)
3. Advance to Day 6 → The Stranger does NOT appear in queue
4. Advance to Day 7 → The Stranger still does NOT appear (permanent loss)

---

## VISUAL REFERENCE - COLOR CODES

Copy-paste these hex codes for implementation:

- **Cream parchment (backgrounds):** `#F4E8D8`
- **Dark brown (text, borders):** `#3A2518`
- **Beige desk (main background):** `#D4B896`
- **Green (money, success, ACCEPT):** `#2D5016`
- **Red (failure, REFUSE):** `#8B0000`
- **Gold (highlights, hover):** `#FFD700`
- **Gray (disabled, refused):** `#CCCCCC`
- **Orange (Medium difficulty):** `#FF8C00`
- **Light green tint (accepted cards):** `#E8F5E0`

---

## TIME ESTIMATES SUMMARY

| Feature | Estimated Time | Critical Path |
|---------|----------------|---------------|
| 3.1 Customer Queue Display | 1.0 hours | Yes |
| 3.2 Customer Selection Popup | 0.75 hours | Yes |
| 3.3 Accept/Refuse Logic | 0.75 hours | Yes |
| 3.4 Capacity Enforcement | 0.5 hours | Yes |
| 3.5 Customer Relationship Tracking | 0.5 hours | No (can simplify) |
| 3.6 Daily Queue Generation | 0.5 hours | Yes |
| **TOTAL** | **4.0 hours** | |

**Buffer:** +1 hour for integration, testing, polish = **5 hours total** (fits within 6-9 hour window)

**Simplification if over time:**
- Cut Feature 3.5 relationship tracking → All customers one-time only (removes consequence depth but preserves capacity constraint)
- Reduce random customer variety → Fixed pool of 10 customers, randomize order

---

## NEXT PHASE

After Phase 3 complete, proceed to **Phase 4: Engaging Texture** (Hours 9-12):
- Feature 4.1: Book Examination Phase
- Feature 4.2: UV Light Tool
- Feature 4.3: Negotiation Display
- Feature 4.4: Multi-Day Progression

Phase 3 establishes the strategic choice layer. Phase 4 adds texture and depth to make choices more engaging.
