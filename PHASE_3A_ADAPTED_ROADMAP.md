# PHASE 3A: DIEGETIC SHOP UI SYSTEM - Adapted Roadmap

---

## THE BIG PICTURE

**What It Is:** Transform the shop scene from a navigation hub into an immersive desk workspace where screens slide in as physical panels when you interact with desk objects, stack like real documents, and slide out when closed.

**Why It Matters:** Tests whether keeping the shop scene as the central hub (with screens appearing dieget

ically) enhances immersion vs. the current "click object → navigate away" system. Maintains the scholar fantasy while keeping spatial continuity.

**Time Investment:** 10 hours (Adapted for shop scene integration)

**Tests Critical Question:** Q3 (Engaging texture) - Does interacting with physical desk objects that reveal information panels feel more immersive than screen navigation?

---

## THE CORE CONCEPT

### Before (Current System):
```
Player in shop → Clicks Diary object → SceneManager navigates to Queue screen → Player leaves shop context
```
**Problem:** Context loss. Shop disappears completely. Feels like menu navigation.

### After (Phase 3A - Diegetic Shop):
```
Player in shop → Clicks Diary on desk → Customer queue panel slides in from right → Reads queue while still seeing shop → Clicks close, panel slides out → Still in shop
```
**Solution:** Spatial continuity. Shop remains visible. Screens are temporary overlays. Feels like pulling documents from desk.

---

## THE ADAPTED DESK LAYOUT

### **The Shop Desk (Integrated Zones):**
```
┌──────────────────────────────────────────────────────────┐
│ 🏠 SHOP SCENE - Scholar's Study                         │
│ [Bookshelves] [Doorway] [Lamp]                          │
├─────────────────────┬────────────────────────────────────┤
│                     │                                    │
│  DESK AREA          │   SLIDING PANEL AREA               │
│  (Always Visible)   │   (Appears on demand)              │
│                     │                                    │
│  • Diary 📔        │   • Customer Queue (from Diary)    │
│  • Papers 📄        │   • Translation Work (from Papers) │
│  • Dictionary 📖    │   • Symbol Dictionary (from Dict)  │
│  • Magnifier 🔍    │   • Examination (from Magnifier)   │
│  • Bell 🔔         │   • Current Work (from Bell)       │
│                     │                                    │
│  [Interactive       │   [Max 3 panels stacked]           │
│   Objects]          │   [Tabs when multiple open]        │
│                     │                                    │
└─────────────────────┴────────────────────────────────────┘
```

### **Key Spatial Rules:**
- **Desk Area (left):** 5 interactive objects (diary, papers, dictionary, magnifier, bell) - always visible
- **Sliding Panel Area (right):** Panels slide in from right edge, stack max 3
- **Shop Background:** Bookshelves, doorway, lamp remain visible (dimmed when panels open)
- **No full navigation:** Never leave shop scene - panels overlay instead

---

## THE 9 ADAPTED FEATURES (In Order)

| # | Feature | Time | Why Critical |
|---|---------|------|--------------|
| **3A.1** | **Interactive Desk Objects** | 90m | Foundation - existing objects trigger panel slides |
| **3A.2** | **Shop Workspace Zones** | 45m | Defines spatial layout (desk vs. panel area) |
| **3A.3** | **Screen Panel Sliding** | 120m | Core magic - screens physically slide in from right |
| **3A.4** | **Diegetic Screen Manager** | 90m | Orchestrator - handles max 3 panels, stacking |
| **3A.5** | **Persistent Desk Area** | 60m | Left side - shop desk always visible |
| **3A.6** | **Dictionary Quick-Panel** | 45m | Dictionary object → mini always-accessible panel |
| **3A.7** | **Customer Queue Card** | 45m | Diary object → sliding customer queue |
| **3A.8** | **Tab Stacking System** | 75m | Browser-style tabs for multiple open panels |
| **3A.9** | **Hover & Polish** | 60m | Final pass - object highlights, shadows, feedback |

