import Foundation

let englishStrings: [String: String] = [
    // Language Selection
    "language.chooseTitle": "Choose Your Language",
    "language.english": "English",
    "language.welsh": "Cymraeg",
    "language.tapToSelect": "Tap a flag to select your language",

    // Main Menu
    "menu.title1": "GemMine",
    "menu.title2": "QUEST",
    "menu.tagline": "Seek the sleeping dragon in the mines of Cymru",
    "menu.startMining": "START MINING",
    "menu.continueMining": "CONTINUE MINING",
    "menu.shop": "Shop",
    "menu.settings": "Settings",
    "menu.level": "LEVEL",
    "menu.stars": "STARS",
    "menu.totalScore": "TOTAL SCORE",
    "menu.exit": "Exit",

    // Level Map
    "levelMap.title": "Mine Shaft",
    "levelMap.free": "FREE",
    "levelMap.levelLocked": "Level Locked",
    "levelMap.ok": "OK",
    "levelMap.lockedMessage": "Complete the previous levels first to dig deeper into the mine shaft!",

    // Level Detail
    "levelDetail.level": "Level %d",
    "levelDetail.superHard": "Super Hard",
    "levelDetail.hard": "Hard",
    "levelDetail.best": "Best: %d",
    "levelDetail.objectives": "Objectives",
    "levelDetail.moves": "%d moves",
    "levelDetail.shuffleWarning": "Gems shuffle every 3 moves!",
    "levelDetail.digAgain": "DIG AGAIN",
    "levelDetail.startDig": "START DIG",

    // Game Container
    "game.lv": "Lv.%d",
    "game.moves": "Moves",
    "game.movesTooltip": "Moves remaining. Match gems wisely before they run out!",
    "game.scoresTooltip": "Your current score for this level. Earn points by matching gems and activating specials.",
    "game.shopTooltip": "Open the shop to buy boosters with coins.",
    "game.god": "GOD",
    "game.godModeOn": "Unlimited moves ON",
    "game.godModeOff": "Unlimited moves OFF",
    "game.freeBooster": "Free %@ booster! (10 attempts reward)",
    "game.retryLevel": "Retry — Level %d",
    "game.levelName": "Level %d — %@",
    "game.leaveGame": "Leave Game?",
    "game.continuePlaying": "Continue Playing",
    "game.leave": "Leave",
    "game.progressLost": "Progress on this level will be lost.",
    "game.getReady": "Get ready to dig...",

    // Game Over
    "gameOver.levelComplete": "Level %d Complete!",
    "gameOver.shaftCollapsed": "Shaft Collapsed!",
    "gameOver.outOfMoves": "Out of moves",
    "gameOver.points": "%d points",
    "gameOver.goldReward": "+%d gold",
    "gameOver.nextLevel": "Next Level",
    "gameOver.retry": "Retry",
    "gameOver.backToMap": "Back to Map",
    "gameOver.needMoreMoves": "Need more moves?",
    "gameOver.goldAvailable": "%d gold available",
    "gameOver.plusMove": "+%d move",
    "gameOver.plusMoves": "+%d moves",

    // Settings
    "settings.title": "Settings",
    "settings.godMode": "God Mode",
    "settings.godModeDesc": "Unlimited moves - for casual play",
    "settings.gameplay": "Gameplay",
    "settings.hapticFeedback": "Haptic Feedback",
    "settings.feedback": "Feedback",
    "settings.boosters": "Boosters",
    "settings.boosterNote": "+1 of each every 25 levels",
    "settings.highestLevel": "Highest Level",
    "settings.levelsCompleted": "Levels Completed",
    "settings.totalStars": "Total Stars",
    "settings.progress": "Progress",
    "settings.resetAllProgress": "Reset All Progress",
    "settings.resetProgress": "Reset Progress?",
    "settings.cancel": "Cancel",
    "settings.reset": "Reset",
    "settings.resetMessage": "This will erase all your level progress and scores. This cannot be undone.",
    "settings.max5": "Max: 5",
    "settings.language": "Language",

    // Shop
    "shop.title": "MINE SHOP",
    "shop.owned": "Owned: %d",

    // Daily Reward
    "daily.title": "DAILY MINING BONUS",
    "daily.dayStreak": "Day %d/7",
    "daily.day": "Day %d",
    "daily.claimed": "Claimed!",
    "daily.claim": "CLAIM",
    "daily.continue": "Continue",
    "daily.skip": "Skip",

    // Spin Wheel
    "spin.title": "LUCKY MINE SPIN",
    "spin.youWon": "YOU WON!",
    "spin.collect": "COLLECT",
    "spin.spin": "SPIN!",
    "spin.close": "Close",
    "spin.gold100": "100 Gold",
    "spin.gold500": "500 Gold",
    "spin.pickaxe": "Miner's Pick",
    "spin.dynamite": "Wildfire",
    "spin.gems2": "2 Gems",
    "spin.drone": "Cwn Annwn",
    "spin.gemForge": "Cauldron",

    // Boosters (Welsh-themed)
    "booster.pickaxe": "Miner's Pick",
    "booster.dynamite": "Wildfire",
    "booster.gemForge": "Ceridwen's Cauldron",
    "booster.droneStrike": "Cwn Annwn",
    "booster.mineCartRush": "Railway Rush",
    "booster.pickaxeShort": "Pick",
    "booster.dynamiteShort": "Wildfire",
    "booster.forgeShort": "Cauldron",
    "booster.droneShort": "Hounds",
    "booster.cartShort": "Railway",
    "booster.pickaxeHintShort": "Break 1",
    "booster.dynamiteHintShort": "Blast 3x3",
    "booster.forgeHintShort": "Place specials",
    "booster.droneHintShort": "Seek 5",
    "booster.cartHintShort": "Row clear",
    "booster.pickaxeHint": "Miner's Pick — Tap any gem to destroy it instantly",
    "booster.dynamiteHint": "Wildfire — Tap to blast a 3x3 area with dragon fire",
    "booster.gemForgeHint": "Ceridwen's Cauldron — Brews a Crystal Ball and Volatile gem",
    "booster.droneStrikeHint": "Cwn Annwn — 5 otherworld hounds hunt random gems",
    "booster.mineCartRushHint": "Railway Rush — Converts a row to laser gems",

    // Achievement
    "achievement.unlocked": "Achievement Unlocked!",
    "achievement.gold": "+%d Gold",
    "achievement.firstDig": "First Dig",
    "achievement.apprenticeMiner": "Apprentice Miner",
    "achievement.journeymanMiner": "Journeyman Miner",
    "achievement.masterMiner": "Master Miner",
    "achievement.legendaryMiner": "Dragon Seeker",
    "achievement.starCollector": "Star Collector",
    "achievement.starHoarder": "Star Hoarder",
    "achievement.perfectRun": "Perfect Run",
    "achievement.comboKing": "Combo King",
    "achievement.explosionExpert": "Explosion Expert",
    "achievement.gemHunter": "Gem Hunter",
    "achievement.dailyDevotion": "Daily Devotion",
    "achievement.fortuneSeeker": "Fortune Seeker",
    "achievement.firstDigDesc": "Complete your first level",
    "achievement.apprenticeMinerDesc": "Complete 10 levels",
    "achievement.journeymanMinerDesc": "Complete 25 levels",
    "achievement.masterMinerDesc": "Complete 50 levels",
    "achievement.legendaryMinerDesc": "Seek the dragon — complete 100 levels",
    "achievement.starCollectorDesc": "Earn 50 total stars",
    "achievement.starHoarderDesc": "Earn 200 total stars",
    "achievement.perfectRunDesc": "Earn 3 stars on any level",
    "achievement.comboKingDesc": "Complete 5 levels in a row",
    "achievement.explosionExpertDesc": "Use 10 dynamite boosters",
    "achievement.gemHunterDesc": "Collect 500 gems total",
    "achievement.dailyDevotionDesc": "Claim 7 daily rewards in a row",
    "achievement.fortuneSeekerDesc": "Spin the wheel 10 times",

    // Event Banner
    "event.weekendRush": "Weekend Mining Rush",
    "event.doubleGold": "Double Gold on all levels!",
    "event.start": "Start",

    // Milestone
    "milestone.reached": "MILESTONE REACHED!",
    "milestone.starsEarned": "%@ Stars Earned!",
    "milestone.levelsCompleted": "%@ Levels Completed!",
    "milestone.reward": "+200 Gold & 3 gems",
    "milestone.awesome": "AWESOME!",

    // Objectives
    "objective.reachScore": "Score %d points",
    "objective.clearAllOre": "Mine all ore tiles",
    "objective.dropTreasures": "Drop %d treasure(s) to mine cart",
    "objective.dropTreasure1": "Drop %d treasure to mine cart",
    "objective.collectGems": "Collect %d %@(s) (%@)",
    "objective.collectGem1": "Collect %d %@ (%@)",
    "objective.collectSpecials": "Create %d %@(s)",
    "objective.collectSpecial1": "Create %d %@",
    "objective.reachScoreDesc": "Score at least %d points by matching gems",
    "objective.clearAllOreDesc": "Match gems on gold ore tiles to mine them. Boosters don't count!",
    "objective.dropTreasuresDesc": "Move %d treasure(s) to the mine cart at the bottom",
    "objective.dropTreasure1Desc": "Move %d treasure to the mine cart at the bottom",
    "objective.collectGemsDesc": "Match and collect %d %@ gems (%@)",
    "objective.collectSpecialsDesc": "Create %d %@ gem(s) through special matches",
    "objective.collectSpecial1Desc": "Create %d %@ gem through special matches",
    "objective.reachScoreShort": "%d pts",
    "objective.clearAllOreShort": "Clear ore",
    "objective.clearAllOreShortColor": "Clear all ore",
    "objective.dropTreasuresShort": "%d treasure(s)",
    "objective.dropTreasure1Short": "%d treasure",

    // Gem Types (Welsh Minerals)
    "gem.ruby": "Dragon Stone",
    "gem.gold": "Welsh Gold",
    "gem.silver": "Arian",
    "gem.emerald": "Preseli Stone",
    "gem.sapphire": "Slate Gem",
    "gem.amethyst": "Ceridwen's Crystal",
    "gem.hintRed": "red",
    "gem.hintGold": "gold",
    "gem.hintSilver": "silver",
    "gem.hintGreen": "green",
    "gem.hintBlue": "blue",
    "gem.hintPurple": "purple",

    // Special Types
    "special.normal": "Normal",
    "special.laserH": "Laser Gem (H)",
    "special.laserV": "Laser Gem (V)",
    "special.volatile": "Volatile Gem",
    "special.crystalBall": "Crystal Ball",
    "special.miningDrone": "Mining Drone",

    // Shop Items (Welsh-themed)
    "shopItem.pickaxe3": "Miner's Pick x3",
    "shopItem.pickaxe10": "Miner's Pick x10",
    "shopItem.dynamite1": "Wildfire",
    "shopItem.dynamite5": "Wildfire x5",
    "shopItem.drone1": "Cwn Annwn",
    "shopItem.drone3": "Cwn Annwn x3",
    "shopItem.forge1": "Ceridwen's Cauldron",
    "shopItem.forge3": "Cauldron x3",
    "shopItem.cart1": "Railway Rush",

    // Objective Progress Labels
    "progress.score": "Score",
    "progress.oreCleared": "Ore cleared",
    "progress.treasures": "Treasures",

    // Encouragement Messages
    "encourage.almostThere": "Almost there!",
    "encourage.lastOre": "Last ore vein!",
    "encourage.oneMoreTreasure": "One more treasure!",
    "encourage.gemsLeft": "%d %@ left!",
    "encourage.oneMoreSpecial": "One more %@!",
    "encourage.movesLeft": "%d moves left!",

    // New Welsh Achievements (Druid Progression)
    "achievement.ovateOfTheMine": "Ovate of the Mine",
    "achievement.ovateOfTheMineDesc": "Reach the South Wales Coalfields (Level 31)",
    "achievement.bardOfTheDeep": "Bard of the Deep",
    "achievement.bardOfTheDeepDesc": "Reach the Llechwedd Slate mines (Level 91)",
    "achievement.druidOfAnnwn": "Druid of Annwn",
    "achievement.druidOfAnnwnDesc": "Reach the Roman gold mines of Dolaucothi (Level 151)",
    "achievement.dragonsFriend": "Dragon's Friend",
    "achievement.dragonsFriendDesc": "Complete the Dragon's Lair at Dinas Emrys (Level 200)",

    // Mining Zones
    "zone.1.name": "Great Orme",
    "zone.1.welsh": "Y Gogarth",
    "zone.1.tagline": "Bronze Age Depths — 4,000 Years of Mining",
    "zone.2.name": "South Wales Coalfields",
    "zone.2.welsh": "Maes Glo De Cymru",
    "zone.2.tagline": "The Black Gold of the Valleys",
    "zone.3.name": "Parys Mountain",
    "zone.3.welsh": "Mynydd Parys",
    "zone.3.tagline": "The Copper Kingdom of Anglesey",
    "zone.4.name": "Llechwedd Slate",
    "zone.4.welsh": "Llechi Llechwedd",
    "zone.4.tagline": "Cathedral Caverns of Blue-Grey Stone",
    "zone.5.name": "Dolgellau Gold Belt",
    "zone.5.welsh": "Gwregys Aur Dolgellau",
    "zone.5.tagline": "The Royal Gold of Cymru",
    "zone.6.name": "Dolaucothi Roman Mines",
    "zone.6.welsh": "Mwyngloddiau Rhufeinig Dolaucothi",
    "zone.6.tagline": "Ancient Power Beneath Sacred Ground",
    "zone.7.name": "Dinas Emrys",
    "zone.7.welsh": "Dinas Emrys — Annwn",
    "zone.7.tagline": "The Dragon's Lair — Where Two Worlds Meet",

    // Zone Transitions
    "zone.1.narrative": "The Coblynau appear in the ancient copper tunnels of the Great Orme, knocking to guide you deeper...",
    "zone.2.narrative": "The mine spirits lead you south to the great coalfields, where generations of Welsh miners carved their legacy.",
    "zone.3.narrative": "The Coblynau whisper of the Copper Kingdom — Parys Mountain, where the earth bleeds orange and green.",
    "zone.4.narrative": "You descend into the cathedral-like chambers of Llechwedd, where blue-grey slate holds the memory of ages.",
    "zone.5.narrative": "Golden veins glitter ahead — the Coblynau grow excited. You have reached the royal gold of Dolgellau.",
    "zone.6.narrative": "Ancient Roman tunnels surround you. The Druids once guarded these mines. The power of Annwn draws near.",
    "zone.7.narrative": "The ground trembles. Beneath Dinas Emrys, an underground lake glows red and blue. Y Ddraig Goch stirs...",

    // Blocker Display Names
    "blocker.granite": "Slate",
    "blocker.boulder": "Bluestone",
    "blocker.lava": "Dragon Fire",
    "blocker.amber": "Awen Crystal",
    "blocker.cage": "Iron Cage",
    "blocker.tnt": "Blasting Charge",

    // Zone UI
    "zone.entering": "ENTERING",
    "zone.continue": "Continue",

    // Settings Language
    "settings.langEN": "EN",
    "settings.langCY": "CY",

    // Lore Tips — Zone 1: Great Orme
    "lore.zone1.tip0": "The Great Orme copper mines near Llandudno are over 4,000 years old — the largest prehistoric mines in the world.",
    "lore.zone1.tip1": "Bronze Age miners at the Great Orme used bone and antler tools to extract copper from limestone tunnels.",
    "lore.zone1.tip2": "The Coblynau are Welsh mine spirits — tiny miners dressed in miniature clothing who knock near rich ore veins.",
    "lore.zone1.tip3": "Wales has been mined continuously for over 4,000 years, from Bronze Age copper to modern-day coal.",
    "lore.zone1.tip4": "The Welsh word 'mwynglawdd' means mine. 'Cloddio' means to dig — the heart of our quest.",

    // Lore Tips — Zone 2: South Wales Coalfields
    "lore.zone2.tip0": "The South Wales Coalfield was the largest in Britain. By 1913, Barry was the world's largest coal-exporting port.",
    "lore.zone2.tip1": "Welsh male voice choirs were born in mining communities — unemployed miners formed choirs that became world-famous.",
    "lore.zone2.tip2": "Wales is called 'Gwlad y Gân' — Land of Song. The singing tradition runs as deep as the coal seams.",
    "lore.zone2.tip3": "A Davy safety lamp saved countless lives in Welsh mines by detecting explosive firedamp gas underground.",
    "lore.zone2.tip4": "The Welsh concept of 'hiraeth' — a deep longing for home — resonates with mining communities scattered across the world.",

    // Lore Tips — Zone 3: Parys Mountain
    "lore.zone3.tip0": "Parys Mountain on Anglesey was once the largest copper mine in the world. Its Mars-like landscape still astonishes visitors.",
    "lore.zone3.tip1": "The mineral Anglesite was first discovered at Parys Mountain in 1783 and named after the island of Anglesey.",
    "lore.zone3.tip2": "Thomas Williams, the 'Copper King,' controlled global copper prices from Parys Mountain in the 1780s.",
    "lore.zone3.tip3": "Anglesey — Ynys Môn in Welsh — was the last stronghold of the Druids before the Roman invasion in AD 61.",
    "lore.zone3.tip4": "The vivid orange, purple, and green pools at Parys Mountain are caused by copper, iron, and sulfur minerals.",

    // Lore Tips — Zone 4: Llechwedd Slate
    "lore.zone4.tip0": "The North Wales Slate Landscape is a UNESCO World Heritage Site — the industry that roofed the world.",
    "lore.zone4.tip1": "Llechwedd Slate Caverns at Blaenau Ffestiniog contain cathedral-like underground chambers carved by quarrymen.",
    "lore.zone4.tip2": "Welsh slate has been quarried since Roman times. Penrhyn and Dinorwic were the two largest slate quarries on Earth.",
    "lore.zone4.tip3": "The Druids had three orders: Ovate (green robes), Bard (blue robes), and Druid (white robes) — a progression of wisdom.",
    "lore.zone4.tip4": "The Celtic triskele — three interlocking spirals — represents earth, water, and sky, the three realms of existence.",

    // Lore Tips — Zone 5: Dolgellau Gold Belt
    "lore.zone5.tip0": "Welsh gold from Dolgellau has been used for Royal wedding rings since the Queen Mother's in 1923.",
    "lore.zone5.tip1": "The Clogau Gold Mine near Dolgellau was the richest in Wales, producing over 78,000 troy ounces of gold.",
    "lore.zone5.tip2": "Welsh love spoons are carved wooden tokens of affection — each symbol has meaning: hearts for love, keys for devotion.",
    "lore.zone5.tip3": "'Awen' means divine inspiration in Welsh — the three rays of the Awen symbol represent truth, knowledge, and poetry.",
    "lore.zone5.tip4": "Ceridwen's Cauldron brewed the potion of Awen for a year and a day — only the first three drops held its power.",

    // Lore Tips — Zone 6: Dolaucothi Roman Mines
    "lore.zone6.tip0": "Dolaucothi is the only known Roman gold mine in Britain, operated from around AD 74 for over two centuries.",
    "lore.zone6.tip1": "The Mabinogion contains the earliest Welsh prose tales — stories of Pwyll, Branwen, and the magical cauldron of rebirth.",
    "lore.zone6.tip2": "In the Mabinogion, Arawn rules Annwn — the Welsh Otherworld, a realm of abundance beneath the earth.",
    "lore.zone6.tip3": "The Preseli Bluestones of Pembrokeshire were transported 150 miles to build Stonehenge — connecting Welsh stone to sacred power.",
    "lore.zone6.tip4": "Myrddin (Merlin) was said to be born in Carmarthen — Caerfyrddin in Welsh, meaning 'Merlin's Fort.'",

    // Lore Tips — Zone 7: Dinas Emrys / Annwn
    "lore.zone7.tip0": "Beneath Dinas Emrys in Snowdonia, two dragons sleep in an underground lake — one red, one white.",
    "lore.zone7.tip1": "Young Merlin revealed the dragons to King Vortigern, prophesying that Y Ddraig Goch — the Red Dragon — would triumph.",
    "lore.zone7.tip2": "Annwn, the Welsh Otherworld, means 'very deep.' It is not a dark place — it is a paradise of eternal youth and abundance.",
    "lore.zone7.tip3": "The Cwn Annwn are spectral white hounds with red ears who hunt between worlds, guided by Gwyn ap Nudd.",
    "lore.zone7.tip4": "Y Ddraig Goch has been the symbol of Wales for over 1,500 years — courage, defiance, and endurance given form.",

    // Zone-Specific Victory Text
    "victory.zone1": "The ancient copper yields its treasure",
    "victory.zone2": "The black gold of the valleys shines",
    "victory.zone3": "The Copper Kingdom reveals its secrets",
    "victory.zone4": "The slate cathedral echoes your triumph",
    "victory.zone5": "Royal Welsh gold gleams in your hands",
    "victory.zone6": "The ancient Roman veins run true",
    "victory.zone7": "The dragon stirs in the deep",

    // Tooltip Hints — Blockers
    "tooltip.granite": "Granite (%d layer%@) — Match next to it to crack",
    "tooltip.granite.s": "s",
    "tooltip.boulder": "Boulder — Match next to it to remove",
    "tooltip.cage": "Caged Gem — Match the gem inside to free it",
    "tooltip.lava": "Lava — Spreads each turn! Match next to it",
    "tooltip.tnt": "TNT (%d moves) — Clear before it explodes!",
    "tooltip.amber": "Amber — Match next to it to break free",

    // Tooltip Hints — Ore
    "tooltip.oreVein": "Ore Vein — Match gems here to mine it",
    "tooltip.doubleOre": "Thick Ore — Match here twice to mine it",

    // Tooltip Hints — Special Gems
    "tooltip.laserH": "Laser Gem — Clears the entire row",
    "tooltip.laserV": "Laser Gem — Clears the entire column",
    "tooltip.volatile": "Volatile Gem — Explodes a 3×3 area",
    "tooltip.crystalBall": "Crystal Ball — Swap to remove all of one color",
    "tooltip.miningDrone": "Mining Drone — Deploys 3 seekers to clear targets",

    // HUD Labels
    "hud.score": "SCORE",
    "hud.moves": "MOVES",

    // Game Banners
    "game.levelComplete": "Level Complete!",
    "game.outOfMoves": "Out of Moves!",
    "game.reshuffling": "Reshuffling...",

    // Objective Display
    "objective.scoreDisplay": "Score: %d/%d",
    "objective.oreDisplay": "Ore: %d/%d",
    "objective.treasureDisplay": "Treasure: %d/%d",

]
