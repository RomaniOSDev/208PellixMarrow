import SwiftUI

extension Color {
    static let pmxNight = Color(red: 26.0 / 255.0, green: 45.0 / 255.0, blue: 56.0 / 255.0)
    static let pmxSurface = Color(red: 53.0 / 255.0, green: 70.0 / 255.0, blue: 80.0 / 255.0)
    static let pmxPrimary = Color(red: 18.0 / 255.0, green: 118.0 / 255.0, blue: 226.0 / 255.0)
    static let pmxAccent = Color(red: 65.0 / 255.0, green: 145.0 / 255.0, blue: 232.0 / 255.0)
    static let pmxInk = Color(red: 1, green: 1, blue: 1)
    static let pmxMuted = Color(red: 156.0 / 255.0, green: 163.0 / 255.0, blue: 175.0 / 255.0)
}

struct PmxFeltField: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color.pmxNight))
            for stitch in PmxMarrowLoom.stitches(width: size.width, height: size.height) {
                var path = Path()
                path.move(to: stitch.start)
                path.addLine(to: stitch.end)
                context.stroke(path, with: .color(Color.pmxSurface.opacity(0.45)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

enum PmxInkResign {
    static func fold() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func pmxFoldInkOnTap() -> some View {
        simultaneousGesture(TapGesture().onEnded { PmxInkResign.fold() })
    }

    func pmxTableCanvas() -> some View {
        scrollContentBackground(.hidden)
            .toolbarBackground(Color.pmxNight, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background {
                PmxFeltField()
                    .ignoresSafeArea()
            }
    }

    func pmxNightBackdrop(_ imageName: String, veil: Double) -> some View {
        let _ = imageName
        let _ = veil
        return frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                PmxFeltField()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
    }
}

struct PmxFramedStill: View {
    let name: String
    var height: CGFloat = 132

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.pmxAccent.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 10, y: 6)
    }
}

struct PmxTicket<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [Color.pmxSurface, Color.pmxSurface.opacity(0.86)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.pmxAccent.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 10, y: 6)
    }
}

struct PmxPrimaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.pmxInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(
                    LinearGradient(colors: [Color.pmxPrimary, Color.pmxAccent], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.pmxPrimary.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct PmxQuietButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.pmxInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.pmxSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.pmxAccent.opacity(0.7), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .background(PmxChromaSalt.pmxWash(title.count))
    }
}

enum PmxChromaSalt {
    static func pmxWash(_ width: Int) -> Color {
        let state = pmxStep(width)
        return state < 0 ? Color.pmxPrimary : Color.clear
    }

    static func pmxStep(_ width: Int) -> Int {
        var state = width
        var step = 0
        while step < 3 {
            switch state % 3 {
            case 0:
                state = state &+ 2
            case 1:
                state ^= 5
            default:
                state = state &- 1
            }
            step += 1
        }
        return state
    }
}
