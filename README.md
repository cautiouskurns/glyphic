# Glyphic

A translation shop game combining cipher puzzles with Papers Please-style capacity management.

## Project Overview

**Glyphic** is a weekend prototype (12-16 hours) for a translation shop game where you decode mysterious texts using pattern recognition while managing limited daily capacity and customer relationships.

**Engine:** Godot 4.5  
**Language:** GDScript  
**Development Timeline:** One weekend

## Folder Structure

```
glyphic/
├── scenes/             # Godot scene files (.tscn)
│   ├── ui/            # UI components and menus
│   ├── levels/        # Game levels/days
│   ├── entities/      # Reusable game entities
│   └── effects/       # Visual effects
│
├── scripts/           # GDScript files (.gd)
│   ├── managers/      # Game state, data managers
│   ├── entities/      # Entity behavior scripts
│   ├── ui/           # UI controller scripts
│   ├── systems/      # Core game systems
│   └── utils/        # Helper functions, utilities
│
├── assets/           # Game assets
│   ├── sprites/      # 2D graphics
│   │   ├── characters/
│   │   ├── environment/
│   │   ├── ui/
│   │   └── effects/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   └── shaders/
│
├── data/             # Game data files
│   ├── json/         # JSON data files
│   └── configs/      # Configuration files
│
└── resources/        # Godot resources
    ├── materials/    # Material resources
    └── themes/       # UI theme resources
```

## Running the Project

### In Godot Editor
```bash
godot "/Users/diarmuidcurran/Godot Projects/Prototypes/glyphic/project.godot"
```

### From Command Line
```bash
godot --path "/Users/diarmuidcurran/Godot Projects/Prototypes/glyphic"
```

## Documentation

- **CLAUDE.md** - Development guidelines and architecture
- **PROJECT_STRUCTURE.md** - Detailed folder organization
- **Glyphic - Prototype Design Document.md** - Complete game design
- **DEVELOPMENT_ROADMAP.md** - Phase-by-phase feature breakdown

## Development Status

This is an early-stage prototype. See DEVELOPMENT_ROADMAP.md for current progress.
