import SwiftUI

struct PmxTurnWheelPane: View {
    @EnvironmentObject private var vault: PmxTableVault
    @State private var draft = ""
    @State private var names: [String] = []
    @State private var spun: [String] = []
    @State private var angle: Double = 0
    @State private var spinning = false
    @State private var showFault = false
    @State private var openPad = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Seat wheel")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.pmxInk)
                Text("Add the people at the table, then spin a seating sequence.")
                    .font(.footnote)
                    .foregroundColor(.pmxMuted)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    TextField("Name", text: $draft)
                        .font(.subheadline)
                        .foregroundColor(.pmxInk)
                        .padding(10)
                        .background(Color.pmxSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Button("Add") {
                        let name = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                        if name.isEmpty { return }
                        names.append(name)
                        draft = ""
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.pmxInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.pmxPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                    HStack {
                        Text(name)
                            .foregroundColor(.pmxInk)
                        Spacer()
                        Button("Remove") { names.remove(at: index) }
                            .font(.caption.weight(.bold))
                            .foregroundColor(.pmxAccent)
                    }
                }
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(colors: [Color.pmxPrimary, Color.pmxAccent, Color.pmxSurface, Color.pmxPrimary], center: .center)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(angle))
                        .shadow(color: Color.pmxPrimary.opacity(0.4), radius: 12, y: 4)
                    Circle()
                        .fill(Color.pmxNight)
                        .frame(width: 70, height: 70)
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.pmxInk)
                }
                .frame(maxWidth: .infinity)
                PmxPrimaryButton(title: spinning ? "Spinning" : "Spin seating") { pmxSpin() }
                if !spun.isEmpty {
                    Text("Seating sequence")
                        .font(.headline)
                        .foregroundColor(.pmxInk)
                    ForEach(Array(spun.enumerated()), id: \.offset) { index, name in
                        Text("\(index + 1). \(name)")
                            .font(.subheadline)
                            .foregroundColor(.pmxInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color.pmxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Button {
                        vault.draftNames = spun
                        openPad = true
                    } label: {
                        Text("Open a score pad with this seating")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.pmxInk)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.pmxAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                PmxFramedStill(name: "PmxDiceCluster", height: 100)
            }
            .padding(16)
        }
        .pmxFoldInkOnTap()
        .pmxTableCanvas()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Seat wheel")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $openPad) {
            PmxScorePadPane()
        }
        .alert("Add two names", isPresented: $showFault) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The wheel needs at least two seats before it can spin.")
        }
    }

    private func pmxSpin() {
        if names.count < 2 {
            showFault = true
            return
        }
        spinning = true
        withAnimation(.easeInOut(duration: 0.9)) { angle += 540 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            spun = names.shuffled()
            spinning = false
        }
    }
}