---

## HOW IT WORKS (Player Flow)

### **Example: Checking customer queue, then examining a book**

1. **Player in shop:**
   - Sees desk with 5 objects (diary, papers, dictionary, magnifier, bell)
   - Shop environment visible (bookshelves, doorway, lamp)

2. **Player clicks Diary (📔):**
   - Diary object glows/highlights
   - Customer queue panel slides in from right edge (0.4s animation)
   - Panel shows customer cards with difficulty pins
   - Shop desk still visible on left

3. **Player wants to examine book:**
   - Clicks Magnifying Glass (🔍) on desk
   - Examination panel slides in BEHIND queue panel
   - Tabs appear: [QUEUE] [EXAMINATION]
   - Queue panel fades to 70% opacity (indicates background)

4. **Player switches between panels:**
   - Clicks [QUEUE] tab → Queue comes to front (100% opacity)
   - Clicks [EXAMINATION] tab → Examination comes to front
   - Or clicks desk object directly

5. **Player closes queue:**
   - Clicks ✕ on queue panel
   - Panel slides out to right edge (0.4s)
   - Examination panel comes forward
   - Shop desk still visible

**Key Advantage:** Never leave shop. All screens are temporary panels. Spatial continuity maintained.

---

## OBJECT-TO-PANEL MAPPING

### **5 Desk Objects → 5 Screen Panels:**

| Desk Object | Panel Type | Content |
|-------------|-----------|---------|
| **📔 Diary** | Customer Queue | Today's customers with difficulty markers |
| **📄 Papers** | Translation Workspace | Symbol text + input field + submit |
| **📖 Dictionary** | Glyph Dictionary | Learned symbols reference (always mini-panel) |
| **🔍 Magnifier** | Examination Screen | Book zoom + UV light tools |
| **🔔 Bell** | Work Screen | Current active translation task |

### **Visual States:**

**Desk Object States:**
- **Default:** Visible on desk, subtle shadow
- **Hover:** Brightens 15%, cursor becomes pointer, tooltip appears
- **Active (panel open):** Glows with colored outline matching panel
- **Inactive (panel closed):** Returns to default

**Panel States:**
- **Sliding In:** Scales from 80% → 100%, fades from 0 → 100% opacity (0.4s)
- **Active (front):** 100% opacity, full color, shadow prominent
- **Background:** 55-70% opacity, slightly desaturated, shadow reduced
- **Sliding Out:** Reverse of slide in (0.4s)

---

## VISUAL HIERARCHY & COLOR CODING

