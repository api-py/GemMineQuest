import Foundation

let welshStrings: [String: String] = [
    // Language Selection
    "language.chooseTitle": "Dewiswch Eich Iaith",
    "language.english": "English",
    "language.welsh": "Cymraeg",
    "language.tapToSelect": "Tapiwch faner i ddewis eich iaith",

    // Main Menu
    "menu.title1": "GemMine",
    "menu.title2": "QUEST",
    "menu.tagline": "Chwiliwch am y ddraig sy'n cysgu ym mwyngloddiau Cymru",
    "menu.startMining": "DECHRAU CLODDIO",
    "menu.continueMining": "PARHAU I GLODDIO",
    "menu.shop": "Siop",
    "menu.settings": "Gosodiadau",
    "menu.level": "LEFEL",
    "menu.stars": "S\u{00CA}R",
    "menu.totalScore": "SGÔR LLAWN",
    "menu.exit": "Gadael",

    // Level Map
    "levelMap.title": "Siafft y Mwynglawdd",
    "levelMap.free": "AM DDIM",
    "levelMap.levelLocked": "Lefel Ar Glo",
    "levelMap.ok": "Iawn",
    "levelMap.lockedMessage": "Cwblhewch y lefelau blaenorol yn gyntaf i gloddio'n ddyfnach i'r siafft!",

    // Level Detail
    "levelDetail.level": "Lefel %d",
    "levelDetail.superHard": "Anodd Iawn",
    "levelDetail.hard": "Anodd",
    "levelDetail.best": "Gorau: %d",
    "levelDetail.objectives": "Amcanion",
    "levelDetail.moves": "%d symudiad",
    "levelDetail.shuffleWarning": "Mae gemau'n cymysgu bob 3 symudiad!",
    "levelDetail.digAgain": "CLODDIO ETO",
    "levelDetail.startDig": "DECHRAU CLODDIO",

    // Game Container
    "game.lv": "Lf.%d",
    "game.moves": "Symudiadau",
    "game.movesTooltip": "Symudiadau ar ôl. Cyfatebwch emau'n ddoeth cyn iddynt redeg allan!",
    "game.scoresTooltip": "Eich sgôr presennol ar gyfer y lefel hon. Enillwch bwyntiau drwy gyfateb gemau ac actifadu arbenigeddau.",
    "game.shopTooltip": "Agorwch y siop i brynu hwbiau gyda darnau arian.",
    "game.god": "DUW",
    "game.godModeOn": "Symudiadau diderfyn YMLAEN",
    "game.godModeOff": "Symudiadau diderfyn I FFWRDD",
    "game.freeBooster": "Hwb %@ am ddim! (gwobr 10 ymgais)",
    "game.retryLevel": "Ail-geisio — Lefel %d",
    "game.levelName": "Lefel %d — %@",
    "game.leaveGame": "Gadael y Gêm?",
    "game.continuePlaying": "Parhau i Chwarae",
    "game.leave": "Gadael",
    "game.progressLost": "Bydd cynnydd ar y lefel hon yn cael ei golli.",
    "game.getReady": "Paratowch i gloddio...",

    // Game Over
    "gameOver.levelComplete": "Lefel %d Wedi'i Chwblhau!",
    "gameOver.shaftCollapsed": "Siafft Wedi Cwympo!",
    "gameOver.outOfMoves": "Dim symudiadau ar ôl",
    "gameOver.points": "%d pwynt",
    "gameOver.goldReward": "+%d aur",
    "gameOver.nextLevel": "Lefel Nesaf",
    "gameOver.retry": "Ail-geisio",
    "gameOver.backToMap": "Nôl i'r Map",
    "gameOver.needMoreMoves": "Angen mwy o symudiadau?",
    "gameOver.goldAvailable": "%d aur ar gael",
    "gameOver.plusMove": "+%d symudiad",
    "gameOver.plusMoves": "+%d symudiad",

    // Settings
    "settings.title": "Gosodiadau",
    "settings.godMode": "Modd Duw",
    "settings.godModeDesc": "Symudiadau diderfyn - ar gyfer chwarae hamddenol",
    "settings.gameplay": "Chwarae",
    "settings.hapticFeedback": "Adborth Haptig",
    "settings.feedback": "Adborth",
    "settings.boosters": "Hwbiau",
    "settings.boosterNote": "+1 o bob un bob 25 lefel",
    "settings.highestLevel": "Lefel Uchaf",
    "settings.levelsCompleted": "Lefelau Cwblhawyd",
    "settings.totalStars": "Cyfanswm Sêr",
    "settings.progress": "Cynnydd",
    "settings.resetAllProgress": "Ailosod Pob Cynnydd",
    "settings.resetProgress": "Ailosod Cynnydd?",
    "settings.cancel": "Canslo",
    "settings.reset": "Ailosod",
    "settings.resetMessage": "Bydd hyn yn dileu eich holl gynnydd lefel a sgoriau. Ni ellir dadwneud hyn.",
    "settings.max5": "Uchaf: 5",
    "settings.language": "Iaith",

    // Shop
    "shop.title": "SIOP Y MWYNGLAWDD",
    "shop.owned": "Perchennog: %d",

    // Daily Reward
    "daily.title": "BONWS CLODDIO DYDDIOL",
    "daily.dayStreak": "Diwrnod %d/7",
    "daily.day": "Diwrnod %d",
    "daily.claimed": "Hawliwyd!",
    "daily.claim": "HAWLIO",
    "daily.continue": "Parhau",
    "daily.skip": "Hepgor",

    // Spin Wheel
    "spin.title": "TROELL LWCUS Y MWYNGLAWDD",
    "spin.youWon": "RYDYCH WEDI ENNILL!",
    "spin.collect": "CASGLU",
    "spin.spin": "TROELLI!",
    "spin.close": "Cau",
    "spin.gold100": "100 Aur",
    "spin.gold500": "500 Aur",
    "spin.pickaxe": "Caib y Mwynwr",
    "spin.dynamite": "Tân Gwyllt",
    "spin.gems2": "2 Em",
    "spin.drone": "Cŵn Annwn",
    "spin.gemForge": "Pair Ceridwen",

    // Boosters (Welsh-themed)
    "booster.pickaxe": "Caib y Mwynwr",
    "booster.dynamite": "Tân Gwyllt",
    "booster.gemForge": "Pair Ceridwen",
    "booster.droneStrike": "Cŵn Annwn",
    "booster.mineCartRush": "Rhuthr Rheilffordd",
    "booster.pickaxeShort": "Caib",
    "booster.dynamiteShort": "Tân",
    "booster.forgeShort": "Pair",
    "booster.droneShort": "Cŵn",
    "booster.cartShort": "Rheilffordd",
    "booster.pickaxeHintShort": "Torri 1",
    "booster.dynamiteHintShort": "Ffrwydro 3x3",
    "booster.forgeHintShort": "Gosod arbenigol",
    "booster.droneHintShort": "Hela 5",
    "booster.cartHintShort": "Clirio rhes",
    "booster.pickaxeHint": "Caib y Mwynwr — Tapiwch unrhyw em i'w dinistrio ar unwaith",
    "booster.dynamiteHint": "Tân Gwyllt — Tapiwch i ffrwydro ardal 3x3 gyda thân draig",
    "booster.gemForgeHint": "Pair Ceridwen — Yn bragu Pêl Grisial ac em Ansefydlog",
    "booster.droneStrikeHint": "Cŵn Annwn — 5 helgi'r Annwn yn hela emau ar hap",
    "booster.mineCartRushHint": "Rhuthr Rheilffordd — Yn troi rhes yn emau laser",

    // Achievement
    "achievement.unlocked": "Cyflawniad Wedi'i Ddatgloi!",
    "achievement.gold": "+%d Aur",
    "achievement.firstDig": "Cloddiad Cyntaf",
    "achievement.apprenticeMiner": "Mwynwr Prentis",
    "achievement.journeymanMiner": "Mwynwr Siwrne",
    "achievement.masterMiner": "Meistr Mwynwr",
    "achievement.legendaryMiner": "Ceisiwr y Ddraig",
    "achievement.starCollector": "Casglwr Sêr",
    "achievement.starHoarder": "Pentyrwr Sêr",
    "achievement.perfectRun": "Rhediad Perffaith",
    "achievement.comboKing": "Brenin Combo",
    "achievement.explosionExpert": "Arbenigwr Ffrwydro",
    "achievement.gemHunter": "Heliwr Emau",
    "achievement.dailyDevotion": "Ymroddiad Dyddiol",
    "achievement.fortuneSeeker": "Ceisiwr Ffortiwn",
    "achievement.firstDigDesc": "Cwblhewch eich lefel gyntaf",
    "achievement.apprenticeMinerDesc": "Cwblhewch 10 lefel",
    "achievement.journeymanMinerDesc": "Cwblhewch 25 lefel",
    "achievement.masterMinerDesc": "Cwblhewch 50 lefel",
    "achievement.legendaryMinerDesc": "Ceisiwch y ddraig — cwblhewch 100 lefel",
    "achievement.starCollectorDesc": "Enillwch 50 seren i gyd",
    "achievement.starHoarderDesc": "Enillwch 200 seren i gyd",
    "achievement.perfectRunDesc": "Enillwch 3 seren ar unrhyw lefel",
    "achievement.comboKingDesc": "Cwblhewch 5 lefel yn olynol",
    "achievement.explosionExpertDesc": "Defnyddiwch 10 hwb dynameit",
    "achievement.gemHunterDesc": "Casglwch 500 em i gyd",
    "achievement.dailyDevotionDesc": "Hawliwch 7 gwobr ddyddiol yn olynol",
    "achievement.fortuneSeekerDesc": "Troellwch yr olwyn 10 gwaith",

    // Event Banner
    "event.weekendRush": "Rhuthr Cloddio'r Penwythnos",
    "event.doubleGold": "Aur dwbl ar bob lefel!",
    "event.start": "Dechrau",

    // Milestone
    "milestone.reached": "CARREG FILLTIR!",
    "milestone.starsEarned": "%@ Seren Wedi'u Hennill!",
    "milestone.levelsCompleted": "%@ Lefel Wedi'u Cwblhau!",
    "milestone.reward": "+200 Aur a 3 em",
    "milestone.awesome": "GWYCH!",

    // Objectives
    "objective.reachScore": "Sgorio %d pwynt",
    "objective.clearAllOre": "Cloddio pob teilsen mwyn",
    "objective.dropTreasures": "Gollwng %d trysor(au) i'r cert mwynglawdd",
    "objective.dropTreasure1": "Gollwng %d trysor i'r cert mwynglawdd",
    "objective.collectGems": "Casglu %d %@(au) (%@)",
    "objective.collectGem1": "Casglu %d %@ (%@)",
    "objective.collectSpecials": "Creu %d %@(au)",
    "objective.collectSpecial1": "Creu %d %@",
    "objective.reachScoreDesc": "Sgoriwch o leiaf %d pwynt drwy gyfateb gemau",
    "objective.clearAllOreDesc": "Cyfatebwch emau ar deilsiau mwyn aur i'w cloddio. Nid yw hwbiau'n cyfrif!",
    "objective.dropTreasuresDesc": "Symudwch %d trysor(au) i'r cert mwynglawdd ar y gwaelod",
    "objective.dropTreasure1Desc": "Symudwch %d trysor i'r cert mwynglawdd ar y gwaelod",
    "objective.collectGemsDesc": "Cyfatebwch a chasglwch %d em %@ (%@)",
    "objective.collectSpecialsDesc": "Crëwch %d em %@(au) drwy gyfatebiadau arbennig",
    "objective.collectSpecial1Desc": "Crëwch %d em %@ drwy gyfatebiad arbennig",
    "objective.reachScoreShort": "%d pnt",
    "objective.clearAllOreShort": "Clirio mwyn",
    "objective.clearAllOreShortColor": "Clirio pob mwyn",
    "objective.dropTreasuresShort": "%d trysor(au)",
    "objective.dropTreasure1Short": "%d trysor",

    // Gem Types (Welsh Minerals)
    "gem.ruby": "Carreg y Ddraig",
    "gem.gold": "Aur Cymru",
    "gem.silver": "Arian",
    "gem.emerald": "Maen Preseli",
    "gem.sapphire": "Llechi",
    "gem.amethyst": "Crisial Ceridwen",
    "gem.hintRed": "coch",
    "gem.hintGold": "aur",
    "gem.hintSilver": "arian",
    "gem.hintGreen": "gwyrdd",
    "gem.hintBlue": "glas",
    "gem.hintPurple": "porffor",

    // Special Types
    "special.normal": "Normal",
    "special.laserH": "Em Laser (Ll)",
    "special.laserV": "Em Laser (F)",
    "special.volatile": "Em Ansefydlog",
    "special.crystalBall": "Pêl Grisial",
    "special.miningDrone": "Drôn Mwyngloddio",

    // Shop Items (Welsh-themed)
    "shopItem.pickaxe3": "Caib y Mwynwr x3",
    "shopItem.pickaxe10": "Caib y Mwynwr x10",
    "shopItem.dynamite1": "Tân Gwyllt",
    "shopItem.dynamite5": "Tân Gwyllt x5",
    "shopItem.drone1": "Cŵn Annwn",
    "shopItem.drone3": "Cŵn Annwn x3",
    "shopItem.forge1": "Pair Ceridwen",
    "shopItem.forge3": "Pair x3",
    "shopItem.cart1": "Rhuthr Rheilffordd",

    // Objective Progress Labels
    "progress.score": "Sgôr",
    "progress.oreCleared": "Mwyn wedi'i glirio",
    "progress.treasures": "Trysorau",

    // Encouragement Messages
    "encourage.almostThere": "Bron yna!",
    "encourage.lastOre": "Gwythïen mwyn olaf!",
    "encourage.oneMoreTreasure": "Un trysor arall!",
    "encourage.gemsLeft": "%d %@ ar ôl!",
    "encourage.oneMoreSpecial": "Un %@ arall!",
    "encourage.movesLeft": "%d symudiad ar ôl!",

    // New Welsh Achievements (Druid Progression)
    "achievement.ovateOfTheMine": "Ofydd y Mwynglawdd",
    "achievement.ovateOfTheMineDesc": "Cyrraedd Maes Glo De Cymru (Lefel 31)",
    "achievement.bardOfTheDeep": "Bardd y Dyfnder",
    "achievement.bardOfTheDeepDesc": "Cyrraedd mwyngloddiau Llechi Llechwedd (Lefel 91)",
    "achievement.druidOfAnnwn": "Derwydd Annwn",
    "achievement.druidOfAnnwnDesc": "Cyrraedd mwyngloddiau aur Rhufeinig Dolaucothi (Lefel 151)",
    "achievement.dragonsFriend": "Cyfaill y Ddraig",
    "achievement.dragonsFriendDesc": "Cwblhewch Ffau'r Ddraig yn Ninas Emrys (Lefel 200)",

    // Mining Zones
    "zone.1.name": "Y Gogarth",
    "zone.1.welsh": "Y Gogarth",
    "zone.1.tagline": "Dyfnderoedd yr Oes Efydd — 4,000 o Flynyddoedd o Gloddio",
    "zone.2.name": "Maes Glo De Cymru",
    "zone.2.welsh": "Maes Glo De Cymru",
    "zone.2.tagline": "Aur Du'r Cymoedd",
    "zone.3.name": "Mynydd Parys",
    "zone.3.welsh": "Mynydd Parys",
    "zone.3.tagline": "Teyrnas Gopr Ynys Môn",
    "zone.4.name": "Llechi Llechwedd",
    "zone.4.welsh": "Llechi Llechwedd",
    "zone.4.tagline": "Ogofâu Cadeiriol o Garreg Las-Lwyd",
    "zone.5.name": "Gwregys Aur Dolgellau",
    "zone.5.welsh": "Gwregys Aur Dolgellau",
    "zone.5.tagline": "Aur Brenhinol Cymru",
    "zone.6.name": "Mwyngloddiau Rhufeinig Dolaucothi",
    "zone.6.welsh": "Mwyngloddiau Rhufeinig Dolaucothi",
    "zone.6.tagline": "Grym Hynafol Dan Dir Sanctaidd",
    "zone.7.name": "Dinas Emrys",
    "zone.7.welsh": "Dinas Emrys — Annwn",
    "zone.7.tagline": "Ffau'r Ddraig — Lle Mae Dau Fyd yn Cwrdd",

    // Zone Transitions
    "zone.1.narrative": "Mae'r Coblynau yn ymddangos yn nhwneli copr hynafol y Gogarth, yn curo i'ch arwain yn ddyfnach...",
    "zone.2.narrative": "Mae ysbrydion y mwynglawdd yn eich arwain tua'r de i'r meysydd glo mawr, lle cerfiodd cenedlaethau o lowyr Cymreig eu hetifeddiaeth.",
    "zone.3.narrative": "Mae'r Coblynau yn sibrwd am Deyrnas y Copr — Mynydd Parys, lle mae'r ddaear yn gwaedu oren a gwyrdd.",
    "zone.4.narrative": "Rydych yn disgyn i siambrau cadeiriol Llechwedd, lle mae llechi las-lwyd yn dal cof yr oesoedd.",
    "zone.5.narrative": "Mae gwythiennau aur yn disgleirio o'ch blaen — mae'r Coblynau'n cynhyrfu. Rydych wedi cyrraedd aur brenhinol Dolgellau.",
    "zone.6.narrative": "Mae twneli Rhufeinig hynafol o'ch cwmpas. Roedd y Derwyddon yn gwarchod y mwyngloddiau hyn. Mae grym Annwn yn agosáu.",
    "zone.7.narrative": "Mae'r ddaear yn crynu. O dan Dinas Emrys, mae llyn tanddaearol yn goleuo'n goch a glas. Mae Y Ddraig Goch yn deffro...",

    // Blocker Display Names
    "blocker.granite": "Llechi",
    "blocker.boulder": "Maen Glas",
    "blocker.lava": "Tân Draig",
    "blocker.amber": "Crisial Awen",
    "blocker.cage": "Cawell Haearn",
    "blocker.tnt": "Ffrwydrad",

    // Zone UI
    "zone.entering": "YN MYND I MEWN",
    "zone.continue": "Parhau",

    // Settings Language
    "settings.langEN": "EN",
    "settings.langCY": "CY",

    // Lore Tips — Zone 1: Y Gogarth
    "lore.zone1.tip0": "Mae mwyngloddiau copr y Gogarth ger Llandudno dros 4,000 o flynyddoedd oed — y mwyngloddiau cynhanesyddol mwyaf yn y byd.",
    "lore.zone1.tip1": "Defnyddiodd mwynwyr yr Oes Efydd ar y Gogarth offer asgwrn a chyrn carw i dynnu copr o dwneli calchfaen.",
    "lore.zone1.tip2": "Mae'r Coblynau yn ysbrydion mwyngloddiau Cymreig — mwynwyr bach mewn dillad bychan sy'n curo ger gwythiennau mwyn cyfoethog.",
    "lore.zone1.tip3": "Mae Cymru wedi'i chloddio'n barhaus ers dros 4,000 o flynyddoedd, o gopr yr Oes Efydd i lo modern.",
    "lore.zone1.tip4": "Mae'r gair Cymraeg 'mwynglawdd' yn golygu mwynglawdd. 'Cloddio' yw calon ein hantur.",

    // Lore Tips — Zone 2: Maes Glo De Cymru
    "lore.zone2.tip0": "Maes Glo De Cymru oedd y mwyaf ym Mhrydain. Erbyn 1913, y Barri oedd porthladd allforio glo mwyaf y byd.",
    "lore.zone2.tip1": "Ganwyd corau meibion Cymreig mewn cymunedau glofaol — ffurfiodd glowyr di-waith gorau a ddaeth yn enwog drwy'r byd.",
    "lore.zone2.tip2": "Gelwir Cymru yn 'Gwlad y Gân'. Mae'r traddodiad canu mor ddwfn â'r gwythiennau glo.",
    "lore.zone2.tip3": "Achubwyd bywydau di-rif gan lamp diogelwch Davy trwy ganfod nwy ffrwydrol mewn mwyngloddiau Cymreig.",
    "lore.zone2.tip4": "Mae cysyniad Cymreig 'hiraeth' — hiraeth dwfn am gartref — yn atseinio gyda chymunedau glofaol ledled y byd.",

    // Lore Tips — Zone 3: Mynydd Parys
    "lore.zone3.tip0": "Mynydd Parys ar Ynys Môn oedd unwaith y mwynglawdd copr mwyaf yn y byd. Mae ei dirwedd fel Mawrth yn syfrdanu ymwelwyr.",
    "lore.zone3.tip1": "Darganfuwyd y mwyn Anglesit am y tro cyntaf ym Mynydd Parys yn 1783 ac fe'i henwyd ar ôl Ynys Môn.",
    "lore.zone3.tip2": "Rheolai Thomas Williams, 'Brenin y Copr,' brisiau copr byd-eang o Fynydd Parys yn y 1780au.",
    "lore.zone3.tip3": "Ynys Môn oedd cadarnle olaf y Derwyddon cyn ymosodiad y Rhufeiniaid yn OC 61.",
    "lore.zone3.tip4": "Mae'r pyllau oren, porffor a gwyrdd llachar ym Mynydd Parys yn cael eu hachosi gan fwynau copr, haearn a sylffwr.",

    // Lore Tips — Zone 4: Llechi Llechwedd
    "lore.zone4.tip0": "Mae Tirwedd Llechi Gogledd Cymru yn Safle Treftadaeth y Byd UNESCO — y diwydiant a doeodd y byd.",
    "lore.zone4.tip1": "Mae Ogofâu Llechi Llechwedd ym Mlaenau Ffestiniog yn cynnwys siambrau tanddaearol fel eglwysi cadeiriol.",
    "lore.zone4.tip2": "Mae llechi Cymreig wedi'u chwarela ers cyfnod y Rhufeiniaid. Penrhyn a Dinorwig oedd y ddwy chwarel lechi fwyaf ar y Ddaear.",
    "lore.zone4.tip3": "Roedd gan y Derwyddon dri urdd: Ofydd (gwyrdd), Bardd (glas), a Derwydd (gwyn) — dilyniant o ddoethineb.",
    "lore.zone4.tip4": "Mae'r triskele Celtaidd — tair troell gydgloi — yn cynrychioli daear, dŵr, ac awyr, tair teyrnas bodolaeth.",

    // Lore Tips — Zone 5: Gwregys Aur Dolgellau
    "lore.zone5.tip0": "Mae aur Cymreig o Ddolgellau wedi'i ddefnyddio ar gyfer modrwyau priodas Brenhinol ers 1923.",
    "lore.zone5.tip1": "Mwynglawdd Aur Clogau ger Dolgellau oedd y cyfoethocaf yng Nghymru, gan gynhyrchu dros 78,000 owns troy o aur.",
    "lore.zone5.tip2": "Mae llwyau caru Cymreig yn docynnau anwyldeb pren cerfiedig — mae gan bob symbol ystyr: calonnau am gariad, allweddi am ymroddiad.",
    "lore.zone5.tip3": "Mae 'Awen' yn golygu ysbrydoliaeth ddwyfol yn Gymraeg — mae tri pelydryn yr Awen yn cynrychioli gwirionedd, gwybodaeth, a barddoniaeth.",
    "lore.zone5.tip4": "Breuodd Pair Ceridwen drwyth yr Awen am flwyddyn a diwrnod — dim ond y tri diferyn cyntaf oedd yn dal ei rym.",

    // Lore Tips — Zone 6: Dolaucothi
    "lore.zone6.tip0": "Dolaucothi yw'r unig fwynglawdd aur Rhufeinig hysbys ym Mhrydain, a weithredwyd o tua OC 74 am dros ddwy ganrif.",
    "lore.zone6.tip1": "Mae'r Mabinogion yn cynnwys y chwedlau rhyddiaith Cymreig cynharaf — straeon Pwyll, Branwen, a'r pair hudol o aileni.",
    "lore.zone6.tip2": "Yn y Mabinogion, mae Arawn yn rheoli Annwn — Isfyd Cymreig, teynas o ddigonedd o dan y ddaear.",
    "lore.zone6.tip3": "Cludwyd Cerrig Gleision Preseli o Sir Benfro 150 milltir i adeiladu Côr y Cewri — yn cysylltu carreg Gymreig â grym sanctaidd.",
    "lore.zone6.tip4": "Dywedir bod Myrddin wedi'i eni yng Nghaerfyrddin — sef 'Caer Myrddin' yn Gymraeg.",

    // Lore Tips — Zone 7: Dinas Emrys / Annwn
    "lore.zone7.tip0": "O dan Dinas Emrys yn Eryri, mae dwy ddraig yn cysgu mewn llyn tanddaearol — un goch, un wen.",
    "lore.zone7.tip1": "Datgelodd y Myrddin ifanc y dreigiau i'r Brenin Gwrtheyrn, gan broffwydo y byddai Y Ddraig Goch yn gorchfygu.",
    "lore.zone7.tip2": "Mae Annwn, Isfyd Cymreig, yn golygu 'dwfn iawn.' Nid lle tywyll ydyw — paradwys o ieuenctid tragwyddol a digonedd.",
    "lore.zone7.tip3": "Mae Cŵn Annwn yn gŵn hela ysbrydol gwyn â chlustiau coch sy'n hela rhwng bydoedd, dan arweiniad Gwyn ap Nudd.",
    "lore.zone7.tip4": "Mae Y Ddraig Goch wedi bod yn symbol Cymru ers dros 1,500 o flynyddoedd — dewrder, her, a dyfalbarhad ar ffurf.",

    // Zone-Specific Victory Text
    "victory.zone1": "Mae'r copr hynafol yn ildio'i drysor",
    "victory.zone2": "Mae aur du'r cymoedd yn disgleirio",
    "victory.zone3": "Mae Teyrnas y Copr yn datgelu'i chyfrinachau",
    "victory.zone4": "Mae cadeirlan y llechi yn atsain eich buddugoliaeth",
    "victory.zone5": "Mae aur brenhinol Cymru yn disgleirio yn eich dwylo",
    "victory.zone6": "Mae gwythiennau Rhufeinig hynafol yn rhedeg yn wir",
    "victory.zone7": "Mae'r ddraig yn deffro yn y dyfnder",

    // Tooltip Hints — Blockers
    "tooltip.granite": "Llechi (%d haen%@) — Matshiwch wrth ei ymyl i'w gracio",
    "tooltip.granite.s": "au",
    "tooltip.boulder": "Maen Glas — Matshiwch wrth ei ymyl i'w symud",
    "tooltip.cage": "Gem mewn Cawell — Matshiwch y gem i'w rhyddhau",
    "tooltip.lava": "Tân Draig — Yn lledu bob tro! Matshiwch wrth ei ymyl",
    "tooltip.tnt": "Ffrwydrad (%d symudiad) — Cliriwch cyn iddo ffrwydro!",
    "tooltip.amber": "Crisial Awen — Matshiwch wrth ei ymyl i'w dorri'n rhydd",

    // Tooltip Hints — Ore
    "tooltip.oreVein": "Gwythïen Mwyn — Matshiwch emau yma i'w gloddio",
    "tooltip.doubleOre": "Mwyn Trwchus — Matshiwch yma ddwywaith i'w gloddio",

    // Tooltip Hints — Special Gems
    "tooltip.laserH": "Gem Laser — Yn clirio'r rhes gyfan",
    "tooltip.laserV": "Gem Laser — Yn clirio'r golofn gyfan",
    "tooltip.volatile": "Gem Ffrwydrol — Yn ffrwydro ardal 3×3",
    "tooltip.crystalBall": "Pelen Grisial — Cyfnewidiwch i ddileu un lliw i gyd",
    "tooltip.miningDrone": "Drôn Mwyngloddio — Yn anfon 3 chwiliwr i glirio targedau",

    // HUD Labels
    "hud.score": "SGÔR",
    "hud.moves": "SYMUDIADAU",

    // Game Banners
    "game.levelComplete": "Lefel Wedi'i Chwblhau!",
    "game.outOfMoves": "Dim Symudiadau ar ôl!",
    "game.reshuffling": "Yn Ailgymysgu...",

    // Objective Display
    "objective.scoreDisplay": "Sgôr: %d/%d",
    "objective.oreDisplay": "Mwyn: %d/%d",
    "objective.treasureDisplay": "Trysor: %d/%d",

]
