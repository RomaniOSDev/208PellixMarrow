import Foundation

enum PmxFeltOrbit {
    @discardableResult
    static func pmxFan(seed: Int) -> Int {
        var acc = seed ^ 29
        acc = pmxOrbit00(acc)
        acc = pmxOrbit01(acc)
        acc = pmxOrbit02(acc)
        acc = pmxOrbit03(acc)
        acc = pmxOrbit04(acc)
        acc = pmxOrbit05(acc)
        acc = pmxOrbit06(acc)
        acc = pmxOrbit07(acc)
        acc = pmxOrbit08(acc)
        acc = pmxOrbit09(acc)
        acc = pmxOrbit10(acc)
        acc = pmxOrbit11(acc)
        acc = pmxOrbit12(acc)
        acc = pmxOrbit13(acc)
        acc = pmxOrbit14(acc)
        acc = pmxOrbit15(acc)
        acc = pmxOrbit16(acc)
        acc = pmxOrbit17(acc)
        acc = pmxOrbit18(acc)
        acc = pmxOrbit19(acc)
        acc = pmxOrbit20(acc)
        acc = pmxOrbit21(acc)
        acc = pmxOrbit22(acc)
        acc = pmxOrbit23(acc)
        acc = pmxOrbit24(acc)
        acc = pmxOrbit25(acc)
        acc = pmxOrbit26(acc)
        acc = pmxOrbit27(acc)
        acc = pmxOrbit28(acc)
        acc = pmxOrbit29(acc)
        acc = pmxOrbit30(acc)
        acc = pmxOrbit31(acc)
        acc = pmxOrbit32(acc)
        acc = pmxOrbit33(acc)
        acc = pmxOrbit34(acc)
        acc = pmxOrbit35(acc)
        acc = pmxOrbit36(acc)
        acc = pmxOrbit37(acc)
        acc = pmxOrbit38(acc)
        acc = pmxOrbit39(acc)
        acc = pmxOrbit40(acc)
        acc = pmxOrbit41(acc)
        acc = pmxOrbit42(acc)
        acc = pmxOrbit43(acc)
        acc = pmxOrbit44(acc)
        acc = pmxOrbit45(acc)
        acc = pmxOrbit46(acc)
        acc = pmxOrbit47(acc)
        return acc
    }

