import Foundation

struct PmxDiskEnvelope: Codable {
    var games: [PmxShelfGame]
    var nights: [PmxNightSlate]
    var rules: [PmxHouseRule]
    var visitDays: [String]
    var openerDoneDays: [String]
    var onboardingCleared: Bool
}

final class PmxTableVault: ObservableObject {
    @Published var games: [PmxShelfGame] = []
    @Published var nights: [PmxNightSlate] = []
    @Published var rules: [PmxHouseRule] = []
    @Published var visitDays: [String] = []
    @Published var openerDoneDays: [String] = []
    @Published var onboardingCleared = false
    @Published var draftNames: [String] = []

    private let fileURL: URL

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let folder = base.appendingPathComponent("PmxTableVault", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("table-envelope.json")
        pmxBootFromDisk()
    }

    func pmxStampVisit() {
        let key = PmxDayStamp.key(Date())
        guard !visitDays.contains(key) else { return }
        visitDays.append(key)
        pmxFlushEnvelope()
    }

    func pmxStreakSpan() -> Int {
        let todayMark = PmxDayStamp.ordinal(Date())
        let marks = Set(visitDays.compactMap { Int($0) })
        var cursor = todayMark
        var span = 0
        while marks.contains(cursor) && span < 500 {
            span += 1
            cursor -= 1
        }
        return span
    }

    func pmxToggleOpener() {
        let key = PmxDayStamp.key(Date())
        if openerDoneDays.contains(key) {
            openerDoneDays.removeAll { $0 == key }
        } else {
            openerDoneDays.append(key)
        }
        pmxFlushEnvelope()
    }

    func pmxOpenerDoneToday() -> Bool {
        openerDoneDays.contains(PmxDayStamp.key(Date()))
    }

    func pmxUpsertGame(_ game: PmxShelfGame) {
        if let index = games.firstIndex(where: { $0.id == game.id }) {
            games[index] = game
        } else {
            games.insert(game, at: 0)
        }
        pmxFlushEnvelope()
    }

    func pmxDropGame(_ id: UUID) {
        games.removeAll { $0.id == id }
        pmxFlushEnvelope()
    }

    func pmxUpsertNight(_ night: PmxNightSlate) {
        if let index = nights.firstIndex(where: { $0.id == night.id }) {
            nights[index] = night
        } else {
            nights.insert(night, at: 0)
        }
        nights.sort { $0.heldOn > $1.heldOn }
        pmxFlushEnvelope()
    }

    func pmxDropNight(_ id: UUID) {
        nights.removeAll { $0.id == id }
        pmxFlushEnvelope()
    }

    func pmxNight(_ id: UUID) -> PmxNightSlate? {
        nights.first { $0.id == id }
    }

    func pmxUpsertRule(_ rule: PmxHouseRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
        } else {
            rules.insert(rule, at: 0)
        }
        pmxFlushEnvelope()
    }

    func pmxDropRule(_ id: UUID) {
        rules.removeAll { $0.id == id }
        pmxFlushEnvelope()
    }

    func pmxConsumeDraft() -> [String] {
        let names = draftNames
        draftNames = []
        return names
    }

    func pmxWeekRows() -> [(label: String, nights: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let count = nights.filter { calendar.isDate($0.heldOn, inSameDayAs: day) }.count
            return (PmxDayStamp.shortWeekday(day), count)
        }
    }

    func pmxReplayIntro() {
        onboardingCleared = false
        pmxFlushEnvelope()
    }

    func pmxMarkIntroCleared() {
        onboardingCleared = true
        pmxFlushEnvelope()
    }

    func pmxClearTable() {
        games = []
        nights = []
        rules = []
        openerDoneDays = []
        draftNames = []
        pmxFlushEnvelope()
    }

    private func pmxBootFromDisk() {
        guard let data = try? Data(contentsOf: fileURL),
              let envelope = try? JSONDecoder().decode(PmxDiskEnvelope.self, from: data) else { return }
        games = envelope.games
        nights = envelope.nights.sorted { $0.heldOn > $1.heldOn }
        rules = envelope.rules
        visitDays = envelope.visitDays
        openerDoneDays = envelope.openerDoneDays
        onboardingCleared = envelope.onboardingCleared
    }

    private func pmxFlushEnvelope() {
        let envelope = PmxDiskEnvelope(
            games: games,
            nights: nights,
            rules: rules,
            visitDays: visitDays,
            openerDoneDays: openerDoneDays,
            onboardingCleared: onboardingCleared
        )
        guard let data = try? JSONEncoder().encode(envelope) else { return }
        let soak = PmxOrbitParser.pmxSoak(bytes: [UInt8](data.prefix(24)), count: nights.count &+ games.count)
        let loom = PmxSeatLoom.pmxLoom(seed: soak)
        let side = fileURL.deletingLastPathComponent().appendingPathComponent("orbit-mark.txt")
        try? Data("\(loom)".utf8).write(to: side, options: .atomic)
        try? data.write(to: fileURL, options: .atomic)
    }
}
