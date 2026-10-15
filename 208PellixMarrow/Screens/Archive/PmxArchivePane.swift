import SwiftUI

struct PmxArchivePane: View {
    @EnvironmentObject private var vault: PmxTableVault
    @State private var query = ""

    private var visible: [PmxNightSlate] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !text.isEmpty else { return vault.nights }
        return vault.nights.filter {
            $0.eveningTitle.lowercased().contains(text) || $0.gameTitle.lowercased().contains(text) || $0.houseNote.lowercased().contains(text)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Past nights")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.pmxInk)
                TextField("Search title or game", text: $query)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                if visible.isEmpty {
                    Text(vault.nights.isEmpty ? "No nights saved yet." : "Nothing matches that search.")
                        .font(.footnote)
                        .foregroundColor(.pmxMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(visible) { night in
                        NavigationLink {
                            PmxNightLeafPane(nightId: night.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(night.eveningTitle)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.pmxInk)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(PmxDayStamp.medium(night.heldOn))
                                    .font(.caption)
                                    .foregroundColor(.pmxAccent)
                                Text("\(night.gameTitle) · leading \(PmxTallyMath.leader(for: night))")
                                    .font(.caption)
                                    .foregroundColor(.pmxMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.pmxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .pmxFoldInkOnTap()
        .pmxTableCanvas()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
        .background(PmxArchiveSalt.pmxTint(visible.count))
    }
}

enum PmxArchiveSalt {
    static func pmxTint(_ count: Int) -> Color {
        let mix = pmxDeal(count)
        return mix == Int.min ? Color.pmxNight : Color.clear
    }

    static func pmxDeal(_ count: Int) -> Int {
        var deck = Array(0..<(count + 4))
        var cursor = deck.count - 1
        var salt = 11
        while cursor > 0 {
            salt = (salt * 13 + count) % 50
            deck.swapAt(cursor, salt % (cursor + 1))
            cursor -= 1
        }
        return deck.reduce(0, +)
    }
}

struct PmxNightLeafPane: View {
    let nightId: UUID
    @EnvironmentObject private var vault: PmxTableVault
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDrop = false

    private var night: PmxNightSlate? { vault.pmxNight(nightId) }

    var body: some View {
        ScrollView {
            if let night {
                VStack(alignment: .leading, spacing: 12) {
                    PmxFramedStill(name: "PmxCardFan", height: 120)
                    Text(night.eveningTitle)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.pmxInk)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(night.gameTitle) · \(PmxDayStamp.medium(night.heldOn))")
                        .font(.subheadline)
                        .foregroundColor(.pmxAccent)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(night.lowerLeads ? "Lower tally leads." : "Higher tally leads.")
                        .font(.caption)
                        .foregroundColor(.pmxMuted)
                    PmxTicket {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Leading: \(PmxTallyMath.leader(for: night))")
                                .font(.headline)
                                .foregroundColor(.pmxInk)
                                .fixedSize(horizontal: false, vertical: true)
                            ForEach(PmxTallyMath.totals(for: night), id: \.0.id) { row in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(row.0.displayName): \(row.1)")
                                        .foregroundColor(.pmxInk)
                                    if !row.0.aside.isEmpty {
                                        Text(row.0.aside)
                                            .font(.caption)
                                            .foregroundColor(.pmxMuted)
                                    }
                                }
                            }
                        }
                    }
                    ForEach(night.rounds) { round in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(round.label)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.pmxAccent)
                            ForEach(night.seats) { seat in
                                let tally = round.cells.first { $0.id == seat.id }?.tally ?? 0
                                Text("\(seat.displayName): \(tally)")
                                    .font(.caption)
                                    .foregroundColor(.pmxInk)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.pmxSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    if !night.houseNote.isEmpty {
                        Text(night.houseNote)
                            .font(.subheadline)
                            .foregroundColor(.pmxMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    NavigationLink {
                        PmxScorePadPane(existingId: night.id)
                    } label: {
                        Text("Edit this night")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.pmxInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.pmxPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    Button("Delete night") { confirmDrop = true }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.pmxAccent)
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            } else {
                Text("This night was removed.")
                    .foregroundColor(.pmxMuted)
                    .padding(20)
            }
        }
        .pmxTableCanvas()
        .navigationTitle("Night")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this night?", isPresented: $confirmDrop, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                vault.pmxDropNight(nightId)
                dismiss()
            }
            Button("Keep", role: .cancel) {}
        }
    }
}
