# PHASE 4: Engaging Texture - Feature Specifications

## Context
- **Game:** Glyphic - Translation Shop Puzzle Game
- **Phase Goal:** Book examination tools work, negotiation affects constraints, multi-day progression functions, rent pressure exists
- **Estimated Duration:** 3 hours (Hours 9-12 of prototype)
- **Features in Phase:** 
  1. Book Examination Phase (4.1)
  2. UV Light Tool (4.2)
  3. Customer Negotiation Display (4.3)
  4. Negotiation Constraint Effects (4.4)
  5. Multi-Day Progression System (4.5)
  6. Rent Deadline & Game Over (4.6)

---

## Feature 4.1: Book Examination Phase

**Priority:** MEDIUM - Tests whether examination adds engaging texture or feels like busywork

**Tests Critical Question:** Q3 (Book examination adds engaging texture) - Core testable feature for this question

**Estimated Time:** 1.0 hours

**Dependencies:** 
- Feature 3.3 (Accept/Refuse Logic) - Triggered after accepting customer
- Feature 2.3 (Translation Workspace) - Proceeds to translation after examination

---

### Overview

After accepting a customer, an optional "Examine Book" screen appears showing the book cover with an interactive zoom tool. Players can click-drag to magnify portions of the cover 2× in an inset panel, or skip directly to translation. This tests whether players find pre-puzzle investigation valuable or prefer to jump straight into translation.

---

### What Player Sees

**Screen Layout:**

**Full-Screen Examination Mode:**
- **Position:** Replaces translation workspace (420, 90) to (1500, 780)
- **Size:** 1080px width × 690px height (center workspace area)
- **Background:** #3A2518 (dark brown, like examining book on desk)

**Book Cover Display:**
- **Position:** Center of examination area (660, 235) - centered horizontally
- **Size:** 600px width × 800px height (book aspect ratio)
- **Visual:** Book cover texture sprite (placeholder: cream parchment with aged border)
- **Border:** 4px solid #8B4513 (saddle brown, leather binding effect)
- **Shadow:** 12px offset, 24px blur, #000000 at 50% opacity (book sits on desk)

**Zoom Inset Panel:**
- **Position:** Bottom-right of examination area (1180, 570)
- **Size:** 300px width × 300px height (square magnification window)
- **Background:** #000000 (black border, 4px)
- **Content:** 2× magnified portion of book cover (follows mouse position)
- **Border:** 4px solid #FFD700 (gold, indicates active tool)
- **Label:** "2× ZOOM" in top-left corner (18pt white text)

