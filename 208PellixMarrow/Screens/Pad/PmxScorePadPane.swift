import SwiftUI

struct PmxScorePadPane: View {
    var existingId: UUID? = nil
    var replayLast = false
    @EnvironmentObject private var vault: PmxTableVault
    @Environment(\.dismiss) private var dismiss

    @State private var eveningTitle = "Table night"
    @State private var gameTitle = ""
    @State private var seatDraft = ""
    @State private var seats: [PmxSeat] = []
    @State private var rounds: [PmxRoundMark] = []
    @State private var houseNote = ""
    @State private var lowerLeads = false
    @State private var showFault = false
    @State private var faultLine = ""
    @State private var loaded = false
    @State private var clockStart: Date?
    @State private var clockMinutes = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                PmxFramedStill(name: "PmxDiceCluster", height: 100)
                field("Evening title", text: $eveningTitle)
                field("Game title", text: $gameTitle)
                if !vault.games.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(vault.games) { game in
                                Button(game.title) { gameTitle = game.title }
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.pmxInk)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(gameTitle == game.title ? Color.pmxPrimary : Color.pmxSurface)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                Toggle(isOn: $lowerLeads) {
                    Text("Lower tally leads")
                        .foregroundColor(.pmxInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .tint(.pmxAccent)

                if matchedMinutes > 0 {
                    clockCard
                }

                HStack {
                    TextField("Seat name", text: $seatDraft)
                        .font(.subheadline)
                        .foregroundColor(.pmxInk)
                        .padding(10)
                        .background(Color.pmxSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Button("Add") { pmxAddSeat() }
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.pmxInk)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.pmxPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                ForEach($seats) { $seat in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(seat.displayName)
                                .foregroundColor(.pmxInk)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Button("Remove") { pmxRemoveSeat(seat.id) }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.pmxAccent)
                        }
                        TextField("Note for this seat", text: $seat.aside)
                            .font(.caption)
                            .foregroundColor(.pmxInk)
                    }
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if !seats.isEmpty {
                    PmxTicket {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Running totals")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.pmxAccent)
                            let preview = pmxPreviewNight()
                            ForEach(PmxTallyMath.totals(for: preview), id: \.0.id) { row in
                                Text("\(row.0.displayName): \(row.1)")
                                    .font(.subheadline)
                                    .foregroundColor(.pmxInk)
                            }
                            Text("Leading: \(PmxTallyMath.leader(for: preview))")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.pmxAccent)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                if let liveIndex = rounds.indices.last {
                    liveRound(liveIndex)
                }

                PmxPrimaryButton(title: rounds.isEmpty ? "Start the first round" : "Next round") { pmxAddRound() }

                ForEach(rounds.dropLast()) { round in
                    pastRound(round)
                }

                TextField("Night note", text: $houseNote, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                PmxPrimaryButton(title: existingId == nil ? "Save the night" : "Update the night") { pmxSave() }
            }
            .padding(16)
        }
        .pmxFoldInkOnTap()
        .pmxTableCanvas()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Score pad")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: pmxLoad)
        .alert("Check the pad", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(faultLine)
        }
    }

    private var matchedMinutes: Int {
        vault.games.first { $0.title.caseInsensitiveCompare(gameTitle) == .orderedSame }?.minuteHint ?? 0
    }

