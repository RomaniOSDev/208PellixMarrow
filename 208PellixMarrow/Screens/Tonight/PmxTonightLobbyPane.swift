import SwiftUI

struct PmxTonightLobbyPane: View {
    @EnvironmentObject private var vault: PmxTableVault

    private var tonight: [PmxNightSlate] {
        vault.nights.filter { Calendar.current.isDateInToday($0.heldOn) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("The felt")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.pmxInk)
                        Text(vault.pmxStreakSpan() == 1 ? "1 night in a row" : "\(vault.pmxStreakSpan()) nights in a row")
                            .font(.subheadline)
                            .foregroundColor(.pmxAccent)
                    }
                    Spacer()
                    NavigationLink {
                        PmxPreferencePane()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.pmxInk)
                            .frame(width: 40, height: 40)
                            .background(Color.pmxPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                PmxFramedStill(name: "PmxTableLamp", height: 128)

                if let picker = PmxChooser.name(from: vault.nights) {
                    PmxTicket {
                        Text("Tonight \(picker) chooses the game.")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.pmxInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let rule = PmxChooser.eveningRule(from: vault.rules, nights: vault.nights) {
                    PmxTicket {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Rule for this table")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.pmxAccent)
                            Text(rule.gameTitle)
                                .font(.caption)
                                .foregroundColor(.pmxMuted)
                            Text(rule.ruleText)
                                .font(.subheadline)
                                .foregroundColor(.pmxInk)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                PmxTicket {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opening cue")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.pmxAccent)
                        Text(PmxOpenerReel.line(for: Date()))
                            .font(.subheadline)
                            .foregroundColor(.pmxInk)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            vault.pmxToggleOpener()
                        } label: {
                            Text(vault.pmxOpenerDoneToday() ? "Cue played" : "Mark the cue")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.pmxInk)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(vault.pmxOpenerDoneToday() ? Color.pmxAccent.opacity(0.45) : Color.pmxPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !vault.nights.isEmpty {
                    NavigationLink {
                        PmxScorePadPane(replayLast: true)
                    } label: {
                        Text("Sit as last time")
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

                NavigationLink {
                    PmxScorePadPane()
                } label: {
                    Text("Open a pad")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.pmxInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [Color.pmxPrimary, Color.pmxAccent], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                HStack(spacing: 8) {
                    NavigationLink {
                        PmxTurnWheelPane()
                    } label: {
                        lobbyChip("Draw seats")
                    }
                    NavigationLink {
                        PmxArchivePane()
                    } label: {
                        lobbyChip("Old pads")
                    }
                }

                Text("Saved tonight")
                    .font(.headline)
                    .foregroundColor(.pmxInk)
                if tonight.isEmpty {
                    Text("No pad for today. Open one when the seats are ready.")
                        .font(.footnote)
                        .foregroundColor(.pmxMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(tonight) { night in
                        NavigationLink {
                            PmxNightLeafPane(nightId: night.id)
                        } label: {
                            nightRow(night)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .pmxTableCanvas()
        .navigationBarHidden(true)
    }

    private func lobbyChip(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundColor(.pmxInk)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.pmxSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.pmxAccent.opacity(0.4), lineWidth: 1))
            .contentShape(Rectangle())
    }

    private func nightRow(_ night: PmxNightSlate) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(night.eveningTitle)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.pmxInk)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(night.gameTitle) · \(night.seats.count) seats · \(night.rounds.count) rounds")
                .font(.caption)
                .foregroundColor(.pmxMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.pmxSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
