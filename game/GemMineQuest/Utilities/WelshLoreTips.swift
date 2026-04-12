import Foundation

/// Welsh folklore, history, and culture tips displayed before levels and during zone transitions.
/// Each zone has 5 rotating tips that cycle as the player progresses through levels in that zone.
enum WelshLoreTips {

    /// Returns a lore tip for the given level number.
    static func tip(for level: Int) -> String {
        let zone = MiningZone.zone(for: level)
        let tips = zoneTips[zone.rawValue] ?? []
        guard !tips.isEmpty else { return "" }
        let index = (level - zone.firstLevel) % tips.count
        return tips[index]
    }

    /// Returns all tips for a given zone.
    static func tips(for zone: MiningZone) -> [String] {
        return zoneTips[zone.rawValue] ?? []
    }

    // MARK: - Zone Tips

    private static let zoneTips: [Int: [String]] = [
        // Zone 1: Great Orme (Bronze Age copper)
        MiningZone.greatOrme.rawValue: [
            "The Great Orme copper mines near Llandudno are over 4,000 years old — the largest prehistoric mines in the world.",
            "Bronze Age miners at the Great Orme used bone and antler tools to extract copper from limestone tunnels.",
            "The Coblynau are Welsh mine spirits — tiny miners dressed in miniature clothing who knock near rich ore veins.",
            "Wales has been mined continuously for over 4,000 years, from Bronze Age copper to modern-day coal.",
            "The Welsh word 'mwynglawdd' means mine. 'Cloddio' means to dig — the heart of our quest.",
        ],

        // Zone 2: South Wales Coalfields
        MiningZone.southWalesCoalfields.rawValue: [
            "The South Wales Coalfield was the largest in Britain. By 1913, Barry was the world's largest coal-exporting port.",
            "Welsh male voice choirs were born in mining communities — unemployed miners formed choirs that became world-famous.",
            "Wales is called 'Gwlad y Gân' — Land of Song. The singing tradition runs as deep as the coal seams.",
            "A Davy safety lamp saved countless lives in Welsh mines by detecting explosive firedamp gas underground.",
            "The Welsh concept of 'hiraeth' — a deep longing for home — resonates with mining communities scattered across the world.",
        ],

        // Zone 3: Parys Mountain (copper)
        MiningZone.parysMountain.rawValue: [
            "Parys Mountain on Anglesey was once the largest copper mine in the world. Its Mars-like landscape still astonishes visitors.",
            "The mineral Anglesite was first discovered at Parys Mountain in 1783 and named after the island of Anglesey.",
            "Thomas Williams, the 'Copper King,' controlled global copper prices from Parys Mountain in the 1780s.",
            "Anglesey — Ynys Môn in Welsh — was the last stronghold of the Druids before the Roman invasion in AD 61.",
            "The vivid orange, purple, and green pools at Parys Mountain are caused by copper, iron, and sulfur minerals.",
        ],

        // Zone 4: Llechwedd Slate
        MiningZone.llechweddSlate.rawValue: [
            "The North Wales Slate Landscape is a UNESCO World Heritage Site — the industry that roofed the world.",
            "Llechwedd Slate Caverns at Blaenau Ffestiniog contain cathedral-like underground chambers carved by quarrymen.",
            "Welsh slate has been quarried since Roman times. Penrhyn and Dinorwic were the two largest slate quarries on Earth.",
            "The Druids had three orders: Ovate (green robes), Bard (blue robes), and Druid (white robes) — a progression of wisdom.",
            "The Celtic triskele — three interlocking spirals — represents earth, water, and sky, the three realms of existence.",
        ],

        // Zone 5: Dolgellau Gold Belt
        MiningZone.dolgellauGold.rawValue: [
            "Welsh gold from Dolgellau has been used for Royal wedding rings since the Queen Mother's in 1923.",
            "The Clogau Gold Mine near Dolgellau was the richest in Wales, producing over 78,000 troy ounces of gold.",
            "Welsh love spoons are carved wooden tokens of affection — each symbol has meaning: hearts for love, keys for devotion.",
            "'Awen' means divine inspiration in Welsh — the three rays of the Awen symbol represent truth, knowledge, and poetry.",
            "Ceridwen's Cauldron brewed the potion of Awen for a year and a day — only the first three drops held its power.",
        ],

        // Zone 6: Dolaucothi Roman Mines
        MiningZone.dolaucothiRoman.rawValue: [
            "Dolaucothi is the only known Roman gold mine in Britain, operated from around AD 74 for over two centuries.",
            "The Mabinogion contains the earliest Welsh prose tales — stories of Pwyll, Branwen, and the magical cauldron of rebirth.",
            "In the Mabinogion, Arawn rules Annwn — the Welsh Otherworld, a realm of abundance beneath the earth.",
            "The Preseli Bluestones of Pembrokeshire were transported 150 miles to build Stonehenge — connecting Welsh stone to sacred power.",
            "Myrddin (Merlin) was said to be born in Carmarthen — Caerfyrddin in Welsh, meaning 'Merlin's Fort.'",
        ],

        // Zone 7: Dinas Emrys / Annwn
        MiningZone.dinasEmrys.rawValue: [
            "Beneath Dinas Emrys in Snowdonia, two dragons sleep in an underground lake — one red, one white.",
            "Young Merlin revealed the dragons to King Vortigern, prophesying that Y Ddraig Goch — the Red Dragon — would triumph.",
            "Annwn, the Welsh Otherworld, means 'very deep.' It is not a dark place — it is a paradise of eternal youth and abundance.",
            "The Cwn Annwn are spectral white hounds with red ears who hunt between worlds, guided by Gwyn ap Nudd.",
            "Y Ddraig Goch has been the symbol of Wales for over 1,500 years — courage, defiance, and endurance given form.",
        ],
    ]
}
