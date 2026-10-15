import SwiftUI

struct PmxHouseRulePane: View {
    @EnvironmentObject private var vault: PmxTableVault
    @State private var gameTitle = ""
    @State private var ruleText = ""
    @State private var editingId: UUID?
    @State private var showFault = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                PmxFramedStill(name: "PmxCardFan", height: 110)
                Text("House rules")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.pmxInk)
                Text("Write the way your table actually plays. These notes stay on this phone.")
                    .font(.footnote)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                TextField("Game title", text: $gameTitle)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                if !vault.games.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(vault.games) { game in
                                Button(game.title) { gameTitle = game.title }
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.pmxInk)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.pmxPrimary.opacity(gameTitle == game.title ? 1 : 0.45))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                TextField("The rule in plain words", text: $ruleText, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.pmxInk)
                    .padding(10)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                PmxPrimaryButton(title: editingId == nil ? "Save rule" : "Update rule") { pmxSave() }
                if editingId != nil {
                    PmxQuietButton(title: "Cancel edit") { pmxReset() }
                }
                ForEach(vault.rules) { rule in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.gameTitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.pmxAccent)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(rule.ruleText)
                            .font(.footnote)
                            .foregroundColor(.pmxInk)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Button("Edit") {
                                editingId = rule.id
                                gameTitle = rule.gameTitle
                                ruleText = rule.ruleText
                            }
                            .font(.caption.weight(.bold))
                            .foregroundColor(.pmxInk)
                            Button("Delete") { vault.pmxDropRule(rule.id) }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.pmxAccent)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(16)
        }
        .pmxFoldInkOnTap()
        .pmxTableCanvas()
        .scrollDismissesKeyboard(.interactively)
        .navigationBarHidden(true)
        .alert("Add both fields", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A house rule needs a game title and the rule itself.")
        }
    }

    private func pmxSave() {
        let title = gameTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = ruleText.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty || text.isEmpty {
            showFault = true
            return
        }
        vault.pmxUpsertRule(PmxHouseRule(id: editingId ?? UUID(), gameTitle: title, ruleText: text))
        pmxReset()
    }

    private func pmxReset() {
        editingId = nil
        gameTitle = ""
        ruleText = ""
    }
}
