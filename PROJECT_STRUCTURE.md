# Project Structure Documentation

This document details the purpose and contents of each folder in the Glyphic project.

---

## `/scenes/` - Godot Scene Files

Contains all `.tscn` (text scene) files that define the visual hierarchy and node structure.

### `/scenes/ui/`
**Purpose:** User interface components and menus  
**Contents:**
- Main menu screens
- HUD elements (status bars, counters)
- Popup dialogs and overlays
- Reusable UI components (buttons, panels, cards)

**Examples:**
- `CustomerCard.tscn` - Individual customer card component
- `DictionaryEntry.tscn` - Symbol entry in dictionary panel
- `CustomerSelectionPopup.tscn` - Daily customer selection overlay
- `UpgradeShopMenu.tscn` - Shop interface for purchasing upgrades

### `/scenes/levels/`
**Purpose:** Game level/day scenes  
**Contents:**
- Main game scene (desk workspace)
- Individual day scenes (if separated)
- Level-specific layouts

**Examples:**
- `Main.tscn` - Primary game scene (workspace, panels, UI)
- `DayTransition.tscn` - Day-end summary screen

### `/scenes/entities/`
**Purpose:** Reusable game entities with independent logic  
**Contents:**
- Interactive game objects
- Self-contained systems with behavior

**Examples:**
- `BookExamination.tscn` - Book investigation interface
- `TranslationWorkspace.tscn` - Main puzzle area
- `Customer.tscn` - Customer entity with dialogue

### `/scenes/effects/`
**Purpose:** Visual effects and particles  
**Contents:**
- Particle systems
- Animation effects
- Screen transitions

**Examples:**
- `DayTransition.tscn` - Fade/wipe effects
- `CashSparkle.tscn` - Money collection animation (if added)

---

## `/scripts/` - GDScript Code Files

Contains all `.gd` script files that implement game logic and behavior.

### `/scripts/managers/`
**Purpose:** Singleton/autoload managers for global systems  
**Contents:**
- Game state management
- Save/load systems
- Event buses
- Global data managers

**Examples:**
- `GameStateManager.gd` - Tracks day, cash, capacity, rent
- `DictionaryManager.gd` - Symbol-to-word mappings, confidence levels
- `CustomerManager.gd` - Customer queue, relationship tracking
- `EventBus.gd` - Global event system (if needed)

**Best Practice:** These are typically set as AutoLoad singletons in project settings.

### `/scripts/entities/`
**Purpose:** Behavior scripts for game entities  
**Contents:**
- Character controllers
- Interactive object logic
- Entity-specific behavior

**Examples:**
- `Customer.gd` - Customer behavior, dialogue, negotiation
- `TranslationBook.gd` - Book data, examination state

### `/scripts/ui/`
**Purpose:** UI controllers and interaction handlers  
**Contents:**
- Menu navigation
- Button handlers
- UI state management
- Panel controllers

**Examples:**
- `CustomerCard.gd` - Card display, accept/refuse buttons
- `DictionaryPanel.gd` - Symbol list, filtering, search
- `UpgradeShop.gd` - Shop UI, purchase validation
- `TopBar.gd` - Status display updates

### `/scripts/systems/`
**Purpose:** Core game systems and mechanics  
**Contents:**
- Translation validation logic
- Economic calculations
- Puzzle generation
- Day progression

**Examples:**
- `TranslationSystem.gd` - Symbol matching, validation, scoring
- `MoneySystem.gd` - Payment, deductions, rent tracking
- `CapacitySystem.gd` - Daily slot management, refusal logic
- `NegotiationSystem.gd` - Fast/Cheap/Accurate priority handling

### `/scripts/utils/`
**Purpose:** Helper functions and utilities  
**Contents:**
- Math helpers
- String formatting
- Data conversion
- Debug tools

**Examples:**
- `StringUtils.gd` - Text formatting, symbol conversion
- `MathUtils.gd` - Random generators, range mapping
- `DebugUtils.gd` - Logging, cheats, test helpers
- `Constants.gd` - Global constants (rent amount, capacity limit)

---

## `/assets/` - Game Assets

Contains all non-code resources (graphics, audio, fonts, shaders).

### `/assets/sprites/`
**Purpose:** 2D images and textures  
**File Types:** `.png`, `.svg`, `.jpg`

#### `/assets/sprites/characters/`
- Customer portraits (if added)
- Character expressions
- NPC sprites

#### `/assets/sprites/environment/`
- Desk background
- Workspace textures
- Office decorations
- Book covers

#### `/assets/sprites/ui/`
- Button graphics
- Panel backgrounds
- Icons (accept, refuse, zoom, UV light)
- Status indicators

#### `/assets/sprites/effects/`
- Particle textures
- Visual effect elements
- Screen overlays

### `/assets/audio/`
**Purpose:** Sound files  
**File Types:** `.wav`, `.ogg`, `.mp3`

#### `/assets/audio/music/`
- Background music tracks
- Ambient loops
- Day-specific themes

#### `/assets/audio/sfx/`
- UI click sounds
- Cash register ding
- Book page turn
- Success/failure jingles

### `/assets/fonts/`
**Purpose:** Typography files  
**File Types:** `.ttf`, `.otf`, `.woff`

**Examples:**
- `SymbolFont.ttf` - Font supporting ∆◊≈⊕⊗⬡∞◈ Unicode characters
- `UIFont.ttf` - Main interface font
- `HandwritingFont.ttf` - For handwritten notes (if added)

### `/assets/shaders/`
**Purpose:** Custom shader files  
**File Types:** `.gdshader`, `.shader`

