# GemMineQuest

A Welsh mythology-inspired match-3 puzzle game where you dig through the historic mines of Wales, guided by Coblynau mine spirits, seeking the sleeping Red Dragon of Dinas Emrys.

## Requirements

- iOS 17.0+
- Xcode 16.0+

## Build & Run

1. Open `game/GemMineQuest.xcodeproj` in Xcode
2. Select an iOS Simulator or connected device
3. Build and run (Cmd+R)

## Features

- 6 Welsh mineral gem types: Dragon Stone, Welsh Gold, Arian, Preseli Stone, Slate Gem, Ceridwen's Crystal
- 5 special gems: Horizontal/Vertical Laser, Volatile (3x3 explosion), Crystal Ball (color clear), Mining Drone
- Full chain reactions between special gems, including drone cascades
- 6 Welsh-themed blocker types: Slate (multi-layer), Bluestone, Iron Cage, Dragon Fire (spreads), Blasting Charge (countdown), Awen Crystal
- 5 Welsh-themed boosters: Miner's Pick, Wildfire, Ceridwen's Cauldron, Cwn Annwn (Otherworld Hounds), Railway Rush
- Worm mechanic on every 5th level: worm eats a random gem or blocker every 5 moves
- 200+ procedurally generated levels with difficulty scaling and solvability guarantees
- 7 mining zones based on real Welsh mining regions (see Welsh Heritage below)
- Druid progression achievements: Ovate, Bard, Druid, Dragon's Friend
- Welsh folklore lore tips displayed before each level
- Free booster reward every 10 consecutive losses on a level
- Daily login rewards and milestone achievements
- Full Welsh language (Cymraeg) localization

## Welsh Heritage

### 7 Mining Zones

The game's 200+ levels are divided into 7 zones, each based on a real Welsh mining region:

1. **Great Orme** (Levels 1-30) -- Bronze Age copper mines near Llandudno, over 4,000 years old
2. **South Wales Coalfields** (Levels 31-60) -- The great industrial coalfields of the Valleys
3. **Parys Mountain** (Levels 61-90) -- The Copper Kingdom of Anglesey, with its Mars-like landscape
4. **Llechwedd Slate** (Levels 91-120) -- UNESCO World Heritage slate caverns of Blaenau Ffestiniog
5. **Dolgellau Gold Belt** (Levels 121-150) -- Source of Welsh gold used in Royal wedding rings
6. **Dolaucothi Roman Mines** (Levels 151-180) -- The only known Roman gold mine in Britain
7. **Dinas Emrys / Annwn** (Levels 181+) -- The mythical dragon's lair and gateway to the Welsh Otherworld

### Welsh Mythology

- **Coblynau** -- Mine spirits from Welsh folklore who knock near rich ore veins and guide miners
- **Y Ddraig Goch** -- The Red Dragon of Wales, sleeping beneath Dinas Emrys in the legend of Merlin
- **Annwn** -- The Welsh Otherworld, meaning "very deep" -- a realm of abundance and eternal youth
- **Ceridwen's Cauldron** -- The magical cauldron from the Mabinogion that brews the potion of Awen (divine inspiration)
- **Cwn Annwn** -- Spectral white hounds with red ears who hunt between worlds
- **Mabinogion** -- The earliest Welsh prose tales, featuring Pwyll, Branwen, Arawn, and magical cauldrons

### Druid Progression

The achievement system follows the three orders of Welsh Druidry:
- **Ovate** (green) -- Reached at Level 31
- **Bard** (blue) -- Reached at Level 91
- **Druid** (white) -- Reached at Level 151
- **Dragon's Friend** -- Complete the Dragon's Lair at Level 200

### Celtic Art & Symbols

- Celtic knotwork borders and triskele (triple spiral) motifs throughout the UI
- Love spoon star ratings -- traditional Welsh carved symbols (heart, key, crown)
- Zone-specific color palettes reflecting each mining region's character

### Welsh Language

- Full UI localization in Cymraeg (Welsh) with toggle in settings
- 229+ real Welsh place names from historic mining settlements, each with map coordinates
- Welsh mineral names: Carreg y Ddraig, Aur Cymru, Arian, Maen Preseli, Llechi, Crisial Ceridwen
- Welsh booster names: Caib y Mwynwr, Tan Gwyllt, Pair Ceridwen, Cwn Annwn, Rheilffordd

### Cultural Note

This game is inspired by the real mining heritage of Wales and its rich mythology. The Welsh mining industry shaped communities, culture, and identity for millennia -- from Bronze Age copper at the Great Orme to the coal valleys that powered the Industrial Revolution. The male voice choir tradition, the concept of hiraeth, and the enduring symbol of Y Ddraig Goch all emerge from this deep connection between the Welsh people and their land.

## Tech Stack

- **SpriteKit** for game board rendering, animations, and particle effects
- **SwiftUI** for menus, HUD overlays, settings, and shop
- **CoreGraphics** for high-resolution gem and tile texture generation
- **CryptoKit** for progress data integrity (HMAC-SHA256)

## License

This project is proprietary software. See [LICENSE](LICENSE) for details.
