import Charts
import SwiftUI

struct PmxWeekHostPane: View {
    @EnvironmentObject private var vault: PmxTableVault

    private var weekBars: [PmxMarrowBar] { PmxMarrowLoom.weekBars(from: vault.pmxWeekRows()) }
    private var gameBars: [PmxMarrowBar] { PmxMarrowLoom.gameBars(from: vault.nights) }
    private var leadBars: [PmxMarrowBar] { PmxMarrowLoom.leadBars(from: vault.nights) }
    private var marrow: Int {
        PmxMarrowLoom.index(
            nights: vault.nights.count,
            rules: vault.rules.count,
            streak: vault.pmxStreakSpan(),
            games: vault.games.count
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Table ledger")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.pmxInk)
                Text("Marrow \(marrow). A higher mark means more nights, rules, and a longer hosting streak.")
                    .font(.footnote)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                if let picker = PmxChooser.name(from: vault.nights) {
                    Text("Longest without a night: \(picker) chooses the next game.")
                        .font(.footnote)
                        .foregroundColor(.pmxAccent)
                        .fixedSize(horizontal: false, vertical: true)
                }

                chartCard(title: "Nights this week", bars: weekBars, horizontal: false)
                chartCard(title: "Games that sat down", bars: gameBars, horizontal: true)
                chartCard(title: "Who took the night", bars: leadBars, horizontal: true)

                let total = weekBars.reduce(0) { $0 + $1.amount }
                Text("\(total) pads in these seven days. \(vault.games.count) titles stay in the cabinet.")
                    .font(.subheadline)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                NavigationLink {
                    PmxArchivePane()
                } label: {
                    Text("Open old pads")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.pmxInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.pmxSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.pmxAccent.opacity(0.5), lineWidth: 1))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .pmxTableCanvas()
        .navigationBarHidden(true)
    }

    private func chartCard(title: String, bars: [PmxMarrowBar], horizontal: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundColor(.pmxAccent)
            if bars.allSatisfy({ $0.amount == 0 }) {
                Text("No marks yet. Save a night and this fills in.")
                    .font(.caption)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Chart(bars) { bar in
                if horizontal {
                    BarMark(
                        x: .value("Count", bar.amount),
                        y: .value("Name", bar.label)
                    )
                    .foregroundStyle(Color.pmxAccent)
                } else {
                    BarMark(
                        x: .value("Day", bar.label),
                        y: .value("Nights", bar.amount)
                    )
                    .foregroundStyle(Color.pmxPrimary)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.pmxSurface)
                    AxisValueLabel().foregroundStyle(Color.pmxMuted)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.pmxSurface)
                    AxisValueLabel().foregroundStyle(Color.pmxMuted)
                }
            }
            .frame(height: horizontal ? CGFloat(max(bars.count, 1) * 36 + 24) : 180)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pmxSurface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
