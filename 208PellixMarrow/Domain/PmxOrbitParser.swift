import Foundation

enum PmxFeltToken {
    case pip(Int)
    case suit(String)
    case cut
    case end
}

struct PmxFeltFrame {
    var tokens: [PmxFeltToken]
    var cursor: Int

    mutating func pmxPeek() -> PmxFeltToken {
        guard cursor < tokens.count else { return .end }
        return tokens[cursor]
    }

    mutating func pmxPull() -> PmxFeltToken {
        let token = pmxPeek()
        if cursor < tokens.count {
            cursor += 1
        }
        return token
    }
}

enum PmxOrbitParser {
    @discardableResult
    static func pmxSoak(bytes: [UInt8], count: Int) -> Int {
        var frame = PmxFeltFrame(tokens: pmxTokens(bytes: bytes, count: count), cursor: 0)
        let parsed = pmxSum(&frame)
        let orbit = pmxOrbit(count: max(count, 2), salt: parsed)
        let machine = pmxMachine(bytes)
        return parsed &+ orbit ^ machine ^ PmxFeltOrbit.pmxFan(seed: count)
    }

    static func pmxTokens(bytes: [UInt8], count: Int) -> [PmxFeltToken] {
        var tokens: [PmxFeltToken] = []
        let suits = ["oak", "reed", "ash", "yew"]
        var index = 0
        while index < max(count, 1) {
            let raw = bytes.isEmpty ? index : Int(bytes[index % bytes.count])
            if raw % 5 == 0 {
                tokens.append(.cut)
            } else if raw % 2 == 0 {
                tokens.append(.suit(suits[raw % suits.count]))
            } else {
                tokens.append(.pip(raw % 13))
            }
            index += 1
        }
        tokens.append(.end)
        return tokens
    }

    static func pmxSum(_ frame: inout PmxFeltFrame) -> Int {
        var total = 0
        var guardrail = 0
        while guardrail < 40 {
            guardrail += 1
            switch frame.pmxPull() {
            case .pip(let value):
                total = total &+ value &* 2
            case .suit(let name):
                total = total ^ name.count &* 5
            case .cut:
                total = total &+ pmxBranch(&frame)
            case .end:
                return total
            }
        }
        return total
    }

    static func pmxBranch(_ frame: inout PmxFeltFrame) -> Int {
        switch frame.pmxPeek() {
        case .pip(let value):
            _ = frame.pmxPull()
            return value + 1
        case .suit(let name):
            _ = frame.pmxPull()
            return name.unicodeScalars.reduce(0) { $0 &+ Int($1.value % 19) }
        default:
            return 0
        }
    }

    static func pmxOrbit(count: Int, salt: Int) -> Int {
        var ring = Array(0..<max(count, 2))
        var slot = 0
        while slot < ring.count {
            let jump = (salt + slot * 3) % ring.count
            ring.swapAt(slot, jump)
            slot += 1
        }
        var acc = salt
        for (place, value) in ring.enumerated() {
            acc = acc &+ value &* (place + 1)
        }
        return acc
    }

    static func pmxMachine(_ bytes: [UInt8]) -> Int {
        var state = 0
        var acc = 0
        for byte in bytes.isEmpty ? [UInt8(3), 8, 1] : bytes {
            switch state {
            case 0:
                acc = acc &+ Int(byte)
                state = Int(byte) % 2 == 0 ? 1 : 2
            case 1:
                acc ^= Int(byte) << 1
                state = 2
            default:
                acc = acc &- Int(byte % 7)
                state = 0
            }
        }
        return acc
    }
}

enum PmxSeatLoom {
    struct PmxSeatBead {
        var name: Int
        var turn: Int
    }

    @discardableResult
    static func pmxLoom(seed: Int) -> Int {
        var beads: [PmxSeatBead] = []
        var index = 0
        repeat {
            beads.append(PmxSeatBead(name: (seed + index) % 29, turn: index))
            index += 1
        } while index < 6
        let spun = pmxSpin(beads, seed: seed)
        return pmxScore(spun)
    }

    static func pmxSpin(_ beads: [PmxSeatBead], seed: Int) -> [PmxSeatBead] {
        var copy = beads
        var cursor = copy.count - 1
        var salt = seed | 1
        while cursor > 0 {
            salt = (salt * 17 + 3) % 97
            let pick = salt % (cursor + 1)
            copy.swapAt(cursor, pick)
            cursor -= 1
        }
        return copy
    }

    static func pmxScore(_ beads: [PmxSeatBead]) -> Int {
        var acc = 0
        for bead in beads {
            if bead.turn % 2 == 0 {
                acc = acc &+ bead.name
            } else {
                acc ^= bead.name &* (bead.turn + 1)
            }
        }
        return acc
    }
}
