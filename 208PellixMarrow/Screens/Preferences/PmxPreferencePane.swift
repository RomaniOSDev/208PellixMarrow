import StoreKit
import SwiftUI

struct PmxPreferencePane: View {
    @EnvironmentObject private var vault: PmxTableVault
    @State private var revealClear = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("House desk")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.pmxInk)
                Text("Nights, rules, and the shelf stay on this phone.")
                    .font(.footnote)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        pmxChip("Rate Us", symbol: "star", action: rateApp)
                        pmxChip("Privacy", symbol: "lock", action: { pmxOpen(PmxParchmentGate.privacyLeaf) })
                        pmxChip("Terms", symbol: "doc.text", action: { pmxOpen(PmxParchmentGate.termsLeaf) })
                    }
                }

                Button("Deal the opening cards again") { vault.pmxReplayIntro() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.pmxAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.pmxSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Button(revealClear ? "Hide the clear step" : "Clear nights, rules, and shelf") {
                        withAnimation(.easeInOut(duration: 0.2)) { revealClear.toggle() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.pmxInk)
                    if revealClear {
                        Text("Saved nights, house rules, and shelf games will be removed from this phone.")
                            .font(.footnote)
                            .foregroundColor(.pmxMuted)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Button("Remove the felt") {
                                vault.pmxClearTable()
                                revealClear = false
                            }
                            .font(.caption.weight(.bold))
                            .foregroundColor(.pmxInk)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color.pmxPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            Button("Leave it") { revealClear = false }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.pmxAccent)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.pmxSurface.opacity(0.85))
                .overlay(Rectangle().stroke(Color.pmxAccent.opacity(0.4), lineWidth: 1))

                PmxFramedStill(name: "PmxTableLamp", height: 110)
            }
            .padding(16)
        }
        .pmxTableCanvas()
        .navigationTitle("Desk")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pmxChip(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.title3)
                Text(title)
                    .font(.caption.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(.pmxInk)
            .frame(width: 108, height: 88)
            .background(
                LinearGradient(colors: [Color.pmxPrimary, Color.pmxAccent], startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .shadow(color: Color.pmxPrimary.opacity(0.35), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func pmxOpen(_ leaf: String) {
        if let url = URL(string: leaf) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
