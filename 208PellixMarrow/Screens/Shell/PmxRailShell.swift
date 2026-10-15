import SwiftUI

enum PmxRailLane: String, CaseIterable, Identifiable {
    case table
    case cabinet
    case canon
    case ledger

    var id: String { rawValue }

    var label: String {
        switch self {
        case .table: return "Table"
        case .cabinet: return "Cabinet"
        case .canon: return "Canon"
        case .ledger: return "Ledger"
        }
    }

    var mark: String {
        switch self {
        case .table: return "square.grid.2x2"
        case .cabinet: return "books.vertical"
        case .canon: return "scroll"
        case .ledger: return "chart.bar.xaxis"
        }
    }
}

struct PmxRailShell: View {
    @State private var lane: PmxRailLane = .table

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch lane {
                case .table:
                    NavigationStack { PmxTonightLobbyPane() }
                case .cabinet:
                    NavigationStack { PmxShelfPane() }
                case .canon:
                    NavigationStack { PmxHouseRulePane() }
                case .ledger:
                    NavigationStack { PmxWeekHostPane() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pmxNight)

            HStack(spacing: 0) {
                ForEach(PmxRailLane.allCases) { item in
                    Button {
                        lane = item
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: item.mark)
                                .font(.body.weight(.semibold))
                            Text(item.label)
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundColor(lane == item ? .pmxInk : .pmxMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(lane == item ? Color.pmxAccent : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(Color.pmxNight.opacity(0.92))
        }
        .pmxNightBackdrop("PmxCardFan", veil: 0.08)
    }
}