### **Brightness = Importance:**
- **Brightest:** Active panel (what you're reading) → Primary focus
- **Medium:** Desk objects (always accessible) → Available actions
- **Dimmer:** Background panels (visible but not focal) → Context
- **Dimmest:** Shop environment (bookshelves, doorway) → Ambient atmosphere

### **Color Coding (Panels match desk objects):**
```
Queue Panel:        🟤 Brown    (#A0826D) - From Diary
Translation Panel:  📄 Cream    (#F4E8D8) - From Papers
Dictionary Panel:   🟢 Green    (#2D5016) - From Dictionary book
Examination Panel:  🔵 Blue     (#3498DB) - From Magnifier glass
Work Panel:         🟡 Gold     (#FFD700) - From Bell
```

---

## KEY DESIGN CONSTRAINTS

### **Max 3 Panels Open:**
- Prevents screen clutter
- Forces prioritization
- Opening 4th auto-closes oldest (leftmost)

### **Desk Area Always Visible:**
- Desk Area (left 40%) = sacred space, never obscured
- Panel Area (right 60%) = sliding panels
- Clear spatial separation = clear mental model

### **Panels Slide, Never Pop:**
- Slide in from right: 0.4s (smooth curve)
- Tab switch: 0.3s (responsive fade)
- Hover: 0.15s (instant feedback)
- **Never wait > 0.6s for anything**

### **Shop Background Stays Present:**
- When panels open, shop background dims to 70% opacity
- Bookshelves, doorway, lamp still visible (maintains immersion)
- Closing all panels returns shop to 100% brightness

---

## TECHNICAL HIGHLIGHTS

### **GDScript Architecture (Adapted):**
```gdscript
DiegeticScreenManager (Node in ShopScene)
├── Listens to: Desk object signals (diary_clicked, papers_clicked, etc.)
├── Creates: ScreenPanel instances
├── Manages: Stack order, z-index, fading
├── Enforces: Max 3 panels rule
└── Coordinates: All slide animations

DeskObject (Button - existing DiaryButton, etc.)
├── Emits: object_clicked(screen_type) signal
├── Visual states: default, hover, active
└── Highlights when corresponding panel open

ScreenPanel (Panel)
├── Slides from right edge → desk area
├── Has close button + tab
├── Returns off-screen when closed
└── Contains screen content (queue, translation, etc.)
```

### **Key Functions:**
```gdscript
DiegeticScreenManager:
├── open_screen(screen_type)      # Slide panel in from right
├── close_screen(screen_type)     # Slide panel out
├── bring_to_front(screen_type)   # Click tab
└── update_panel_positions()      # Restack when panel closes

ScreenPanel:
├── slide_in()                    # From right edge to position
├── slide_out()                   # Back to right edge
└── set_opacity(alpha)            # Fade to background
```

---

## WHAT YOU'LL SEE

### **Opening Queue Panel (First Time):**
```
[Click 📔 Diary on desk]
  ↓
[Diary object glows brown outline]
  ↓
[Customer queue panel appears at right edge, small + transparent]
  ↓
[Panel slides left to position (600, 130) over 0.4s]
  ↓
[Panel settles with slight bounce, 100% opacity]
  ↓
[Customer cards visible, diary still glowing on left]
```

### **Opening 3 Panels (Max Stack):**
```
Queue open       → Position (600, 130), z=10, alpha 0.55, tab visible
Translation open → Position (650, 130), z=11, alpha 0.70, tab visible
Examination open → Position (700, 130), z=12, alpha 1.00 ← On top

Tabs visible:    [📔 QUEUE] [📄 TRANSLATION] [🔍 EXAM]

Desk objects still visible on left (diary, papers, magnifier glowing)
```

### **Closing Middle Panel (Translation):**
```
[Click ✕ on Translation panel]
  ↓
[Translation panel slides right off-screen (0.4s)]
  ↓
[Papers object stops glowing on desk]
  ↓
[Remaining panels restack: Queue + Examination]
  ↓
[Tabs update: [📔 QUEUE] [🔍 EXAM]]
  ↓
[Shop background brightens slightly (fewer panels = less dimming)]
```

---

## SUCCESS METRICS

### **Feature Passes If:**
✅ Player can open/close all 5 panels smoothly from desk objects
✅ Max 3 panels enforced (4th auto-closes oldest)
✅ Stacking is visually clear (tabs, z-index, fading)
✅ Desk area (left) with objects never obscured
✅ All animations < 0.6s (feel instant)
✅ Shop environment remains visible (maintains immersion)
✅ System feels more immersive than full-screen navigation

### **Red Flags (Indicates Failure):**
❌ Player says "I lost the shop scene, where am I?"
❌ Panels overlap desk objects
❌ Animations feel sluggish (>1s)
❌ Opening 3 panels feels cluttered/overwhelming
❌ Player prefers old navigation system (SceneManager.goto_X)

---

## IMPLEMENTATION ORDER

### **Day 1 (4 hours):**
1. **3A.1: Interactive Desk Objects** (90m)
   - Modify existing desk objects (DiaryButton, etc.) to emit signals instead of navigating
   - Add glow/highlight states
   - Connect to DiegeticScreenManager

2. **3A.2: Shop Workspace Zones** (45m)
   - Define desk area (left 40%: 0-770px)
   - Define panel area (right 60%: 770-1920px)
   - Add background dimming overlay

3. **3A.3: Screen Panel Sliding** (120m)
   - Create ScreenPanel scene template
   - Implement slide in/out animations
   - Bezier curve from right edge → position

   **Milestone:** Click diary, queue panel slides in

### **Day 2 (3.5 hours):**
4. **3A.4: Diegetic Screen Manager** (90m)
   - Create DiegeticScreenManager node in ShopScene
   - Max 3 panel enforcement
   - Stack management (z-index, positions)

5. **3A.5: Persistent Desk Area** (60m)
   - Ensure desk objects remain clickable
   - Handle desk object glow states
   - Coordinate with panel visibility

6. **3A.6: Dictionary Quick-Panel** (45m)
   - Dictionary object → mini always-visible panel
   - Bottom-left corner, 300×200px
   - Shows last 5 learned symbols

   **Milestone:** Full workspace with 3 panels, desk still accessible

### **Day 3 (2.5 hours):**
7. **3A.7: Customer Queue Card** (45m)
   - Diary object → customer queue panel
   - Cork board aesthetic from Main.tscn Queue tab
   - Difficulty pins, customer cards

8. **3A.8: Tab Stacking System** (75m)
   - Browser-style tabs at top of panel area
   - Click tab → bring panel to front
   - Tab shows object icon + name

9. **3A.9: Hover & Polish** (60m)
   - Desk object tooltips
   - Panel shadows and depth
   - Smooth transitions
   - Sound effects (paper slide, object click)

   **Milestone:** Complete diegetic shop system, polished

---

## INTEGRATION WITH EXISTING SYSTEMS

### **Replace SceneManager Navigation:**

**Before (ShopScene.gd):**
```gdscript
diary_button.pressed.connect(SceneManager.goto_queue_screen)
papers_button.pressed.connect(SceneManager.goto_translation_screen)
# etc.
```

**After (ShopScene.gd):**
```gdscript
# Add DiegeticScreenManager node
@onready var screen_manager = $DiegeticScreenManager

# Connect desk objects to screen manager
diary_button.pressed.connect(screen_manager.toggle_screen.bind("queue"))
papers_button.pressed.connect(screen_manager.toggle_screen.bind("translation"))
dictionary_button.pressed.connect(screen_manager.toggle_screen.bind("dictionary"))
magnifying_glass_button.pressed.connect(screen_manager.toggle_screen.bind("examination"))
bell_button.pressed.connect(screen_manager.toggle_screen.bind("work"))
```

### **Screen Content Migration:**

**Queue Panel** ← Content from `Main.tscn → LeftPanel` (Queue tab)
**Translation Panel** ← Content from `Main.tscn → Workspace → TranslationDisplay`
**Dictionary Panel** ← Content from `Main.tscn → RightPanel` (Dictionary tab)
**Examination Panel** ← Content from `Main.tscn → Workspace → ExaminationScreen`
**Work Panel** ← Content from `Main.tscn` (Work tab layout)

---

## WHAT'S DIFFERENT FROM ORIGINAL PHASE 3A

| Aspect | Original 3A (Translation Focus) | Adapted 3A (Shop Hub) |
|--------|--------------------------------|----------------------|
| **Context** | Translation workspace with reference books | Shop scene with information panels |
| **Triggers** | Click book spines on shelf | Click desk objects (diary, papers, etc.) |
| **Content** | Grimoire, translations, context, notes | Queue, translation, dictionary, examination, work |
| **Layout** | Work area (left) + Reference area (right) | Desk area (left) + Panel area (right) |
| **Background** | Translation book always visible | Shop scene (bookshelves, doorway) always visible |
| **Navigation** | Stays in translation workspace | Eliminates need for SceneManager.goto_X() |

---

## RISKS & MITIGATIONS

### **Risk 1: "Panels obscure important shop elements"**
**Mitigation:**
- Desk area (left 40%) never obscured
- Background dims but stays visible
- Panels slide in from right only
- Close button always visible on panels

### **Risk 2: "Confusing - which object opens which panel?"**
**Mitigation:**
- Color-coded panels match desk objects
- Tooltips on hover: "Open Customer Queue"
- Object glows when its panel is open
- Icon in tab matches desk object

### **Risk 3: "Too many panels open feels cluttered"**
**Mitigation:**
- Max 3 enforced strictly
- Clear visual hierarchy (opacity, z-index)
- Tabs show all open panels
- Oldest auto-closes if opening 4th

### **Risk 4: "Animations break existing shop scene visuals"**
**Mitigation:**
- Shop background layers stay static
- Only panels animate
- Preserve existing shop ambiance (lamp, particles)
- Test with all shop features (books, doorway, etc.)

---

## WHAT PLAYERS EXPERIENCE

### **Emotional Journey:**

**Current System:**
"I'm in a nice shop... I click the diary... now I'm in a different screen. Where did the shop go?"

**Phase 3A Diegetic:**
"I'm at my scholar's desk. I pick up the diary, and my customer queue slides out like a drawer. I can still see my desk, the bookshelves, the lamp. I'm organizing my work AT my desk, not navigating through menus."

### **The "Aha" Moment:**
When player realizes:
- They never left the shop scene
- All information is temporary overlays
- Desk objects are physical controls (not navigation buttons)
- The shop feels like a REAL workspace, not a menu hub

---

## NEXT STEPS AFTER PHASE 3A

### **If Diegetic Shop System Succeeds:**
→ **Phase 3B:** Add sound design (drawer slide, paper rustle, object click)
→ **Phase 3C:** Animate desk objects (diary opens, magnifier lens glints)
→ **Phase 3D:** Customer visits in shop (NPC appears at doorway, walks to desk)

### **If Diegetic System Fails:**
→ **Fallback:** Keep current SceneManager navigation
→ **Hybrid:** Offer setting toggle (diegetic panels vs. full-screen navigation)
→ **Lesson learned:** Some players prefer clear screen transitions over immersive overlays

---

## IMPLEMENTATION CHECKLIST

### **Phase 1: Foundation (3A.1-3A.3)**
- [ ] Modify DiaryButton, PapersButton, etc. to emit `object_clicked` instead of calling SceneManager
- [ ] Create DiegeticScreenManager.gd singleton
- [ ] Create ScreenPanel.tscn template with slide animations
- [ ] Define workspace zones (desk area 0-770px, panel area 770-1920px)
- [ ] Test: Click diary → queue panel slides in from right

### **Phase 2: Core System (3A.4-3A.6)**
- [ ] Implement max 3 panels enforcement
- [ ] Add panel stacking (z-index management)
- [ ] Add background dimming overlay
- [ ] Ensure desk objects remain clickable when panels open
- [ ] Add dictionary mini-panel (bottom-left, always visible when dictionary clicked)
- [ ] Test: Open 3 panels, verify stacking and desk accessibility

### **Phase 3: Polish (3A.7-3A.9)**
- [ ] Migrate customer queue content to queue panel
- [ ] Implement tab system (browser-style tabs at top of panel area)
- [ ] Add hover effects to desk objects
- [ ] Add panel shadows and depth
- [ ] Add tooltips
- [ ] Add sound effects (optional)
- [ ] Test: Full workflow - open queue, examination, translation panels, switch between tabs, close

---

## BOTTOM LINE

**Phase 3A transforms the shop from a navigation menu into an immersive workspace where information appears diegetically as you interact with physical objects.**

**It's the difference between:**
- Clicking "Queue" in a menu and teleporting to a queue screen
- vs. Picking up your diary and having your customer list slide out onto your desk

**If this works, the shop becomes the heart of the game - a persistent space you never want to leave.**
**If it doesn't, the current navigation system works fine.**

**Budget:** 10 hours to find out.

---

**Ready to implement?** Start with 3A.1 (Interactive Desk Objects) - modifying the existing desk objects to trigger panels instead of navigation is the foundation.