    private var clockCard: some View {
        PmxTicket {
            VStack(alignment: .leading, spacing: 8) {
                Text("Party clock")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.pmxAccent)
                if let clockStart {
                    TimelineView(.periodic(from: clockStart, by: 1)) { context in
                        let left = max(0, clockMinutes * 60 - Int(context.date.timeIntervalSince(clockStart)))
                        Text(left == 0 ? "Time to close the round." : pmxClock(left))
                            .font(.title3.weight(.bold))
                            .foregroundColor(left == 0 ? .pmxAccent : .pmxInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Button("Stop the clock") { self.clockStart = nil }
                        .font(.caption.weight(.bold))
                        .foregroundColor(.pmxAccent)
                } else {
                    Text("This game is about \(matchedMinutes) min.")
                        .font(.subheadline)
                        .foregroundColor(.pmxInk)
                    Button("Start the clock") {
                        clockMinutes = matchedMinutes
                        clockStart = Date()
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.pmxInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.pmxPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func liveRound(_ index: Int) -> some View {
        PmxTicket {
            VStack(alignment: .leading, spacing: 10) {
                Text(rounds[index].label)
                    .font(.headline)
                    .foregroundColor(.pmxInk)
                ForEach(seats) { seat in
                    if let cell = rounds[index].cells.firstIndex(where: { $0.id == seat.id }) {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(seat.displayName)
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.pmxInk)
                                if !seat.aside.isEmpty {
                                    Text(seat.aside)
                                        .font(.caption)
                                        .foregroundColor(.pmxMuted)
                                }
                            }
                            Spacer()
                            Button("-") { pmxNudge(round: index, cell: cell, by: -1) }
                                .font(.title3.weight(.bold))
                                .foregroundColor(.pmxInk)
                                .frame(width: 36, height: 36)
                                .background(Color.pmxNight)
                                .clipShape(Circle())
                            Text("\(rounds[index].cells[cell].tally)")
                                .font(.title.weight(.bold))
                                .foregroundColor(.pmxInk)
                                .frame(minWidth: 36)
                            Button("+") { pmxNudge(round: index, cell: cell, by: 1) }
                                .font(.title3.weight(.bold))
                                .foregroundColor(.pmxInk)
                                .frame(width: 36, height: 36)
                                .background(Color.pmxPrimary)
                                .clipShape(Circle())
                        }
                    }
                }
                Button("Drop this round") {
                    rounds.removeAll { $0.id == rounds[index].id }
                }
                .font(.caption.weight(.bold))
                .foregroundColor(.pmxAccent)
            }
        }
    }

    private func pastRound(_ round: PmxRoundMark) -> some View {
        PmxTicket {
            VStack(alignment: .leading, spacing: 6) {
                Text(round.label)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.pmxAccent)
                ForEach(seats) { seat in
                    let tally = round.cells.first { $0.id == seat.id }?.tally ?? 0
                    Text("\(seat.displayName): \(tally)")
                        .font(.caption)
                        .foregroundColor(.pmxInk)
                }
                Button("Drop round") { rounds.removeAll { $0.id == round.id } }
                    .font(.caption.weight(.bold))
                    .foregroundColor(.pmxAccent)
            }
        }
    }

    private func field(_ caption: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption)
                .font(.caption.weight(.bold))
                .foregroundColor(.pmxMuted)
            TextField(caption, text: text)
                .font(.subheadline)
                .foregroundColor(.pmxInk)
                .padding(10)
                .background(Color.pmxSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func pmxLoad() {
        guard !loaded else { return }
        loaded = true
        if let existingId, let night = vault.pmxNight(existingId) {
            eveningTitle = night.eveningTitle
            gameTitle = night.gameTitle
            seats = night.seats
            rounds = night.rounds
            houseNote = night.houseNote
            lowerLeads = night.lowerLeads
        } else if replayLast, let last = vault.nights.max(by: { $0.heldOn < $1.heldOn }) {
            eveningTitle = last.eveningTitle
            gameTitle = last.gameTitle
            lowerLeads = last.lowerLeads
            seats = last.seats.map { PmxSeat(id: UUID(), displayName: $0.displayName, aside: $0.aside) }
        } else {
            let names = vault.pmxConsumeDraft()
            seats = names.map { PmxSeat(id: UUID(), displayName: $0) }
        }
    }

    private func pmxNudge(round: Int, cell: Int, by delta: Int) {
        let next = rounds[round].cells[cell].tally + delta
        rounds[round].cells[cell].tally = min(200, max(-50, next))
    }

    private func pmxClock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func pmxAddSeat() {
        let name = seatDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            faultLine = "Type a seat name first."
            showFault = true
            return
        }
        let seat = PmxSeat(id: UUID(), displayName: name)
        seats.append(seat)
        for index in rounds.indices {
            rounds[index].cells.append(PmxTallyCell(id: seat.id, tally: 0))
        }
        seatDraft = ""
    }

    private func pmxRemoveSeat(_ id: UUID) {
        seats.removeAll { $0.id == id }
        for index in rounds.indices {
            rounds[index].cells.removeAll { $0.id == id }
        }
    }

    private func pmxAddRound() {
        if seats.isEmpty {
            faultLine = "Add at least one seat before a round."
            showFault = true
            return
        }
        let cells = seats.map { PmxTallyCell(id: $0.id, tally: 0) }
        rounds.append(PmxRoundMark(id: UUID(), label: "Round \(rounds.count + 1)", cells: cells))
    }

    private func pmxPreviewNight() -> PmxNightSlate {
        PmxNightSlate(
            id: existingId ?? UUID(),
            eveningTitle: eveningTitle,
            heldOn: Date(),
            gameTitle: gameTitle,
            seats: seats,
            rounds: rounds,
            houseNote: houseNote,
            lowerLeads: lowerLeads
        )
    }

    private func pmxSave() {
        let title = eveningTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let game = gameTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty || game.isEmpty {
            faultLine = "Add an evening title and a game title."
            showFault = true
            return
        }
        if seats.count < 2 {
            faultLine = "A table needs at least two seats."
            showFault = true
            return
        }
        if rounds.isEmpty {
            faultLine = "Add a round so the pad has a tally."
            showFault = true
            return
        }
        let prior = existingId.flatMap { vault.pmxNight($0) }
        vault.pmxUpsertNight(PmxNightSlate(
            id: existingId ?? UUID(),
            eveningTitle: title,
            heldOn: prior?.heldOn ?? Date(),
            gameTitle: game,
            seats: seats,
            rounds: rounds,
            houseNote: houseNote.trimmingCharacters(in: .whitespacesAndNewlines),
            lowerLeads: lowerLeads
        ))
        dismiss()
    }
}