**Toolbar (Bottom of Examination Area):**
- **Position:** Bottom of workspace (420, 780)
- **Size:** 1080px width × 80px height
- **Background:** #2B2520 (dark brown panel)
- **Buttons:**
  - **Skip Button:** 
    - Position: (900, 800) - right side of toolbar
    - Size: 200px × 50px
    - Background: #3A2518 (dark brown)
    - Text: "SKIP EXAMINATION" (18pt, #F4E8D8 cream)
    - Border: 2px solid #FFD700 (gold)
  - **UV Light Button (if purchased):**
    - Position: (680, 800) - left of skip button
    - Size: 180px × 50px
    - Background: #4B0082 (indigo/purple)
    - Text: "UV LIGHT" (18pt, white)
    - Border: 2px solid #9370DB (medium purple)
    - Icon: Small UV lamp icon (24×24px) to left of text

**Customer Info Header:**
- **Position:** Top of examination area (420, 100)
- **Size:** 1080px width × 60px height
- **Background:** Semi-transparent #000000 (40% opacity overlay)
- **Text:** "Examining book for: Mrs. Kowalski" (24pt, #F4E8D8 cream, centered)

**Visual States:**

- **Default State:** Book cover visible, zoom inset shows 2× magnification of center area
- **Hover State (Book):** Crosshair cursor appears when hovering over book, zoom inset updates in real-time
- **Hover State (Skip Button):** Button background lightens to #4A3828, border glows gold (3px)
- **Hover State (UV Button):** Button background lightens to #6A0DAD (brighter purple), border glows
- **Active State (UV On):** Book texture changes to purple-tinted version, UV button shows "ON" indicator (green dot)

**Visual Feedback:**

- **On examination start:** Screen fades from customer popup to examination view (0.3s)
- **On mouse move over book:** Zoom inset updates in real-time (no lag), crosshair follows cursor
- **On skip button click:** Examination fades out (0.2s), translation workspace fades in (0.3s)
- **On UV button click:** Book texture transitions to UV version (0.5s purple tint fade-in), hidden text overlays appear

---

### What Player Does

**Input Methods:**

- **Mouse:** 
  - Move cursor over book → Zoom inset follows cursor position, shows 2× magnified view
  - Click Skip button → Proceed directly to translation
  - Click UV Light button (if purchased) → Toggle UV mode on/off
- **Keyboard:**
  - Spacebar → Same as clicking Skip button (quick skip)
  - U key → Toggle UV Light (if purchased)
  - Escape → Same as clicking Skip button

**Immediate Response:**

- **Move mouse over book** → Zoom inset updates within 0.05s, crosshair cursor appears
- **Move mouse off book** → Crosshair returns to default cursor
- **Click Skip button** → Button flashes gold (0.1s), examination fades out (0.2s), translation loads (0.3s total)
- **Click UV button** → Button shows "ON" indicator, book texture transitions to purple tint (0.5s), hidden text appears
- **Press Spacebar** → Instant skip to translation (same as clicking Skip)

**Feedback Loop:**

1. **Player action:** Moves mouse over top-left corner of book cover
2. **Visual change:** Zoom inset updates to show 2× magnified top-left corner, crosshair cursor active
3. **System response:** Examination.update_zoom(mouse_position) calculates magnification region
4. **Next player decision:** Continue examining other areas, click UV to reveal hidden text, or skip to translation

**Example Interaction Flow:**
```
Player accepts Mrs. Kowalski
→ Examination screen fades in (0.3s)
→ Book cover appears in center, zoom inset shows 2× magnified center
→ Player moves mouse over book's spine area
→ Zoom inset updates to show 2× spine detail (title text visible)
→ Player moves mouse over book's corner
→ Zoom inset shows 2× corner detail (aged paper texture visible)
→ Player decides examination isn't helpful for this book
→ Player clicks "SKIP EXAMINATION" button
→ Button flashes gold, examination fades out
→ Translation workspace loads with Mrs. K's text ("∆ ◊≈ ⊕⊗◈")
→ Player begins translation puzzle
```

**Alternative Flow (UV Light):**
```
Player accepts Dr. Chen (after purchasing UV Light)
→ Examination screen appears with UV Light button visible
→ Player clicks "UV LIGHT" button
→ Book texture transitions to purple tint (0.5s)
→ Hidden text overlays appear: "Previous owner: Margaret K."
→ Player reads clue (connects to Mrs. Kowalski family history)
→ Player clicks "SKIP EXAMINATION" to proceed
→ Translation workspace loads
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Examination screen appears after accepting customer (0.3s fade-in)
- [ ] Book cover displays centered at (660, 235) with 600×800px dimensions
- [ ] Book has 4px saddle brown border (#8B4513) and 12px shadow
- [ ] Zoom inset panel appears at (1180, 570) with 300×300px dimensions
- [ ] Zoom inset shows "2× ZOOM" label in top-left corner (18pt white)
- [ ] Zoom inset has 4px gold border (#FFD700)
- [ ] Customer info header shows "Examining book for: [Customer Name]" at top
- [ ] Skip button displays "SKIP EXAMINATION" (200×50px) at (900, 800)
- [ ] Toolbar has dark brown background (#2B2520) across bottom

**Visual Checks (UV Light - if purchased):**
- [ ] UV Light button appears at (680, 800) with purple background (#4B0082)
- [ ] UV button shows UV lamp icon (24×24px) to left of text
- [ ] UV button is NOT visible if UV Light upgrade not purchased

**Interaction Checks:**
- [ ] Move mouse over book → crosshair cursor appears, zoom inset updates within 0.05s
- [ ] Zoom inset follows mouse position in real-time (no lag or stutter)
- [ ] Zoom inset shows 2× magnified portion of book cover matching cursor position
- [ ] Move mouse to top-left corner → zoom shows top-left at 2× magnification
- [ ] Move mouse to bottom-right corner → zoom shows bottom-right at 2× magnification
- [ ] Hover Skip button → background lightens, border glows gold (3px)
- [ ] Click Skip button → button flashes gold (0.1s), examination fades out (0.2s), translation loads (0.3s)
- [ ] Press Spacebar → same result as clicking Skip button
- [ ] Click UV button (if purchased) → book transitions to purple tint (0.5s), hidden text appears
- [ ] Click UV button again → toggle off (purple tint fades out, hidden text disappears)

**Functional Checks:**
- [ ] Examination screen triggered after Feature 3.3 accept logic completes
- [ ] Zoom calculation: `zoom_region = (mouse_x - 150, mouse_y - 150, 300, 300)` (300px square centered on cursor)
- [ ] Magnification renders book texture at 2× scale in zoom inset (no pixelation)
- [ ] Skip button proceeds to Feature 2.3 (Translation Workspace) with accepted customer's text
- [ ] UV button only appears if GameState.upgrades["UV Light"] == true
- [ ] UV mode reveals hidden text overlays (stored in book metadata)
- [ ] Edge case: If no book texture loaded, show placeholder cream parchment rectangle
- [ ] Edge case: Move mouse off book area → zoom inset shows last valid position (doesn't break)
- [ ] Edge case: Rapid Skip clicks don't cause double-transition or errors
- [ ] Integration: Examination.load_book(customer_id) fetches book texture from CustomerData
- [ ] Integration: Examination.skip() calls TranslationWorkspace.load_text(text_id)

**Polish Checks (if time permits):**
- [ ] Zoom inset transition is smooth (interpolates between positions if lagging)
- [ ] Book cover has realistic aged paper texture (not flat color)
- [ ] UV Light transition feels satisfying (purple tint + hidden text reveal)
- [ ] Crosshair cursor is custom sprite (not default system crosshair)

---

## Feature 4.2: UV Light Tool (Upgrade)

**Priority:** LOW - Optional enhancement, can be cut if time runs short

**Tests Critical Question:** Q3 (Book examination adds engaging texture) - Tests if tools make examination more valuable

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 4.1 (Book Examination Phase) - UV button appears in examination toolbar
- Feature 5.3 (Upgrade Shop - Phase 5) - UV Light must be purchased first

---

### Overview

If the UV Light upgrade is purchased ($500), a UV button appears in the examination toolbar. Clicking it toggles UV mode, which applies a purple tint to the book texture and reveals hidden text overlays (ownership marks, warnings). This tests whether examination tools provide valuable clues or are ignored by players.

---

### What Player Sees

**UV Light Button (in Examination Toolbar):**

- **Position:** (680, 800) - left of Skip button in toolbar
- **Size:** 180px width × 50px height
- **Background:** #4B0082 (indigo/purple)
- **Text:** "UV LIGHT" (18pt, white, bold)
- **Icon:** UV lamp icon (24×24px) to left of text (purple/white gradient)
- **Border:** 2px solid #9370DB (medium purple)

**UV Mode Active State:**

- **Button Appearance:**
  - Background: #6A0DAD (brighter purple)
  - Border: 3px solid #DA70D6 (orchid, glowing effect)
  - "ON" Indicator: Small green dot (12×12px circle) in top-right corner of button
  - Text: "UV LIGHT (ON)" (18pt, white, bold)

**Book Texture Changes (UV Mode On):**

1. **Purple Tint Overlay:**
   - Semi-transparent purple overlay (#8A2BE2 at 40% opacity) covers entire book texture
   - Applied via shader/ColorRect overlay (0.5s fade-in transition)

2. **Hidden Text Overlays:**
   - **Ownership Mark (Top-Right Corner):**
     - Position: (book_x + 450, book_y + 50) - top-right corner of book
     - Text: "Previous owner: Margaret K." (16pt, #00FFFF cyan, glowing effect)
     - Background: Semi-transparent #000000 (60% opacity, 4px padding)
   - **Warning Text (Bottom Edge):**
     - Position: (book_x + 200, book_y + 750) - bottom center of book
     - Text: "⚠ Warning: Handle with care" (16pt, #FFFF00 yellow, glowing effect)
     - Background: Semi-transparent #000000 (60% opacity, 4px padding)
   - **Fade-In:** Hidden text fades in over 0.3s after purple tint applies

**Zoom Inset Updates (UV Mode):**

- Zoom inset shows purple-tinted 2× magnification of book
- If zoomed over hidden text area, text is readable at 2× scale (easier to read small cyan/yellow text)

**Visual States:**

- **UV Off (Default):** Button shows normal purple background, no "ON" indicator, book shows normal texture
- **UV On (Active):** Button shows brighter purple, green "ON" dot, book shows purple tint + hidden text
- **Hover (UV Off):** Button background lightens to #6A0DAD, border glows
- **Hover (UV On):** Button background brightens to #8B00FF, border glows brighter

**Visual Feedback:**

- **On UV button click (off → on):** Button flashes white (0.1s), purple tint fades in (0.5s), hidden text appears (0.3s delay)
- **On UV button click (on → off):** Button flashes white (0.1s), purple tint fades out (0.3s), hidden text fades out (0.2s)
- **Toggle animation:** Smooth transitions, not instant snaps

---

### What Player Does

**Input Methods:**

- **Mouse:** Click UV Light button to toggle UV mode on/off
- **Keyboard:** Press U key to toggle UV mode on/off

**Immediate Response:**

- **Click UV button (off → on):**
  - T+0.0s: Button flashes white
  - T+0.1s: Green "ON" indicator appears on button
  - T+0.2s: Purple tint begins fading in over book texture
  - T+0.7s: Purple tint fully applied
  - T+0.8s: Hidden text overlays fade in
  - T+1.1s: UV mode fully active, player can examine hidden text with zoom

- **Click UV button (on → off):**
  - T+0.0s: Button flashes white
  - T+0.1s: Green "ON" indicator disappears
  - T+0.2s: Hidden text fades out
  - T+0.4s: Purple tint begins fading out
  - T+0.7s: Book returns to normal texture

**Feedback Loop:**

1. **Player action:** Clicks UV Light button
2. **Visual change:** Button shows "ON" indicator, book texture transitions to purple tint, hidden text appears
3. **System response:** Examination.uv_mode = true, overlay renders, hidden text objects enabled
4. **Next player decision:** Use zoom to read hidden text closely, note clues for translation, or skip to translation

**Example Interaction Flow:**
```
Player purchases UV Light upgrade ($500)
→ Player accepts Dr. Chen (Day 3)
→ Examination screen appears with UV Light button visible
→ Player examines book normally first (zooms around cover)
→ Player clicks "UV LIGHT" button
→ Button shows green "ON" indicator
→ Purple tint fades over book texture (0.5s)
→ Hidden text appears: "Previous owner: Margaret K."
→ Player realizes: "Mrs. Kowalski's family book connects to Dr. Chen's research!"
→ Player uses zoom to read warning text: "⚠ Handle with care"
→ Player notes clues, clicks "SKIP EXAMINATION"
→ Translation workspace loads
→ Player uses clues to inform translation choices (thematic connection)
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] UV Light button appears in toolbar at (680, 800) if UV Light purchased
- [ ] UV button is 180×50px with purple background (#4B0082)
- [ ] UV button shows UV lamp icon (24×24px) to left of "UV LIGHT" text
- [ ] UV button does NOT appear if UV Light upgrade not purchased (GameState.upgrades["UV Light"] == false)

**Visual Checks (UV Mode On):**
- [ ] Button shows green "ON" indicator (12×12px dot) in top-right corner
- [ ] Button text changes to "UV LIGHT (ON)"
- [ ] Button background brightens to #6A0DAD
- [ ] Book texture shows purple tint overlay (#8A2BE2 at 40% opacity)
- [ ] Hidden text "Previous owner: Margaret K." appears in top-right corner (16pt cyan)
- [ ] Hidden text "⚠ Warning: Handle with care" appears at bottom center (16pt yellow)
- [ ] Hidden text has semi-transparent black background (60% opacity, 4px padding)
- [ ] Zoom inset shows purple-tinted 2× magnification (includes hidden text if zoomed over it)

**Interaction Checks:**
- [ ] Click UV button (off → on) → button flashes white, purple tint fades in over 0.5s, hidden text appears after 0.3s delay
- [ ] Click UV button (on → off) → button flashes white, hidden text fades out, purple tint fades out over 0.3s
- [ ] Press U key → same result as clicking UV button (toggle on/off)
- [ ] Hover UV button → background lightens, border glows
- [ ] Rapid UV toggle clicks don't break animation (queues transitions properly)
- [ ] UV mode persists while examining (doesn't auto-disable)
- [ ] Clicking Skip while UV on → UV state doesn't affect translation workspace (examination state isolated)

**Functional Checks:**
- [ ] UV button only appears if GameState.upgrades["UV Light"] == true
- [ ] UV mode toggles: Examination.uv_mode = !Examination.uv_mode
- [ ] Purple tint applied via ColorRect overlay or shader (not baked into texture)
- [ ] Hidden text content pulled from book metadata: CustomerData.books[book_id].hidden_text
- [ ] Hidden text positions calculated relative to book position (not hardcoded absolute positions)
- [ ] Edge case: If book has no hidden text defined, UV mode shows purple tint but no text (no errors)
- [ ] Edge case: Clicking UV Light 10× rapidly → toggle state remains consistent (no desync)
- [ ] Integration: UV Light upgrade purchased via Feature 5.3 (Upgrade Shop)
- [ ] Integration: Book metadata includes hidden_text field for UV-revealed clues

**Polish Checks (if time permits):**
- [ ] Purple tint transition is smooth (ease-in-out curve, not linear)
- [ ] Hidden text has subtle glow effect (outer glow shader)
- [ ] UV lamp icon animates slightly when UV mode active (pulsing glow)
- [ ] Hidden text positions vary per book (not always same spots)

---

## Feature 4.3: Customer Negotiation Display

**Priority:** MEDIUM - Enhances strategic decision-making, already partially implemented in Phase 3

**Tests Critical Question:** Q4 (Customer negotiation creates variety) - Visual display of negotiation priorities

**Estimated Time:** 0.25 hours

**Dependencies:** 
- Feature 3.2 (Customer Selection Popup) - Negotiation info displayed in popup
- Feature 1.4 (Customer Data Structures) - Customer priorities defined

---

### Overview

The customer selection popup (Feature 3.2) already shows negotiation priorities. This feature adds clearer visual presentation and constraint descriptions, explaining what each priority combination means mechanically. Priorities are preset per customer (not player-negotiated), testing if preset priorities create enough variety.

---

### What Player Sees

**Negotiation Section (in Customer Selection Popup):**

**Section Position:**
- **Location:** Below translation info, above ACCEPT/REFUSE buttons in popup
- **Position:** y: 300 (within 600×500px popup)
- **Size:** 560px width × 120px height
- **Background:** #E8F5E0 (light green tint, distinct from popup cream background)
- **Border:** 2px solid #2D5016 (green), top and bottom only (horizontal dividers)

**Priority Badges:**

**Visual Layout:**
```
Customer Priorities:
 [✓ CHEAP]  [✓ ACCURATE]  [✗ FAST]
```

- **Badge Dimensions:** 160px width × 40px height
- **Spacing:** 10px gap between badges
- **Position:** Centered horizontally in negotiation section

**Badge Appearance (Selected Priority):**
- **Background:** #2D5016 (green)
- **Border:** 2px solid #1A3009 (dark green)
- **Text:** Priority name in 18pt white, bold, uppercase
- **Icon:** Green checkmark (✓) to left of text (20×20px, white)
- **Corner Radius:** 4px

**Badge Appearance (Not Selected Priority):**
- **Background:** #CCCCCC (gray)
- **Border:** 2px solid #888888 (dark gray)
- **Text:** Priority name in 18pt #666666 (dark gray), bold, uppercase
- **Icon:** Red X (✗) to left of text (20×20px, #8B0000)
- **Corner Radius:** 4px

**Constraint Description Text:**

- **Position:** Below priority badges, y: 350
- **Size:** 520px width × 60px height (2 lines of text)
- **Text:** Explanation of what selected priorities mean
- **Font:** 18pt, #3A2518 (dark brown), regular weight
- **Alignment:** Center-aligned

**Constraint Text Examples:**

| Customer | Priorities | Constraint Description |
|----------|-----------|----------------------|
| Mrs. Kowalski | Cheap + Accurate | "Low payment (50% reduction), no time limit, must be perfect" |
| Dr. Chen | Fast + Accurate | "Normal payment, quick turnaround expected, must be perfect" |
| The Stranger | Fast + Accurate | "High payment, urgent delivery, must be perfect" |
| Random (Cheap) | Cheap + Fast | "Low payment (50% reduction), quick turnaround, mistakes forgiven" |

**Visual States:**

- **Default:** Negotiation section visible in popup, priorities and description displayed
- **No Hover State:** Badges are informational only (not interactive in prototype)
- **Tooltip (if time permits):** Hovering individual badges shows detailed explanation
  - Cheap: "Payment reduced by 50%"
  - Accurate: "Customer expects perfect translation (no mistakes)"
  - Fast: "Flavor only in prototype (no mechanical effect)"

---

### What Player Does

**Input Methods:**

- **Mouse:** Read negotiation section in popup (no interaction required)
- **Visual Scan:** Player reads priorities and constraint description to inform accept/refuse decision

**Information Flow:**

1. **Player action:** Clicks customer card in queue
2. **Visual change:** Popup opens, negotiation section shows priorities (2 selected, 1 not selected)
3. **Player observation:** Sees "CHEAP + ACCURATE" badges, reads "Low payment, must be perfect"
4. **Next player decision:** Decide if 50% payment reduction is acceptable, or refuse and find better-paying customer

**Example Interaction Flow:**
```
Player clicks "Mrs. Kowalski" card
→ Popup opens showing:
   - Payment: $50 (but negotiation shows Cheap priority)
   - Priorities: [✓ CHEAP] [✓ ACCURATE] [✗ FAST]
   - Description: "Low payment (50% reduction), no time limit, must be perfect"
→ Player realizes: "$50 shown, but Cheap = 50% reduction → actual payment is $25"
→ Player thinks: "Day 1, I need money... but $25 is very low. Accept or find better customer?"
→ Player checks other customers in queue
→ Player clicks "Dr. Chen" card
→ Popup shows:
   - Payment: $100
   - Priorities: [✓ FAST] [✓ ACCURATE] [✗ CHEAP]
   - Description: "Normal payment, quick turnaround expected, must be perfect"
→ Player realizes: "Dr. Chen pays full $100, no reduction. Better deal!"
→ Player clicks ACCEPT on Dr. Chen
```

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Negotiation section appears in customer selection popup below translation info
- [ ] Negotiation section has light green background (#E8F5E0) with green borders (#2D5016)
- [ ] Section is 560×120px, positioned at y: 300 in popup
- [ ] "Customer Priorities:" header appears above badges (20pt, dark brown, bold)
- [ ] Three priority badges display horizontally: CHEAP, ACCURATE, FAST (160×40px each, 10px gaps)
- [ ] Selected priorities (2 per customer) show green background with white checkmark (✓)
- [ ] Not selected priority (1 per customer) shows gray background with red X (✗)
- [ ] Constraint description text appears below badges (18pt, dark brown, center-aligned)

**Visual Checks (Priority Combinations):**
- [ ] Mrs. Kowalski: [✓ CHEAP] [✓ ACCURATE] [✗ FAST], description: "Low payment (50% reduction), no time limit, must be perfect"
- [ ] Dr. Chen: [✓ FAST] [✓ ACCURATE] [✗ CHEAP], description: "Normal payment, quick turnaround expected, must be perfect"
- [ ] The Stranger: [✓ FAST] [✓ ACCURATE] [✗ CHEAP], description: "High payment, urgent delivery, must be perfect"
- [ ] Random customers: Varied combinations (Cheap+Fast, Cheap+Accurate, Fast+Accurate)

**Interaction Checks:**
- [ ] Open popup → negotiation section visible immediately (no delay or loading)
- [ ] Priority badges are static (no hover or click effects in prototype)
- [ ] Constraint description text is readable (not truncated or overlapping)
- [ ] Popup remains functional (ACCEPT/REFUSE buttons work with negotiation section present)

**Functional Checks:**
- [ ] Negotiation data pulled from CustomerData: `customer.priorities = ["Cheap", "Accurate"]`
- [ ] Badge rendering logic: If priority in customer.priorities → green with ✓, else gray with ✗
- [ ] Constraint description generated from priority combination:
  - Cheap + Accurate → "Low payment (50% reduction), no time limit, must be perfect"
  - Fast + Accurate → "Normal payment, quick turnaround expected, must be perfect"
  - Cheap + Fast → "Low payment (50% reduction), quick turnaround, mistakes forgiven"
- [ ] Edge case: Customer with only 1 priority → show that priority + "None" for missing second priority (shouldn't happen in prototype)
- [ ] Edge case: Customer with 3 priorities → show all 3 as selected (shouldn't happen in prototype, max 2 selected)
- [ ] Integration: CustomerData.customers[id].priorities array defines which badges are green
- [ ] Integration: Feature 4.4 (Negotiation Constraint Effects) uses this data for payment calculation

**Polish Checks (if time permits):**
- [ ] Badge checkmark/X icons are crisp vector graphics (not pixelated)
- [ ] Constraint description text uses line breaks if too long (doesn't overflow)
- [ ] Tooltips on individual badges provide detailed explanations
- [ ] Negotiation section visually separates from rest of popup (clear hierarchy)

---

## Feature 4.4: Negotiation Constraint Effects

**Priority:** HIGH - Mechanical enforcement of negotiation priorities, creates actual variety

**Tests Critical Question:** Q4 (Customer negotiation creates variety) - Priorities have real impact on gameplay

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 4.3 (Customer Negotiation Display) - Priorities displayed to player
- Feature 3.3 (Accept/Refuse Logic) - Payment calculation happens after accept
- Feature 2.4 (Translation Validation) - Accuracy checking for "Accurate" priority

---

### Overview

Negotiation priorities have mechanical effects: "Cheap" reduces payment by 50%, "Accurate" shows a warning message on translation failure (no penalty in prototype), "Fast" is dialogue flavor only. This creates variety in customer value propositions, forcing players to balance low-paying-but-easy customers with high-paying-but-demanding ones.

---

### What Player Sees

**Cheap Priority - Payment Reduction:**

**In Customer Selection Popup:**
- **Payment Display:** Shows base payment with strikethrough, reduced payment next to it
- **Example:** 
  - Mrs. Kowalski: ~~$50~~ **$25** (16pt red strikethrough, 22pt green bold)
  - Text below: "(Cheap priority: 50% reduction)"

**After Translation Completion:**
- **Cash Counter Update:** Increments by reduced amount ($25 instead of $50)
- **Dialogue Box:** "Mrs. Kowalski pays you $25. 'Thank you, dear!'" (18pt, dark brown)

**Accurate Priority - Failure Warning:**

**After Submitting Incorrect Translation:**
- **Dialogue Box Update:** Special warning message appears
- **Text:** "Mrs. Kowalski looks disappointed. 'This doesn't seem right... accuracy was critical to me.'" (18pt, #8B0000 red)
- **Visual Effect:** Dialogue box border flashes red briefly (0.3s)
- **No Mechanical Penalty:** Player still receives payment (prototype simplification)

**Fast Priority - Dialogue Flavor Only:**

**In Customer Dialogue:**
- **Initial Greeting:** "I need this urgently!" (Dr. Chen)
- **Success Message:** "Perfect! And so quick, thank you!" (Dr. Chen)
- **No Mechanical Effect:** No timer, no payment change, purely atmospheric

**Visual States:**

- **Payment Display (Cheap):** Strikethrough base payment in red, reduced payment in green
- **Payment Display (No Cheap):** Normal green payment amount (no strikethrough)
- **Dialogue Box (Accurate Failure):** Red border flash, red text warning
- **Dialogue Box (Normal Failure):** Standard dialogue, no special warning

---

### What Player Sees (Detailed Breakdown)

**Payment Calculation Display:**

**In Popup (Before Accept):**
- **Position:** Top-right of popup (same as Feature 3.2)
- **Normal Payment:** $100 (22pt, #2D5016 green, bold) - Dr. Chen, no Cheap priority
- **Cheap Payment:** ~~$50~~ **$25** (Mrs. Kowalski)
  - Strikethrough: 16pt, #8B0000 red, regular weight
  - Reduced payment: 22pt, #2D5016 green, bold
  - Spacing: 10px between strikethrough and reduced amount
  - Subtext: "(Cheap priority: 50% reduction)" below payment (14pt, #666666 gray, italic)

**After Translation (Cash Update):**
- **Cash Counter (Top Bar):** Increments by actual payment amount
- **Animation:** Number scales 1.2× → 1.0× over 0.2s, green flash effect
- **Dialogue Box Confirmation:**
  - Normal: "Dr. Chen pays you $100. 'Excellent work!'"
  - Cheap: "Mrs. Kowalski pays you $25. 'Thank you, dear!'"

**Accurate Priority Failure Message:**

**Trigger:** Player submits incorrect translation for customer with "Accurate" priority

**Dialogue Box Changes:**
- **Border:** Flashes from #3A2518 (dark brown) to #8B0000 (red) and back (0.3s pulse)
- **Text Color:** #8B0000 (red) instead of normal #3A2518 (dark brown)
- **Message Examples:**
  - Mrs. Kowalski: "This doesn't seem right... accuracy was critical to me. I'm disappointed."
  - Dr. Chen: "This translation has errors. I expected perfection. Very disappointing."
  - The Stranger: "*He frowns silently, clearly displeased with the mistakes.*"
- **Icon:** Small warning triangle (⚠) appears to left of text (24×24px, yellow)

**No Mechanical Penalty (Prototype):**
- **Payment Still Received:** Despite failure message, customer still pays full (or reduced if Cheap) amount
- **Rationale:** Prototype tests if dialogue feedback alone creates emotional weight, without complex penalty systems

---

### What Player Does

**Cheap Priority - Player Experience:**

**Scenario: Accept Mrs. Kowalski (Cheap + Accurate)**

**Input:** Click ACCEPT on Mrs. Kowalski popup

**Immediate Response:**
1. **T+0.0s:** Popup closes
2. **T+0.15s:** Translation workspace loads with Text 1
3. **Player completes translation:** "the old way"
4. **Player submits:** Click Submit button
5. **T+0.2s:** Validation success → dialogue box shows payment
6. **T+0.3s:** Cash counter updates: $100 → $125 (+$25, not +$50)
7. **T+0.5s:** Dialogue: "Mrs. Kowalski pays you $25. 'Thank you, dear!'"

**Feedback Loop:**
1. **Player action:** Accepts Mrs. Kowalski (sees ~~$50~~ $25 in popup)
2. **Visual change:** Cash counter increments by $25 after translation
3. **System response:** GameState.cash += calculate_payment(customer) → $25 (base $50 × 0.5 Cheap modifier)
4. **Next player decision:** "Low payment... should I prioritize higher-paying customers next time?"

**Accurate Priority - Player Experience:**

**Scenario: Fail translation for Dr. Chen (Fast + Accurate)**

**Input:** Submit incorrect translation for Dr. Chen's text

**Immediate Response:**
1. **T+0.0s:** Player submits wrong translation: "the new way" (correct: "the old way")
2. **T+0.2s:** Validation fails → red X icon appears
3. **T+0.3s:** Dialogue box border flashes red (0.3s pulse)
4. **T+0.4s:** Warning triangle (⚠) appears in dialogue box
5. **T+0.5s:** Text appears: "Dr. Chen looks disappointed. 'This translation has errors. I expected perfection.'"
6. **T+1.0s:** Despite failure message, cash still increments by $100 (prototype: no penalty)
7. **Player sees:** Red warning, disappointed dialogue, but still got paid

**Feedback Loop:**
1. **Player action:** Submits incorrect translation
2. **Visual change:** Dialogue box flashes red, warning message appears
3. **System response:** Validation.check_accuracy() → false, but GameState.cash still increments
4. **Next player decision:** "Dr. Chen was upset about mistakes... should I be more careful with Accurate customers?"

---

### Acceptance Criteria

**Visual Checks (Cheap Priority):**
- [ ] Customer with Cheap priority shows ~~base_payment~~ **reduced_payment** in popup
- [ ] Strikethrough payment is 16pt red, reduced payment is 22pt green bold
- [ ] Subtext "(Cheap priority: 50% reduction)" appears below payment (14pt gray italic)
- [ ] After translation, cash counter increments by reduced amount (not base amount)
- [ ] Dialogue box shows reduced payment: "Mrs. Kowalski pays you $25"

**Visual Checks (Accurate Priority):**
- [ ] On translation failure, dialogue box border flashes red (0.3s pulse)
- [ ] Warning triangle (⚠) appears to left of dialogue text (24×24px, yellow)
- [ ] Dialogue text color is red (#8B0000) for failure message
- [ ] Failure message includes customer disappointment: "accuracy was critical to me"
- [ ] Despite failure, cash counter still increments (no penalty in prototype)

**Visual Checks (Fast Priority):**
- [ ] Customer with Fast priority shows urgency in dialogue: "I need this urgently!"
- [ ] Success message mentions speed: "And so quick, thank you!"
- [ ] No visual timer or countdown appears (Fast is dialogue flavor only)
- [ ] No payment bonus for fast completion (Fast has no mechanical effect in prototype)

**Interaction Checks:**
- [ ] Accept Cheap customer → payment reduced by 50% after translation
- [ ] Submit incorrect translation for Accurate customer → red warning appears, cash still received
- [ ] Submit correct translation for Accurate customer → normal success message, no warning
- [ ] Accept Fast customer → no difference in gameplay (dialogue only)

**Functional Checks:**
- [ ] Payment calculation: `actual_payment = base_payment × (customer.has_priority("Cheap") ? 0.5 : 1.0)`
- [ ] Mrs. Kowalski (Easy $50, Cheap): actual_payment = $50 × 0.5 = $25
- [ ] Dr. Chen (Medium $100, no Cheap): actual_payment = $100 × 1.0 = $100
- [ ] The Stranger (Hard $200, no Cheap): actual_payment = $200 × 1.0 = $200
- [ ] Accurate priority failure: Display warning message, but GameState.cash += actual_payment (no penalty)
- [ ] Fast priority: No mechanical effects (timer, payment bonus, etc.)
- [ ] Edge case: Customer with both Cheap and Accurate → payment reduced, failure shows warning
- [ ] Edge case: Submit incorrect translation for non-Accurate customer → normal failure message (no red warning)
- [ ] Edge case: Cheap customer with Hard difficulty → $200 × 0.5 = $100 (Cheap applies to all difficulties)
- [ ] Integration: CustomerData.customers[id].priorities checked for "Cheap", "Accurate", "Fast"
- [ ] Integration: TranslationValidation.check() result determines if Accurate warning triggers

**Polish Checks (if time permits):**
- [ ] Payment strikethrough animation (line draws across number)
- [ ] Cash counter increment shows green +$25 floating text briefly
- [ ] Accurate failure warning has subtle shake effect (dialogue box vibrates)
- [ ] Dialogue text for Accurate failure varies per customer (not generic)

---

## Feature 4.5: Multi-Day Progression System

**Priority:** CRITICAL - Core game loop requires advancing through 7 days

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Tension builds across multiple days

**Estimated Time:** 0.75 hours

**Dependencies:** 
- Feature 3.3 (Accept/Refuse Logic) - Knows when 5 customers served
- Feature 3.6 (Daily Queue Generation) - Generates new queue each day
- Feature 1.1 (Game State Manager) - Tracks day number, cash, utilities

---

### Overview

After serving 5 customers (or exhausting the queue), an "End Day" button appears. Clicking it deducts $30 utilities, advances the day counter (Monday → Tuesday), generates a new customer queue, and resets capacity to 0/5. This creates the week-long progression testing economic pressure and relationship management across 7 days.

---

### What Player Sees

**End Day Button:**

**Appearance & Position:**
- **Trigger:** Appears when capacity = 5/5 OR all customers accepted/refused (queue empty)
- **Position:** Bottom-right of screen (1600, 1000) - above dialogue box, visible from any view
- **Size:** 250px width × 60px height
- **Background:** #2D5016 (green)
- **Text:** "END DAY" (24pt, white, bold, center-aligned)
- **Border:** 3px solid #1A3009 (dark green)
- **Corner Radius:** 6px
- **Icon:** Small moon icon (30×30px) to left of text (indicates end of day)

**Visual States:**
- **Enabled:** Green background, white text, moon icon visible
- **Hover:** Background brightens to #3FB023, border glows gold (#FFD700, 4px)
- **Disabled (Before 5/5):** Grayed out (#888888), text 50% opacity, tooltip: "Serve 5 customers to end the day"
- **Pressed:** Button depresses (2px offset), background darkens to #1A3009

**Day Transition Screen:**

**Visual Sequence (0.8s total):**

1. **Fade Out Current View (0.2s):**
   - Entire screen fades to black (#000000)
   - All UI elements fade out simultaneously

2. **Day Title Card (0.4s):**
   - **Background:** Black (#000000)
   - **Title Text:** "Day 2 - Tuesday" (48pt, #F4E8D8 cream, bold, centered)
   - **Position:** Center of screen (960, 540)
   - **Subtitle:** "Utilities: -$30" (24pt, #8B0000 red, centered, below title)
   - **Cash Remaining:** "Cash: $120" (24pt, #2D5016 green, centered, below subtitle)
   - **Fade In:** Title card fades in (0.2s), holds (0.2s)

3. **Fade In New Day (0.2s):**
   - Title card fades out
   - New day UI fades in (customer queue refreshed, capacity reset)

**Top Bar Updates:**

**Day Counter:**
- **Before:** "Day 1 - Monday" (27pt, white)
- **After:** "Day 2 - Tuesday" (27pt, white)
- **Days:** Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday

**Capacity Counter:**
- **Before:** "5/5 Customers Served" (green)
- **After:** "0/5 Customers Served" (gray)

**Cash Counter:**
- **Before:** "$130" (green)
- **After:** "$100" (-$30 utilities deducted, red flash effect on decrement)

**Customer Queue (Left Panel):**
- **Before:** 5 accepted customers (green checkmarks), 2-5 refused (grayed out)
- **After:** Fresh queue of 7-10 new customers (based on day number + relationships)

---

### What Player Does

**Input Methods:**

- **Mouse:** Click "END DAY" button after serving 5 customers
- **Keyboard:** Press E key to end day (shortcut)

**Immediate Response:**

- **Click END DAY button:**
  - T+0.0s: Button flashes white, depresses (2px)
  - T+0.1s: Screen begins fading to black
  - T+0.3s: Black screen fully visible
  - T+0.5s: Day title card fades in ("Day 2 - Tuesday, Utilities: -$30, Cash: $100")
  - T+0.7s: Title card holds (player reads info)
  - T+0.9s: Title card fades out
  - T+1.1s: New day UI fades in (queue refreshed, capacity reset)
  - T+1.3s: Player can click customer cards to begin Day 2

**Feedback Loop:**

1. **Player action:** Clicks "END DAY" button after serving 5 customers
2. **Visual change:** Screen fades to black, day title card appears, utilities deducted from cash
3. **System response:** 
   - GameState.current_day += 1
   - GameState.cash -= 30 (utilities)
   - GameState.capacity_used = 0
   - CustomerData.generate_daily_queue(day) → new 7-10 customers
4. **Next player decision:** Examine new queue, choose which 5 customers to serve on Day 2

**Example Interaction Flow:**
```
Day 1 complete: Player has served 5 customers, cash = $130
→ "END DAY" button appears bottom-right (green, glowing)
→ Player clicks "END DAY"
→ Button flashes white, screen fades to black (0.2s)
→ Title card appears: "Day 2 - Tuesday"
→ Subtitle: "Utilities: -$30"
→ Cash update: "Cash: $100" (was $130, now $100)
→ Player reads: "I lost $30 to utilities, have $100 left"
→ Title card fades out (0.2s)
→ Day 2 UI fades in (0.2s)
→ Left panel shows new queue: Mrs. Kowalski (if not refused 2×), Dr. Chen, + 5-8 random customers
→ Capacity counter: "0/5 Customers Served" (gray)
→ Player begins Day 2: clicks customer cards, makes new accept/refuse choices
```

---

### Acceptance Criteria

**Visual Checks (End Day Button):**
- [ ] "END DAY" button appears at (1600, 1000) when capacity = 5/5
- [ ] Button is 250×60px with green background (#2D5016), white text, moon icon
- [ ] Button is disabled (grayed out) before 5/5 capacity reached
- [ ] Hover enabled button → background brightens, border glows gold
- [ ] Button shows tooltip "Serve 5 customers to end the day" when disabled

**Visual Checks (Day Transition Screen):**
- [ ] Screen fades to black over 0.2s
- [ ] Day title card appears centered (960, 540) with black background
- [ ] Title shows: "Day [N] - [Weekday]" (48pt cream, bold)
- [ ] Subtitle shows: "Utilities: -$30" (24pt red, centered)
- [ ] Cash remaining shows: "Cash: $[amount]" (24pt green, centered)
- [ ] Title card holds for 0.2s (readable duration)
- [ ] Title card fades out, new day UI fades in over 0.2s

**Visual Checks (Day Counter Updates):**
- [ ] Day 1 → Day 2: "Monday" → "Tuesday"
- [ ] Day 2 → Day 3: "Tuesday" → "Wednesday"
- [ ] Day 3 → Day 4: "Wednesday" → "Thursday"
- [ ] Day 4 → Day 5: "Thursday" → "Friday"
- [ ] Day 5 → Day 6: "Friday" → "Saturday"
- [ ] Day 6 → Day 7: "Saturday" → "Sunday"

**Visual Checks (UI Resets):**
- [ ] Capacity counter resets to "0/5 Customers Served" (gray)
- [ ] Customer queue refreshes with 7-10 new customers
- [ ] Previous day's accepted/refused customers cleared (not visible in new queue unless recurring)
- [ ] Cash counter shows updated amount after -$30 deduction (red flash on decrement)

**Interaction Checks:**
- [ ] Click "END DAY" at 5/5 capacity → day transition triggers within 0.1s
- [ ] Press E key → same result as clicking button
- [ ] Click "END DAY" before 5/5 capacity → nothing happens (button disabled)
- [ ] Day transition sequence completes in 1.3s total (black → title → new day)
- [ ] Cannot click customer cards during transition (UI locked until fade-in completes)
- [ ] After transition, player can immediately interact with new queue

**Functional Checks:**
- [ ] GameState.current_day increments: 1 → 2 → 3 → 4 → 5 → 6 → 7
- [ ] GameState.cash decrements by $30: If day starts with $130, next day starts with $100
- [ ] GameState.capacity_used resets to 0 at start of each day
- [ ] GameState.accepted_customers array cleared at day end
- [ ] GameState.refused_customers persists across days (relationship tracking)
- [ ] CustomerData.generate_daily_queue(day) called, returns 7-10 customers based on day + relationships
- [ ] Edge case: Day 1 ends with $20 cash → Day 2 starts with -$10 cash (negative allowed, triggers Game Over at rent deadline)
- [ ] Edge case: Serve 5 customers in first 3 queue slots → remaining 4-7 customers auto-refused, "END DAY" button enabled immediately
- [ ] Edge case: Refuse all 7-10 customers (0/5 capacity) → "END DAY" button enabled (queue exhausted, even if <5 served)
- [ ] Integration: Feature 3.6 (Daily Queue Generation) called to populate new queue
- [ ] Integration: Feature 4.6 (Rent Deadline) checks if current_day == 5 (Friday) before day transition

**Polish Checks (if time permits):**
- [ ] Day transition has smooth fade curves (ease-in-out, not linear)
- [ ] Cash decrement shows floating "-$30" red text briefly
- [ ] Title card has subtle shadow/glow effect (professional presentation)
- [ ] Weekday names are full words (Monday, not Mon)

---

## Feature 4.6: Rent Deadline & Game Over

**Priority:** CRITICAL - Win/lose condition creates economic pressure across week

**Tests Critical Question:** Q2 (Limited capacity creates strategic tension) - Rent deadline tests if economic pressure works

**Estimated Time:** 0.5 hours

**Dependencies:** 
- Feature 4.5 (Multi-Day Progression) - Day advancement to reach Friday (Day 5)
- Feature 1.1 (Game State Manager) - Checks cash balance on Friday

---

### Overview

On Friday evening (end of Day 5), the game checks if player has $200 for rent. If cash < $200, Game Over screen appears with restart button. If cash ≥ $200, rent is deducted, a success message appears, and the game continues to Saturday. This tests whether the economic pressure loop (earn money, pay utilities, save for rent) creates satisfying strategic tension.

---

### What Player Sees

**Rent Check (Friday End of Day):**

**Trigger:** Player clicks "END DAY" button on Day 5 (Friday)

**Scenario A: Cash < $200 (Game Over)**

**Game Over Screen:**

- **Background:** Semi-transparent black overlay (#000000 at 80% opacity) over game UI
- **Panel Position:** Centered (710, 340)
- **Panel Size:** 500px width × 400px height
- **Panel Background:** #3A2518 (dark brown)
- **Panel Border:** 4px solid #8B0000 (red)
- **Corner Radius:** 8px

**Panel Content:**
```
┌─────────────────────────────────────┐
│                                      │
│         ⚠ GAME OVER ⚠               │ ← Title (36pt, red, bold)
│                                      │
│  Rent is due: $200                  │ ← Rent amount (24pt, white)
│  Your cash: $150                    │ ← Player's cash (24pt, red)
│  Short by: $50                      │ ← Deficit (24pt, red, bold)
│                                      │
│  You cannot afford rent.            │ ← Message (20pt, white)
│  Your shop closes.                  │
│                                      │
│  Days survived: 5/7                 │ ← Progress (20pt, gray)
│                                      │
│  [     RESTART GAME     ]           │ ← Button (200×50px, green)
│                                      │
└─────────────────────────────────────┘
```

**Button Details:**
- **Restart Button:**
  - Position: Centered in panel (650, 620)
  - Size: 200px × 50px
  - Background: #2D5016 (green)
  - Text: "RESTART GAME" (18pt, white, bold)
  - Border: 2px solid #1A3009 (dark green)
  - Hover: Background brightens to #3FB023

**Scenario B: Cash ≥ $200 (Rent Paid Successfully)**

**Rent Payment Screen:**

- **Background:** Semi-transparent black overlay (#000000 at 60% opacity)
- **Panel Position:** Centered (710, 390)
- **Panel Size:** 500px width × 300px height
- **Panel Background:** #F4E8D8 (cream parchment)
- **Panel Border:** 4px solid #2D5016 (green)
- **Corner Radius:** 8px

**Panel Content:**
```
┌─────────────────────────────────────┐
│                                      │
│       ✓ RENT PAID ✓                 │ ← Title (36pt, green, bold)
│                                      │
│  Rent deducted: -$200               │ ← Deduction (24pt, red)
│  Remaining cash: $50                │ ← New balance (24pt, green)
│                                      │
│  Your shop survives another week!   │ ← Message (20pt, dark brown)
│                                      │
│  [     CONTINUE TO SATURDAY     ]   │ ← Button (250×50px, green)
│                                      │
└─────────────────────────────────────┘
```

**Button Details:**
- **Continue Button:**
  - Position: Centered in panel (625, 600)
  - Size: 250px × 50px
  - Background: #2D5016 (green)
  - Text: "CONTINUE TO SATURDAY" (18pt, white, bold)
  - Border: 2px solid #1A3009 (dark green)
  - Hover: Background brightens to #3FB023

**Auto-Dismiss (if time permits):**
- Rent paid message auto-dismisses after 3 seconds if player doesn't click
- Countdown indicator: "(Continuing in 3...)" below button (16pt, gray)

---

### What Player Does

**Scenario A: Game Over (Cash < $200)**

**Input:** Click "END DAY" on Friday with $150 cash

**Immediate Response:**
1. **T+0.0s:** "END DAY" button clicked
2. **T+0.2s:** Screen fades to black (normal day transition start)
3. **T+0.3s:** Rent check runs: GameState.cash ($150) < $200 → fail
4. **T+0.4s:** Instead of day title card, Game Over panel fades in (0.3s)
5. **T+0.7s:** Game Over panel fully visible
6. **Panel shows:**
   - "GAME OVER" (red title)
   - "Rent is due: $200"
   - "Your cash: $150"
   - "Short by: $50"
   - "You cannot afford rent. Your shop closes."
   - "Days survived: 5/7"
   - "RESTART GAME" button
7. **Player clicks RESTART:**
   - T+0.0s: Button flashes white
   - T+0.1s: Game Over panel fades out
   - T+0.3s: Game resets to Day 1 (fresh start)
   - T+0.5s: Day 1 UI loads (cash = $100, capacity = 0/5, new queue)

**Feedback Loop (Game Over):**
1. **Player action:** Clicks "END DAY" on Friday with insufficient cash
2. **Visual change:** Game Over panel appears, shows deficit calculation
3. **System response:** GameState.game_over = true, UI locks except Restart button
4. **Next player decision:** Click Restart to try again, or quit application

**Scenario B: Rent Paid Successfully (Cash ≥ $200)**

**Input:** Click "END DAY" on Friday with $250 cash

**Immediate Response:**
1. **T+0.0s:** "END DAY" button clicked
2. **T+0.2s:** Screen fades to black (normal day transition start)
3. **T+0.3s:** Rent check runs: GameState.cash ($250) ≥ $200 → pass
4. **T+0.4s:** Rent payment panel fades in (0.3s)
5. **T+0.7s:** Rent payment panel fully visible
6. **Panel shows:**
   - "RENT PAID ✓" (green title)
   - "Rent deducted: -$200"
   - "Remaining cash: $50" (was $250, now $50)
   - "Your shop survives another week!"
   - "CONTINUE TO SATURDAY" button
7. **Player clicks CONTINUE (or waits 3s):**
   - T+0.0s: Button flashes white (or auto-dismiss triggers)
   - T+0.1s: Rent panel fades out
   - T+0.3s: Day 6 title card appears ("Day 6 - Saturday")
   - T+0.5s: Title card fades out, Saturday UI loads
   - T+0.7s: Player begins Day 6 with $50 cash, new queue

**Feedback Loop (Rent Paid):**
1. **Player action:** Clicks "END DAY" on Friday with sufficient cash
2. **Visual change:** Rent paid panel appears, shows $200 deduction
3. **System response:** GameState.cash -= 200, GameState.current_day = 6
4. **Next player decision:** Continue to Saturday, manage remaining $50 carefully

---

### Acceptance Criteria

**Visual Checks (Game Over - Cash < $200):**
- [ ] Game Over panel appears centered (710, 340) with 500×400px dimensions
- [ ] Panel has dark brown background (#3A2518) with red border (#8B0000, 4px)
- [ ] Title shows "⚠ GAME OVER ⚠" (36pt, red, bold)
- [ ] Rent amount: "Rent is due: $200" (24pt, white)
- [ ] Player cash: "Your cash: $[amount]" (24pt, red)
- [ ] Deficit: "Short by: $[deficit]" (24pt, red, bold) - e.g., $200 - $150 = $50
- [ ] Message: "You cannot afford rent. Your shop closes." (20pt, white)
- [ ] Progress: "Days survived: 5/7" (20pt, gray)
- [ ] Restart button: "RESTART GAME" (200×50px, green, centered)

**Visual Checks (Rent Paid - Cash ≥ $200):**
- [ ] Rent paid panel appears centered (710, 390) with 500×300px dimensions
- [ ] Panel has cream background (#F4E8D8) with green border (#2D5016, 4px)
- [ ] Title shows "✓ RENT PAID ✓" (36pt, green, bold)
- [ ] Deduction: "Rent deducted: -$200" (24pt, red)
- [ ] Remaining cash: "Remaining cash: $[amount]" (24pt, green) - e.g., $250 - $200 = $50
- [ ] Message: "Your shop survives another week!" (20pt, dark brown)
- [ ] Continue button: "CONTINUE TO SATURDAY" (250×50px, green, centered)

**Interaction Checks (Game Over):**
- [ ] End Day 5 with $150 cash → Game Over panel appears within 0.4s
- [ ] Deficit calculation correct: $200 - $150 = $50 shown as "Short by: $50"
- [ ] Click "RESTART GAME" → panel fades out, game resets to Day 1
- [ ] After restart: Cash = $100, Day = 1 (Monday), Capacity = 0/5, fresh queue appears
- [ ] Game Over UI locks all other interactions (cannot click customer cards, cannot continue)

**Interaction Checks (Rent Paid):**
- [ ] End Day 5 with $250 cash → Rent paid panel appears within 0.4s
- [ ] Cash deduction correct: $250 - $200 = $50 shown as "Remaining cash: $50"
- [ ] Click "CONTINUE TO SATURDAY" → panel fades out, Day 6 begins
- [ ] After continue: Cash = $50 (was $250), Day = 6 (Saturday), Capacity = 0/5, new queue appears
- [ ] Auto-dismiss (if implemented): After 3s without click, panel auto-closes and continues to Day 6

**Functional Checks:**
- [ ] Rent check triggers at end of Day 5 (Friday) only (not other days)
- [ ] Game Over condition: `if GameState.current_day == 5 && GameState.cash < 200 → game_over()`
- [ ] Rent paid condition: `if GameState.current_day == 5 && GameState.cash >= 200 → pay_rent()`
- [ ] Rent payment: `GameState.cash -= 200` after successful check
- [ ] Restart resets: GameState.current_day = 1, GameState.cash = 100, GameState.capacity_used = 0, relationships cleared
- [ ] Edge case: Exactly $200 cash on Friday → rent paid successfully (≥ check, not >)
- [ ] Edge case: $199 cash on Friday → Game Over (fails < 200 check)
- [ ] Edge case: Negative cash on Friday (e.g., -$50 from excessive utilities) → Game Over (< 200)
- [ ] Edge case: $500 cash on Friday → rent paid, remaining cash = $300 (continues to Day 6)
- [ ] Integration: Feature 4.5 (Multi-Day Progression) calls rent check before day transition on Friday
- [ ] Integration: Restart calls GameState.reset() to clear all state and reload Day 1

**Polish Checks (if time permits):**
- [ ] Game Over panel has subtle red glow/pulsing effect (emphasizes failure)
- [ ] Rent paid panel has green checkmark animation (bounces in)
- [ ] Deficit calculation shows color-coded amount (red for negative balance)
- [ ] Restart button has confirmation dialog: "Are you sure? Progress will be lost."

---

## INTEGRATION CHECKLIST

These features work together as a system. Verify integration:

- [ ] **4.1 → 4.2:** UV Light button appears in examination toolbar if upgrade purchased
- [ ] **4.1 → 2.3:** Skip button in examination proceeds to translation workspace with customer's text
- [ ] **4.3 → 4.4:** Negotiation priorities displayed in popup affect payment calculation after translation
- [ ] **4.4 → 1.1:** Payment calculation (Cheap modifier) updates GameState.cash correctly
- [ ] **4.5 → 3.6:** Day transition triggers daily queue generation for next day
- [ ] **4.5 → 4.6:** End Day 5 (Friday) triggers rent check before advancing to Day 6
- [ ] **4.6 → 4.5:** Rent paid successfully proceeds to Day 6 via multi-day progression system
- [ ] **4.6 → 1.1:** Game Over restart resets GameState to initial values (Day 1, $100 cash)

---

## TESTING PROTOCOL

**Book Examination Test (10 minutes):**

1. Accept customer → examination screen appears
2. Move mouse over book → zoom inset follows cursor, shows 2× magnification
3. Move mouse to top-left corner → zoom shows top-left at 2×
4. Click "SKIP EXAMINATION" → examination closes, translation workspace loads
5. If UV Light purchased: Click "UV LIGHT" → purple tint appears, hidden text reveals

**Negotiation Effects Test (10 minutes):**

1. View Mrs. Kowalski popup → see ~~$50~~ **$25** payment, "Cheap + Accurate" priorities
2. Accept Mrs. K → complete translation correctly → verify cash += $25 (not $50)
3. View Dr. Chen popup → see $100 payment, "Fast + Accurate" priorities
4. Accept Dr. Chen → submit incorrect translation → verify red warning, but still get $100

**Multi-Day Progression Test (15 minutes):**

1. Complete Day 1 (serve 5 customers, cash = $130)
2. Click "END DAY" → screen fades, title card "Day 2 - Tuesday, Utilities: -$30, Cash: $100"
3. Day 2 loads → verify capacity reset to 0/5, new queue appears, cash = $100
4. Repeat for Days 2-4 → verify utilities deduct $30 each day
5. Reach Day 5 (Friday) with $250 cash

**Rent Deadline Test (10 minutes):**

**Scenario A: Fail rent check**
1. Reach Friday with $150 cash
2. Click "END DAY" → Game Over panel appears
3. Verify: "Rent is due: $200, Your cash: $150, Short by: $50"
4. Click "RESTART GAME" → Day 1 loads, cash = $100

**Scenario B: Pass rent check**
1. Reach Friday with $250 cash
2. Click "END DAY" → Rent paid panel appears
3. Verify: "Rent deducted: -$200, Remaining cash: $50"
4. Click "CONTINUE TO SATURDAY" → Day 6 loads, cash = $50

---

## VISUAL REFERENCE - COLOR CODES

Copy-paste these hex codes for implementation:

**Existing colors:**
- **Cream parchment:** `#F4E8D8`
- **Dark brown:** `#3A2518`
- **Green (success, buttons):** `#2D5016`
- **Red (failure, warnings):** `#8B0000`
- **Gold (highlights):** `#FFD700`
- **Gray (disabled):** `#888888`

**New colors (Phase 4):**
- **Purple (UV Light):** `#4B0082` (button), `#8A2BE2` (tint overlay)
- **Cyan (hidden text):** `#00FFFF`
- **Yellow (warnings):** `#FFFF00`
- **Saddle brown (book border):** `#8B4513`
- **Light green (negotiation section):** `#E8F5E0`

---

## TIME ESTIMATES SUMMARY

| Feature | Estimated Time | Critical Path |
|---------|----------------|---------------|
| 4.1 Book Examination Phase | 1.0 hours | No (can simplify/cut) |
| 4.2 UV Light Tool | 0.5 hours | No (optional upgrade) |
| 4.3 Customer Negotiation Display | 0.25 hours | No (enhances Phase 3) |
| 4.4 Negotiation Constraint Effects | 0.5 hours | Yes (mechanical variety) |
| 4.5 Multi-Day Progression System | 0.75 hours | Yes (core loop) |
| 4.6 Rent Deadline & Game Over | 0.5 hours | Yes (win/lose condition) |
| **TOTAL** | **3.5 hours** | |

**Buffer:** +0.5 hours for integration, testing, polish = **4 hours total** (fits within 9-12 hour window)

**Simplification if over time:**
- **Cut Feature 4.1 + 4.2** (Book Examination + UV Light) → Jump straight to translation after accept (saves 1.5 hours)
- **Simplify Feature 4.3** → Remove detailed negotiation display, keep only payment calculation (saves 0.25 hours)
- **Minimum viable:** Features 4.4, 4.5, 4.6 only → Tests economic pressure without examination layer (2 hours)

---

## NEXT PHASE

After Phase 4 complete, proceed to **Phase 5: Polish & Integration** (Hours 12-16):
- Feature 5.1: Upgrade Shop (UV Light, Coffee Machine, Better Lamp)
- Feature 5.2: Story Integration (lore snippets in translations)
- Feature 5.3: Win Condition (Day 7 cliffhanger)
- Feature 5.4: Balance Tweaks
- Feature 5.5: Full Playthrough Test

Phase 4 establishes multi-day progression and economic pressure. Phase 5 polishes the experience and completes the 7-day prototype.