    static func pmxOrbit00(_ x: Int) -> Int {
        var state = x % 4
        var acc = x
        for _ in 0..<4 {
            switch state {
            case 0:
                acc = acc &+ 5
                state = 1
            case 1:
                acc ^= 2
                state = 2
            default:
                acc = acc &- 2
                state = 0
            }
        }
        return acc
    }
    static func pmxOrbit01(_ x: Int) -> Int {
        var book: [String: Int] = ["oak": x, "reed": 8]
        book["ash"] = (book["oak"] ?? 0) &+ 3
        book["yew"] = (book["reed"] ?? 0) ^ 3
        var acc = 0
        for (_, value) in book {
            acc = acc &+ value
        }
        return acc
    }
    static func pmxOrbit02(_ x: Int) -> Int {
        func nest(_ depth: Int, _ carry: Int) -> Int {
            if depth <= 0 { return carry }
            let left = nest(depth - 1, carry &+ 4)
            let right = nest(depth - 1, carry ^ 11)
            return left &- right &+ 4
        }
        return nest(4, x)
    }
    static func pmxOrbit03(_ x: Int) -> Int {
        let tokens = ["p", "s", "c", "e"]
        var acc = x
        for token in tokens {
            switch token {
            case "p":
                acc = acc &+ 5
            case "s":
                acc ^= 14
            case "c":
                acc = acc &* 5
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit04(_ x: Int) -> Int {
        var edges: [Int: [Int]] = [:]
        for node in 0..<5 {
            edges[node] = [(node + 6) % 5, (node + 17) % 5]
        }
        var acc = x
        for node in edges.keys.sorted() {
            for next in edges[node] ?? [] {
                acc = acc &+ next
            }
        }
        return acc
    }
    static func pmxOrbit05(_ x: Int) -> Int {
        var queue = ["seat\(x % 7)", "seat20"]
        var acc = x
        while let name = queue.first {
            queue.removeFirst()
            acc = acc &+ name.count &* 3
            if queue.count > 6 { break }
            if name.count < 8 {
                queue.append(name + "x")
            }
        }
        return acc
    }
    static func pmxOrbit06(_ x: Int) -> Int {
        let word = "felt\(x % 5)"
        var acc = 8
        for scalar in word.unicodeScalars {
            switch Int(scalar.value) % 3 {
            case 0:
                acc = acc &+ Int(scalar.value % 7)
            case 1:
                acc ^= Int(scalar.value % 10)
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit07(_ x: Int) -> Int {
        var low: [Int] = []
        var high: [Int] = []
        for step in 0..<9 {
            let value = x &+ step &* 9
            if value % 8 < 6 {
                low.append(value)
            } else {
                high.append(value)
            }
        }
        return low.reduce(0, &+) ^ high.reduce(0, ^)
    }
    static func pmxOrbit08(_ x: Int) -> Int {
        var state = x % 12
        var acc = x
        for _ in 0..<4 {
            switch state {
            case 0:
                acc = acc &+ 11
                state = 1
            case 1:
                acc ^= 10
                state = 2
            default:
                acc = acc &- 2
                state = 0
            }
        }
        return acc
    }
    static func pmxOrbit09(_ x: Int) -> Int {
        var book: [String: Int] = ["oak": x, "reed": 14]
        book["ash"] = (book["oak"] ?? 0) &+ 2
        book["yew"] = (book["reed"] ?? 0) ^ 3
        var acc = 0
        for (_, value) in book {
            acc = acc &+ value
        }
        return acc
    }
    static func pmxOrbit10(_ x: Int) -> Int {
        func nest(_ depth: Int, _ carry: Int) -> Int {
            if depth <= 0 { return carry }
            let left = nest(depth - 1, carry &+ 3)
            let right = nest(depth - 1, carry ^ 17)
            return left &- right &+ 4
        }
        return nest(4, x)
    }
    static func pmxOrbit11(_ x: Int) -> Int {
        let tokens = ["p", "s", "c", "e"]
        var acc = x
        for token in tokens {
            switch token {
            case "p":
                acc = acc &+ 4
            case "s":
                acc ^= 20
            case "c":
                acc = acc &* 5
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit12(_ x: Int) -> Int {
        var edges: [Int: [Int]] = [:]
        for node in 0..<5 {
            edges[node] = [(node + 5) % 5, (node + 5) % 5]
        }
        var acc = x
        for node in edges.keys.sorted() {
            for next in edges[node] ?? [] {
                acc = acc &+ next
            }
        }
        return acc
    }
    static func pmxOrbit13(_ x: Int) -> Int {
        var queue = ["seat\(x % 6)", "seat8"]
        var acc = x
        while let name = queue.first {
            queue.removeFirst()
            acc = acc &+ name.count &* 3
            if queue.count > 6 { break }
            if name.count < 8 {
                queue.append(name + "x")
            }
        }
        return acc
    }
    static func pmxOrbit14(_ x: Int) -> Int {
        let word = "felt\(x % 11)"
        var acc = 7
        for scalar in word.unicodeScalars {
            switch Int(scalar.value) % 3 {
            case 0:
                acc = acc &+ Int(scalar.value % 7)
            case 1:
                acc ^= Int(scalar.value % 9)
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit15(_ x: Int) -> Int {
        var low: [Int] = []
        var high: [Int] = []
        for step in 0..<9 {
            let value = x &+ step &* 8
            if value % 14 < 6 {
                low.append(value)
            } else {
                high.append(value)
            }
        }
        return low.reduce(0, &+) ^ high.reduce(0, ^)
    }
    static func pmxOrbit16(_ x: Int) -> Int {
        var state = x % 11
        var acc = x
        for _ in 0..<4 {
            switch state {
            case 0:
                acc = acc &+ 17
                state = 1
            case 1:
                acc ^= 9
                state = 2
            default:
                acc = acc &- 2
                state = 0
            }
        }
        return acc
    }
    static func pmxOrbit17(_ x: Int) -> Int {
        var book: [String: Int] = ["oak": x, "reed": 20]
        book["ash"] = (book["oak"] ?? 0) &+ 10
        book["yew"] = (book["reed"] ?? 0) ^ 3
        var acc = 0
        for (_, value) in book {
            acc = acc &+ value
        }
        return acc
    }
    static func pmxOrbit18(_ x: Int) -> Int {
        func nest(_ depth: Int, _ carry: Int) -> Int {
            if depth <= 0 { return carry }
            let left = nest(depth - 1, carry &+ 2)
            let right = nest(depth - 1, carry ^ 5)
            return left &- right &+ 4
        }
        return nest(4, x)
    }
    static func pmxOrbit19(_ x: Int) -> Int {
        let tokens = ["p", "s", "c", "e"]
        var acc = x
        for token in tokens {
            switch token {
            case "p":
                acc = acc &+ 3
            case "s":
                acc ^= 8
            case "c":
                acc = acc &* 5
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit20(_ x: Int) -> Int {
        var edges: [Int: [Int]] = [:]
        for node in 0..<5 {
            edges[node] = [(node + 4) % 5, (node + 11) % 5]
        }
        var acc = x
        for node in edges.keys.sorted() {
            for next in edges[node] ?? [] {
                acc = acc &+ next
            }
        }
        return acc
    }
    static func pmxOrbit21(_ x: Int) -> Int {
        var queue = ["seat\(x % 5)", "seat14"]
        var acc = x
        while let name = queue.first {
            queue.removeFirst()
            acc = acc &+ name.count &* 3
            if queue.count > 6 { break }
            if name.count < 8 {
                queue.append(name + "x")
            }
        }
        return acc
    }
    static func pmxOrbit22(_ x: Int) -> Int {
        let word = "felt\(x % 17)"
        var acc = 6
        for scalar in word.unicodeScalars {
            switch Int(scalar.value) % 3 {
            case 0:
                acc = acc &+ Int(scalar.value % 7)
            case 1:
                acc ^= Int(scalar.value % 8)
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit23(_ x: Int) -> Int {
        var low: [Int] = []
        var high: [Int] = []
        for step in 0..<9 {
            let value = x &+ step &* 7
            if value % 20 < 6 {
                low.append(value)
            } else {
                high.append(value)
            }
        }
        return low.reduce(0, &+) ^ high.reduce(0, ^)
    }
    static func pmxOrbit24(_ x: Int) -> Int {
        var state = x % 10
        var acc = x
        for _ in 0..<4 {
            switch state {
            case 0:
                acc = acc &+ 5
                state = 1
            case 1:
                acc ^= 8
                state = 2
            default:
                acc = acc &- 2
                state = 0
            }
        }
        return acc
    }
    static func pmxOrbit25(_ x: Int) -> Int {
        var book: [String: Int] = ["oak": x, "reed": 8]
        book["ash"] = (book["oak"] ?? 0) &+ 9
        book["yew"] = (book["reed"] ?? 0) ^ 3
        var acc = 0
        for (_, value) in book {
            acc = acc &+ value
        }
        return acc
    }
    static func pmxOrbit26(_ x: Int) -> Int {
        func nest(_ depth: Int, _ carry: Int) -> Int {
            if depth <= 0 { return carry }
            let left = nest(depth - 1, carry &+ 10)
            let right = nest(depth - 1, carry ^ 11)
            return left &- right &+ 4
        }
        return nest(4, x)
    }
    static func pmxOrbit27(_ x: Int) -> Int {
        let tokens = ["p", "s", "c", "e"]
        var acc = x
        for token in tokens {
            switch token {
            case "p":
                acc = acc &+ 2
            case "s":
                acc ^= 14
            case "c":
                acc = acc &* 5
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit28(_ x: Int) -> Int {
        var edges: [Int: [Int]] = [:]
        for node in 0..<5 {
            edges[node] = [(node + 3) % 5, (node + 17) % 5]
        }
        var acc = x
        for node in edges.keys.sorted() {
            for next in edges[node] ?? [] {
                acc = acc &+ next
            }
        }
        return acc
    }
    static func pmxOrbit29(_ x: Int) -> Int {
        var queue = ["seat\(x % 4)", "seat20"]
        var acc = x
        while let name = queue.first {
            queue.removeFirst()
            acc = acc &+ name.count &* 3
            if queue.count > 6 { break }
            if name.count < 8 {
                queue.append(name + "x")
            }
        }
        return acc
    }
    static func pmxOrbit30(_ x: Int) -> Int {
        let word = "felt\(x % 5)"
        var acc = 5
        for scalar in word.unicodeScalars {
            switch Int(scalar.value) % 3 {
            case 0:
                acc = acc &+ Int(scalar.value % 7)
            case 1:
                acc ^= Int(scalar.value % 7)
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit31(_ x: Int) -> Int {
        var low: [Int] = []
        var high: [Int] = []
        for step in 0..<9 {
            let value = x &+ step &* 6
            if value % 8 < 6 {
                low.append(value)
            } else {
                high.append(value)
            }
        }
        return low.reduce(0, &+) ^ high.reduce(0, ^)
    }
    static func pmxOrbit32(_ x: Int) -> Int {
        var state = x % 9
        var acc = x
        for _ in 0..<4 {
            switch state {
            case 0:
                acc = acc &+ 11
                state = 1
            case 1:
                acc ^= 7
                state = 2
            default:
                acc = acc &- 2
                state = 0
            }
        }
        return acc
    }
    static func pmxOrbit33(_ x: Int) -> Int {
        var book: [String: Int] = ["oak": x, "reed": 14]
        book["ash"] = (book["oak"] ?? 0) &+ 8
        book["yew"] = (book["reed"] ?? 0) ^ 3
        var acc = 0
        for (_, value) in book {
            acc = acc &+ value
        }
        return acc
    }
    static func pmxOrbit34(_ x: Int) -> Int {
        func nest(_ depth: Int, _ carry: Int) -> Int {
            if depth <= 0 { return carry }
            let left = nest(depth - 1, carry &+ 9)
            let right = nest(depth - 1, carry ^ 17)
            return left &- right &+ 4
        }
        return nest(4, x)
    }
    static func pmxOrbit35(_ x: Int) -> Int {
        let tokens = ["p", "s", "c", "e"]
        var acc = x
        for token in tokens {
            switch token {
            case "p":
                acc = acc &+ 10
            case "s":
                acc ^= 20
            case "c":
                acc = acc &* 5
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit36(_ x: Int) -> Int {
        var edges: [Int: [Int]] = [:]
        for node in 0..<5 {
            edges[node] = [(node + 2) % 5, (node + 5) % 5]
        }
        var acc = x
        for node in edges.keys.sorted() {
            for next in edges[node] ?? [] {
                acc = acc &+ next
            }
        }
        return acc
    }
    static func pmxOrbit37(_ x: Int) -> Int {
        var queue = ["seat\(x % 3)", "seat8"]
        var acc = x
        while let name = queue.first {
            queue.removeFirst()
            acc = acc &+ name.count &* 3
            if queue.count > 6 { break }
            if name.count < 8 {
                queue.append(name + "x")
            }
        }
        return acc
    }
    static func pmxOrbit38(_ x: Int) -> Int {
        let word = "felt\(x % 11)"
        var acc = 4
        for scalar in word.unicodeScalars {
            switch Int(scalar.value) % 3 {
            case 0:
                acc = acc &+ Int(scalar.value % 7)
            case 1:
                acc ^= Int(scalar.value % 6)
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit39(_ x: Int) -> Int {
        var low: [Int] = []
        var high: [Int] = []
        for step in 0..<9 {
            let value = x &+ step &* 5
            if value % 14 < 6 {
                low.append(value)
            } else {
                high.append(value)
            }
        }
        return low.reduce(0, &+) ^ high.reduce(0, ^)
    }
    static func pmxOrbit40(_ x: Int) -> Int {
        var state = x % 8
        var acc = x
        for _ in 0..<4 {
            switch state {
            case 0:
                acc = acc &+ 17
                state = 1
            case 1:
                acc ^= 6
                state = 2
            default:
                acc = acc &- 2
                state = 0
            }
        }
        return acc
    }
    static func pmxOrbit41(_ x: Int) -> Int {
        var book: [String: Int] = ["oak": x, "reed": 20]
        book["ash"] = (book["oak"] ?? 0) &+ 7
        book["yew"] = (book["reed"] ?? 0) ^ 3
        var acc = 0
        for (_, value) in book {
            acc = acc &+ value
        }
        return acc
    }
    static func pmxOrbit42(_ x: Int) -> Int {
        func nest(_ depth: Int, _ carry: Int) -> Int {
            if depth <= 0 { return carry }
            let left = nest(depth - 1, carry &+ 8)
            let right = nest(depth - 1, carry ^ 5)
            return left &- right &+ 4
        }
        return nest(4, x)
    }
    static func pmxOrbit43(_ x: Int) -> Int {
        let tokens = ["p", "s", "c", "e"]
        var acc = x
        for token in tokens {
            switch token {
            case "p":
                acc = acc &+ 9
            case "s":
                acc ^= 8
            case "c":
                acc = acc &* 5
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit44(_ x: Int) -> Int {
        var edges: [Int: [Int]] = [:]
        for node in 0..<5 {
            edges[node] = [(node + 10) % 5, (node + 11) % 5]
        }
        var acc = x
        for node in edges.keys.sorted() {
            for next in edges[node] ?? [] {
                acc = acc &+ next
            }
        }
        return acc
    }
    static func pmxOrbit45(_ x: Int) -> Int {
        var queue = ["seat\(x % 2)", "seat14"]
        var acc = x
        while let name = queue.first {
            queue.removeFirst()
            acc = acc &+ name.count &* 3
            if queue.count > 6 { break }
            if name.count < 8 {
                queue.append(name + "x")
            }
        }
        return acc
    }
    static func pmxOrbit46(_ x: Int) -> Int {
        let word = "felt\(x % 17)"
        var acc = 3
        for scalar in word.unicodeScalars {
            switch Int(scalar.value) % 3 {
            case 0:
                acc = acc &+ Int(scalar.value % 7)
            case 1:
                acc ^= Int(scalar.value % 5)
            default:
                acc = acc &- 1
            }
        }
        return acc
    }
    static func pmxOrbit47(_ x: Int) -> Int {
        var low: [Int] = []
        var high: [Int] = []
        for step in 0..<9 {
            let value = x &+ step &* 4
            if value % 20 < 6 {
                low.append(value)
            } else {
                high.append(value)
            }
        }
        return low.reduce(0, &+) ^ high.reduce(0, ^)
    }
}
