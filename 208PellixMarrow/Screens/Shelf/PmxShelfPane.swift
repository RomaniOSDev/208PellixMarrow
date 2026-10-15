import SwiftUI

struct PmxShelfPane: View {
    @EnvironmentObject private var vault: PmxTableVault
    @State private var kindFilter = "All"
    @State private var query = ""

    private var visible: [PmxShelfGame] {
        vault.games.filter { game in
            let kindOK = kindFilter == "All" || game.kindTag == kindFilter
            let text = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let textOK = text.isEmpty || game.title.lowercased().contains(text) || game.blurb.lowercased().contains(text)
            return kindOK && textOK
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                PmxFramedStill(name: "PmxBoxStack", height: 120)
                Text("Games you play")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.pmxInk)
                Text("Add a title you already bring to the table. Nothing here leaves this phone.")
                    .font(.footnote)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                TextField("Search the shelf", text: $query)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        kindChip("All")
                        ForEach(PmxKindRibbon.tags, id: \.self) { tag in
                            kindChip(tag)
                        }
                    }
                }
                NavigationLink {
                    PmxGameLeafPane(existingId: nil)
                } label: {
                    Text("Add a game")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.pmxInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.pmxPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                if visible.isEmpty {
                    Text(vault.games.isEmpty ? "The shelf is empty." : "Nothing matches this filter.")
                        .font(.footnote)
                        .foregroundColor(.pmxMuted)
                } else {
                    ForEach(visible) { game in
                        NavigationLink {
                            PmxGameLeafPane(existingId: game.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(game.title)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.pmxInk)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("\(game.kindTag) · \(game.playerSpan) · about \(game.minuteHint) min")
                                    .font(.caption)
                                    .foregroundColor(.pmxAccent)
                                    .fixedSize(horizontal: false, vertical: true)
                                if !game.blurb.isEmpty {
                                    Text(game.blurb)
                                        .font(.caption)
                                        .foregroundColor(.pmxMuted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.pmxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.black.opacity(0.25), radius: 6, y: 3)
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
        .navigationBarHidden(true)
    }

    private func kindChip(_ title: String) -> some View {
        Button(title) { kindFilter = title }
            .font(.caption.weight(.bold))
            .foregroundColor(kindFilter == title ? .pmxInk : .pmxAccent)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(kindFilter == title ? Color.pmxPrimary : Color.pmxSurface)
            .clipShape(Capsule())
    }
}

struct PmxGameLeafPane: View {
    var existingId: UUID?
    @EnvironmentObject private var vault: PmxTableVault
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var playerSpan = "2 to 4"
    @State private var minuteHint = 30
    @State private var kindTag = "Cards"
    @State private var blurb = ""
    @State private var showFault = false
    @State private var loaded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Game title", text: $title)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                TextField("Who can sit, such as 2 to 6", text: $playerSpan)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Stepper(value: $minuteHint, in: 5...240, step: 5) {
                    Text("About \(minuteHint) minutes")
                        .foregroundColor(.pmxInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(PmxKindRibbon.tags, id: \.self) { tag in
                            Button(tag) { kindTag = tag }
                                .font(.caption.weight(.bold))
                                .foregroundColor(kindTag == tag ? .pmxInk : .pmxAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(kindTag == tag ? Color.pmxPrimary : Color.pmxSurface)
                                .clipShape(Capsule())
                        }
                    }
                }
                TextField("How you like to play it", text: $blurb, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                PmxPrimaryButton(title: existingId == nil ? "Save on the shelf" : "Keep changes") { pmxSave() }
                if existingId != nil {
                    Button("Remove from shelf") {
                        if let existingId { vault.pmxDropGame(existingId) }
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.pmxAccent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
        }
        .pmxFoldInkOnTap()
        .pmxTableCanvas()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(existingId == nil ? "New game" : "Edit game")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !loaded else { return }
            loaded = true
            guard let existingId, let game = vault.games.first(where: { $0.id == existingId }) else { return }
            title = game.title
            playerSpan = game.playerSpan
            minuteHint = game.minuteHint
            kindTag = game.kindTag
            blurb = game.blurb
        }
        .alert("Add a title", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The shelf needs a title so you can pick this game later.")
        }
    }

    private func pmxSave() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            showFault = true
            return
        }
        let span = playerSpan.trimmingCharacters(in: .whitespacesAndNewlines)
        vault.pmxUpsertGame(PmxShelfGame(
            id: existingId ?? UUID(),
            title: trimmed,
            playerSpan: span.isEmpty ? "Any table" : span,
            minuteHint: minuteHint,
            kindTag: kindTag,
            blurb: blurb.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
        dismiss()
    }
}
