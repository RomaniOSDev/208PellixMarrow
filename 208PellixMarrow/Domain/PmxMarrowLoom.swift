import CoreGraphics
import Foundation

struct PmxMarrowBar: Identifiable, Equatable {
    let id: String
    let label: String
    let amount: Int
}

struct PmxFeltStitch {
    let start: CGPoint
    let end: CGPoint
}

enum PmxMarrowLoom {
    static func index(nights: Int, rules: Int, streak: Int, games: Int) -> Int {
        let weighted = nights * 3 + rules * 2 + streak * 4 + min(games, 12)
        return min(100, weighted)
    }

    static func weekBars(from rows: [(label: String, nights: Int)]) -> [PmxMarrowBar] {
        rows.enumerated().map { offset, row in
            PmxMarrowBar(id: "week-\(offset)-\(row.label)", label: row.label, amount: row.nights)
        }
    }

    static func gameBars(from nights: [PmxNightSlate]) -> [PmxMarrowBar] {
        var counts: [String: Int] = [:]
        for night in nights {
            let title = night.gameTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { continue }
            counts[title, default: 0] += 1
        }
        let ranked = counts.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        let bars = ranked.prefix(6).map { PmxMarrowBar(id: "game-\($0.key)", label: $0.key, amount: $0.value) }
        return bars.isEmpty ? [PmxMarrowBar(id: "game-empty", label: "No pads", amount: 0)] : bars
    }

    static func leadBars(from nights: [PmxNightSlate]) -> [PmxMarrowBar] {
        var counts: [String: Int] = [:]
        for night in nights {
            let name = PmxTallyMath.leader(for: night)
            guard name != "No seats yet" else { continue }
            counts[name, default: 0] += 1
        }
        let ranked = counts.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        let bars = ranked.prefix(6).map { PmxMarrowBar(id: "lead-\($0.key)", label: $0.key, amount: $0.value) }
        return bars.isEmpty ? [PmxMarrowBar(id: "lead-empty", label: "No leads", amount: 0)] : bars
    }

    static func stitches(width: CGFloat, height: CGFloat) -> [PmxFeltStitch] {
        guard width > 1, height > 1 else { return [] }
        let step: CGFloat = 28
        var lines: [PmxFeltStitch] = []
        var cursor: CGFloat = -height
        var salt = 3
        while cursor < width + height {
            let wobble = CGFloat((salt * 17) % 7) - 3
            lines.append(PmxFeltStitch(
                start: CGPoint(x: cursor + wobble, y: 0),
                end: CGPoint(x: cursor - height + wobble, y: height)
            ))
            salt = (salt * 5 + 11) % 97
            cursor += step
        }
        return lines
    }
}