**Examples:**
- `UVLightEffect.gdshader` - UV light reveal shader
- `ParchmentTexture.gdshader` - Paper texture effect

---

## `/data/` - Game Data Files

Contains structured data separate from code.

### `/data/json/`
**Purpose:** JSON data files  
**Contents:**
- Translation text definitions
- Customer data
- Dialogue trees
- Item/upgrade definitions

**Examples:**
- `translation_texts.json` - 5 translation puzzles with solutions
- `customers.json` - Customer properties, dialogue, priorities
- `upgrades.json` - UV Light, Coffee Machine, Better Lamp data

**Format Example:**
```json
{
  "id": 1,
  "name": "Text 1 - Family History",
  "symbols": "∆ ◊≈ ⊕⊗◈",
  "solution": "the old way",
  "difficulty": "Easy",
  "payment_base": 50
}
```

### `/data/configs/`
**Purpose:** Configuration files  
**Contents:**
- Game balance values
- System settings
- Difficulty presets

**Examples:**
- `economy_config.json` - Rent, utilities, starting cash
- `gameplay_config.json` - Capacity limits, refusal tolerances
- `debug_config.json` - Cheat codes, test modes

---

## `/resources/` - Godot Resource Files

Contains `.tres` resource files created in Godot.

### `/resources/materials/`
**Purpose:** Material resources  
**Contents:**
- CanvasItemMaterial
- ShaderMaterial instances
- Texture configurations

**Examples:**
- `parchment_material.tres` - Paper texture material
- `uv_light_material.tres` - UV effect material

### `/resources/themes/`
**Purpose:** UI theme resources  
**Contents:**
- Theme files defining UI appearance
- StyleBox resources
- Font configurations

**Examples:**
- `main_theme.tres` - Primary UI theme (colors, fonts, styles)
- `button_styles.tres` - Button hover/pressed states
- `panel_styles.tres` - Panel background styles

---

## Special Files

### `.gdignore`
**Purpose:** Tells Godot to ignore folders during import  
**Location:** Place in folders that should not be scanned

**Use Cases:**
- `/data/` (if you want to manually load JSON, not auto-import)
- External tool output folders
- Documentation folders

**Note:** For this project, `.gdignore` is generally NOT needed unless you have large external data that slows down Godot's import process.

---

## File Naming Conventions

### Scenes (`.tscn`)
- **PascalCase:** `CustomerCard.tscn`, `MainWorkspace.tscn`
- Match the root node name

### Scripts (`.gd`)
- **PascalCase:** `GameStateManager.gd`, `Customer.gd`
- Match the class name if using `class_name`

### Assets
- **snake_case:** `desk_background.png`, `button_accept.png`
- Descriptive, lowercase with underscores

### Data Files
- **snake_case:** `translation_texts.json`, `economy_config.json`
- Descriptive, indicates content type

---

## Best Practices

### Scene Organization
1. **One scene per reusable component** - Makes prefabs easy to instantiate
2. **Separate UI from logic** - UI scenes in `/scenes/ui/`, controllers in `/scripts/ui/`
3. **Use scene inheritance** - Base scenes for shared behavior

### Script Organization
1. **Managers are AutoLoads** - Set in Project Settings > Autoload
2. **One script per file** - Match filename to class name
3. **Group related systems** - E.g., all economy code in `MoneySystem.gd`

### Asset Organization
1. **Mirror folder structure in imports** - Keep `.import` organized
2. **Use descriptive names** - `customer_card_background.png` not `bg.png`
3. **Optimize before importing** - Compress PNGs, downsample audio

### Data Organization
1. **Separate data from code** - Use JSON for content, GDScript for logic
2. **Version control friendly** - Text-based formats (JSON, not binary)
3. **Validate on load** - Check for required keys before using data

---

## Development Workflow

### Adding a New Feature

1. **Plan folder locations:**
   - Where does the scene go? (`/scenes/ui/`, `/scenes/entities/`)
   - Where does the script go? (`/scripts/systems/`, `/scripts/ui/`)
   - What data is needed? (`/data/json/`)

2. **Create scene first:**
   - Build visual layout in `/scenes/`
   - Add placeholder labels/sprites

3. **Attach script:**
   - Create in appropriate `/scripts/` subfolder
   - Implement logic

4. **Add data if needed:**
   - Create JSON in `/data/json/`
   - Load via `FileAccess` or `JSON.parse()`

5. **Test in isolation:**
   - Run scene directly (F6 in Godot)
   - Verify behavior before integrating

### Refactoring

- **Extract reusable scenes:** If a UI element repeats, make it a scene in `/scenes/ui/`
- **Consolidate scripts:** If multiple scripts share logic, move to `/scripts/utils/`
- **Externalize data:** If values are hardcoded, move to JSON in `/data/configs/`

---

## Quick Reference

| Need to... | Go to... |
|------------|----------|
| Create a new UI component | `/scenes/ui/` + `/scripts/ui/` |
| Add a game system | `/scripts/systems/` |
| Store game data | `/data/json/` |
| Add a sprite | `/assets/sprites/` (appropriate subfolder) |
| Create a reusable entity | `/scenes/entities/` + `/scripts/entities/` |
| Add a manager singleton | `/scripts/managers/` + Project Settings > Autoload |
| Store a theme | `/resources/themes/` |
| Add helper functions | `/scripts/utils/` |

---

## Maintenance Notes

- **Keep folders flat when possible** - Don't over-nest subfolders
- **Delete unused files promptly** - Avoid clutter
- **Use Git effectively** - `.gitignore` handles Godot internals
- **Document custom conventions** - Update this file if you add new patterns

---

This structure balances organization with simplicity, designed for rapid prototyping while maintaining clear separation of concerns.
