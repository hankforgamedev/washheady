import SwiftUI

struct CharacterHeadView: View {
    let messinessLevel: Int
    var wetProgress: Double = 0
    var isUnknown = false
    var hairOffset: CGSize = .zero

    private var clampedMessiness: CGFloat {
        CGFloat(min(3, max(0, messinessLevel)))
    }

    private var clampedWetness: CGFloat {
        CGFloat(min(1, max(0, wetProgress)))
    }

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let messyScale = 1 + clampedMessiness * 0.14
            let hairScale = messyScale - (messyScale - 0.92) * clampedWetness

            ZStack {
                HairCloud(color: hairColor)
                    .frame(width: side * 0.82, height: side * 0.58)
                    .scaleEffect(hairScale)
                    .rotationEffect(.degrees(Double(hairOffset.width / 38)))
                    .offset(
                        x: hairOffset.width * 0.50,
                        y: -side * 0.18 + hairOffset.height * 0.30
                    )
                    .animation(.spring(response: 0.45, dampingFraction: 0.62), value: messinessLevel)
                    .animation(.interactiveSpring(response: 0.20, dampingFraction: 0.62), value: hairOffset)

                HStack(spacing: side * 0.55) {
                    Circle().fill(faceColor)
                    Circle().fill(faceColor)
                }
                .frame(width: side * 0.82, height: side * 0.14)
                .offset(y: side * 0.05)

                Ellipse()
                    .fill(faceColor)
                    .overlay {
                        Ellipse().stroke(.black, lineWidth: max(4, side * 0.014))
                    }
                    .frame(width: side * 0.66, height: side * 0.69)
                    .offset(y: side * 0.08)

                faceDetails(side: side)
                    .offset(y: side * 0.08)

                HairFringe(color: hairColor)
                    .frame(width: side * 0.64, height: side * 0.28)
                    .scaleEffect(x: hairScale, y: 1 + clampedMessiness * 0.05)
                    .rotationEffect(.degrees(Double(hairOffset.width / 30)))
                    .offset(
                        x: hairOffset.width * 0.72,
                        y: -side * 0.17
                            + clampedMessiness * side * 0.012
                            + hairOffset.height * 0.42
                    )
                    .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.58), value: hairOffset)

                if isUnknown {
                    Text("?")
                        .font(.system(size: side * 0.35, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 0, x: 5, y: 5)
                        .offset(y: -side * 0.18)
                }

                if clampedWetness > 0.08 {
                    WaterDrops(side: side)
                        .opacity(clampedWetness)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(0.92, contentMode: .fit)
    }

    private var faceColor: Color {
        Color(red: 0.98, green: 0.73, blue: 0.50)
    }

    private var hairColor: Color {
        let wet = Double(clampedWetness)
        return Color(
            red: 0.16 - 0.06 * wet,
            green: 0.10 + 0.02 * wet,
            blue: 0.08 + 0.08 * wet
        )
    }

    @ViewBuilder
    private func faceDetails(side: CGFloat) -> some View {
        VStack(spacing: side * 0.07) {
            HStack(spacing: side * 0.20) {
                eye(side: side)
                eye(side: side)
            }

            Capsule()
                .fill(Color(red: 0.82, green: 0.43, blue: 0.31))
                .frame(width: side * 0.075, height: side * 0.12)

            Capsule()
                .fill(.black)
                .frame(width: side * 0.20, height: side * 0.035)
        }
    }

    private func eye(side: CGFloat) -> some View {
        ZStack {
            Capsule().fill(.white)
            Circle()
                .fill(.black)
                .frame(width: side * 0.047)
        }
        .frame(width: side * 0.105, height: side * 0.075)
        .overlay { Capsule().stroke(.black, lineWidth: max(3, side * 0.009)) }
    }
}

private struct HairCloud: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                Ellipse().fill(color).frame(width: w * 0.70, height: h * 0.90).offset(y: h * 0.04)
                Circle().fill(color).frame(width: h * 0.76).offset(x: -w * 0.30, y: h * 0.04)
                Circle().fill(color).frame(width: h * 0.88).offset(x: -w * 0.15, y: -h * 0.18)
                Circle().fill(color).frame(width: h * 0.95).offset(y: -h * 0.22)
                Circle().fill(color).frame(width: h * 0.88).offset(x: w * 0.17, y: -h * 0.17)
                Circle().fill(color).frame(width: h * 0.76).offset(x: w * 0.31, y: h * 0.05)
            }
            .frame(width: w, height: h)
            .overlay {
                Ellipse().stroke(.black, lineWidth: max(4, w * 0.018))
            }
        }
    }
}

private struct HairFringe: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: -geometry.size.width * 0.055) {
                ForEach(0..<7, id: \.self) { index in
                    Ellipse()
                        .fill(color)
                        .frame(
                            width: geometry.size.width * 0.19,
                            height: geometry.size.height * (index.isMultiple(of: 2) ? 0.95 : 0.72)
                        )
                        .overlay { Ellipse().stroke(.black, lineWidth: 3) }
                }
            }
        }
    }
}

private struct WaterDrops: View {
    let side: CGFloat

    var body: some View {
        ZStack {
            Image(systemName: "drop.fill").offset(x: -side * 0.25, y: -side * 0.16)
            Image(systemName: "drop.fill").offset(x: side * 0.28, y: -side * 0.06)
            Image(systemName: "drop.fill").offset(x: -side * 0.20, y: side * 0.18)
            Image(systemName: "drop.fill").offset(x: side * 0.22, y: side * 0.20)
        }
        .font(.system(size: side * 0.055, weight: .bold))
        .foregroundStyle(Color(red: 0.17, green: 0.65, blue: 0.92))
    }
}
