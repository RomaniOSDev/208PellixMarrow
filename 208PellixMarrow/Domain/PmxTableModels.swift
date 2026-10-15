import Foundation

struct PmxShelfGame: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var playerSpan: String
    var minuteHint: Int
    var kindTag: String
    var blurb: String
}

struct PmxSeat: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var displayName: String
    var aside: String

    init(id: UUID, displayName: String, aside: String = "") {
        self.id = id
        self.displayName = displayName
        self.aside = aside
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        id = try box.decode(UUID.self, forKey: .id)
        displayName = try box.decode(String.self, forKey: .displayName)
        aside = try box.decodeIfPresent(String.self, forKey: .aside) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var box = encoder.container(keyedBy: CodingKeys.self)
        try box.encode(id, forKey: .id)
        try box.encode(displayName, forKey: .displayName)
        try box.encode(aside, forKey: .aside)
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayName, aside
    }
}

struct PmxTallyCell: Identifiable, Codable, Equatable {
    var id: UUID
    var tally: Int
}

struct PmxRoundMark: Identifiable, Codable, Equatable {
    var id: UUID
    var label: String
    var cells: [PmxTallyCell]
}

struct PmxNightSlate: Identifiable, Codable, Equatable {
    var id: UUID
    var eveningTitle: String
    var heldOn: Date
    var gameTitle: String
    var seats: [PmxSeat]
    var rounds: [PmxRoundMark]
    var houseNote: String
    var lowerLeads: Bool
}

struct PmxHouseRule: Identifiable, Codable, Equatable {
    var id: UUID
    var gameTitle: String
    var ruleText: String
}

enum PmxKindRibbon {
    static let tags = ["Cards", "Dice", "Words", "Coop", "Party"]
}

enum PmxOpenerReel {
    static let lines = [
        "Ask each seat for one house rule to try tonight.",
        "Let the newest seat choose the first game.",
        "Play one short round before a longer one.",
        "Write the seating before the first tally.",
        "Keep one line about a moment you want to remember.",
        "Swap two seats if the table feels stuck.",
        "Close the night with a single recap line."
    ]

    static func line(for date: Date) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return lines[day % lines.count]
    }
}

enum PmxDayStamp {
    private static let origin: Date = {
        var parts = DateComponents()
        parts.calendar = Calendar(identifier: .gregorian)
        parts.year = 2020
        parts.month = 1
        parts.day = 1
        return parts.date ?? Date(timeIntervalSince1970: 0)
    }()

    static func ordinal(_ date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.startOfDay(for: origin)
        let day = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: day).day ?? 0
    }

    static func key(_ date: Date) -> String {
        String(ordinal(date))
    }

    static func shortWeekday(_ date: Date) -> String {
        let names = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        let index = Calendar(identifier: .gregorian).component(.weekday, from: date) - 1
        guard names.indices.contains(index) else { return "" }
        return names[index]
    }

    static func medium(_ date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0) \(parts.hour ?? 0):\(String(format: "%02d", parts.minute ?? 0))"
    }
}

enum PmxTallyMath {
    static func totals(for night: PmxNightSlate) -> [(PmxSeat, Int)] {
        night.seats.map { seat in
            let sum = night.rounds.reduce(0) { partial, round in
                partial + (round.cells.first { $0.id == seat.id }?.tally ?? 0)
            }
            return (seat, sum)
        }
    }

    static func leader(for night: PmxNightSlate) -> String {
        let rows = totals(for: night)
        guard !rows.isEmpty else { return "No seats yet" }
        if night.lowerLeads {
            return rows.min { $0.1 < $1.1 }?.0.displayName ?? "No seats yet"
        }
        return rows.max { $0.1 < $1.1 }?.0.displayName ?? "No seats yet"
    }
}

enum PmxChooser {
    static func name(from nights: [PmxNightSlate], on date: Date = Date()) -> String? {
        let ordered = nights.sorted { $0.heldOn < $1.heldOn }
        var seen: [String] = []
        var lastWin: [String: Int] = [:]
        for (index, night) in ordered.enumerated() {
            for seat in night.seats {
                let name = seat.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty, !seen.contains(name) else { continue }
                seen.append(name)
            }
            let lead = PmxTallyMath.leader(for: night)
            guard lead != "No seats yet" else { continue }
            lastWin[lead] = index
        }
        guard !seen.isEmpty else { return nil }
        let ranked = seen.sorted { lhs, rhs in
            switch (lastWin[lhs], lastWin[rhs]) {
            case (nil, nil):
                return lhs < rhs
            case (nil, _):
                return true
            case (_, nil):
                return false
            case let (left?, right?):
                return left == right ? lhs < rhs : left < right
            }
        }
        let drought = lastWin[ranked[0]]
        let tied = ranked.filter { lastWin[$0] == drought }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return tied[day % tied.count]
    }

    static func eveningRule(from rules: [PmxHouseRule], nights: [PmxNightSlate], on date: Date = Date()) -> PmxHouseRule? {
        let savedToday = nights.contains { Calendar.current.isDateInToday($0.heldOn) }
        guard !savedToday else { return nil }
        let lastGame = nights.max { $0.heldOn < $1.heldOn }?.gameTitle ?? ""
        let matched = rules.filter { $0.gameTitle.caseInsensitiveCompare(lastGame) == .orderedSame }
        let pool = matched.isEmpty ? rules : matched
        guard !pool.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return pool[day % pool.count]
    }
}
