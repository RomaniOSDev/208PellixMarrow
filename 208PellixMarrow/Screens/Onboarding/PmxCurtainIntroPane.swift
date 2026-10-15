import SwiftUI

struct PmxCurtainIntroPane: View {
    @EnvironmentObject private var vault: PmxTableVault
    @State private var dealt = 0

    private let cards: [(image: String, title: String, body: String)] = [
        ("PmxTableLamp", "A felt of your own", "List the games you already bring, then open a pad when everyone sits."),
        ("PmxDiceCluster", "Rounds, not scraps", "Seats and tallies stay in one pad. Totals move as the night goes."),
        ("PmxCardFan", "Come back tomorrow", "An opening cue waits each day. The streak counts the nights you host.")
    ]

    var body: some View {
        VStack(spacing: 18) {
            Text("Card \(dealt + 1) of \(cards.count)")
                .font(.caption.weight(.bold))
                .foregroundColor(.pmxAccent)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                ForEach(Array(cards.enumerated()).reversed(), id: \.offset) { index, card in
                    if index >= dealt {
                        VStack(alignment: .leading, spacing: 10) {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .overlay {
                                    Image(card.image)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .clipped()
                            Text(card.title)
                                .font(.title3.weight(.bold))
                                .foregroundColor(.pmxInk)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(card.body)
                                .font(.subheadline)
                                .foregroundColor(.pmxMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .background(Color.pmxSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(alignment: .top) {
                            Rectangle().fill(Color.pmxAccent).frame(height: 4)
                        }
                        .shadow(color: Color.black.opacity(0.35), radius: 8, y: 4)
                        .offset(x: CGFloat(index - dealt) * 10, y: CGFloat(index - dealt) * 12)
                        .scaleEffect(1 - CGFloat(index - dealt) * 0.03)
                        .zIndex(Double(cards.count - index))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)

            Spacer(minLength: 8)

            PmxPrimaryButton(title: dealt == cards.count - 1 ? "Sit down" : "Deal the next card") {
                if dealt == cards.count - 1 {
                    vault.pmxMarkIntroCleared()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { dealt += 1 }
                }
            }
        }
        .padding(16)
    }
}
