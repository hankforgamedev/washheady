import SwiftUI

enum WashStatus: String {
    case none
    case washed
    case notWashed
    case unknown
}

struct ContentView: View {
    @AppStorage("messinessLevel") private var messinessLevel = 0
    @AppStorage("lastStatus") private var lastStatusRaw = WashStatus.none.rawValue
    @AppStorage("lastStatusDate") private var lastStatusDate = 0.0
    @AppStorage("trustUser") private var trustUser = false

    @State private var isWashing = false
    @State private var characterLine = "欸 Hank，我們今天有要洗頭嗎？"

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 14) {
                Text(characterLine)
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 62)
                    .padding(.horizontal, 8)
                    .accessibilityAddTraits(.isHeader)

                CharacterHeadView(
                    messinessLevel: messinessLevel,
                    isUnknown: lastStatusRaw == WashStatus.unknown.rawValue
                )
                .frame(height: max(360, geometry.size.height * 0.62))
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Hank 的大頭，頭髮澎度 \(messinessLevel)")

                HStack(spacing: 12) {
                    ChoiceButton(title: "要啊", foreground: .white, background: .black) {
                        isWashing = true
                    }

                    ChoiceButton(title: "今天不要", foreground: .black, background: .white) {
                        skipWash()
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, max(12, geometry.safeAreaInsets.bottom))
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color(red: 0.95, green: 0.91, blue: 0.82).ignoresSafeArea())
        .fullScreenCover(isPresented: $isWashing) {
            WashInteractionView(
                isPresented: $isWashing,
                messinessLevel: messinessLevel,
                trustUser: $trustUser,
                onWashed: finishWash
            )
        }
    }

    private func skipWash() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.58)) {
            messinessLevel = min(3, messinessLevel + 1)
        }
        lastStatusRaw = WashStatus.notWashed.rawValue
        lastStatusDate = Date().timeIntervalSince1970
        characterLine = "噢耶，賺到一點時間，我可以躺床上看平板。"
    }

    private func finishWash(trustedAutomatically: Bool) {
        messinessLevel = 0
        lastStatusRaw = WashStatus.washed.rawValue
        lastStatusDate = Date().timeIntervalSince1970
        characterLine = trustedAutomatically ? "行，我信你。" : "好，現在頭髮很乖。"
    }
}

private struct ChoiceButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(foreground)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.black, lineWidth: 3)
                }
        }
        .buttonStyle(.plain)
    }
}
