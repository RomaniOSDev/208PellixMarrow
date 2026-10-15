import SwiftUI

struct ContentView: View {
    @StateObject private var vault = PmxTableVault()

    var body: some View {
        pmxStage
            .environmentObject(vault)
            .onAppear { vault.pmxStampVisit() }
    }

    @ViewBuilder
    private var pmxStage: some View {
        if vault.onboardingCleared {
            PmxRailShell()
        } else {
            PmxCurtainIntroPane()
                .pmxNightBackdrop("PmxTableLamp", veil: 0.18)
        }
    }
}
