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
    @State private var showDailyQuestion = true
    @State private var characterLine: String?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 8) {
                    Text(characterLine ?? "洗頭了沒？")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 58)
                        .padding(.horizontal, 8)
                        .accessibilityAddTraits(.isHeader)

                    CharacterHeadView(
                        messinessLevel: messinessLevel,
                        isUnknown: lastStatusRaw == WashStatus.unknown.rawValue
                    )
                    .frame(height: max(410, geometry.size.height * 0.70))
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            showDailyQuestion = true
                        }
                    }
                    .accessibilityLabel("Hank 的大頭，頭髮澎度 \(messinessLevel)。點一下回答今天要不要洗頭。")

                    Text("點一下頭髮，再決定一次")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.55))
                        .padding(.bottom, max(14, geometry.safeAreaInsets.bottom))
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .blur(radius: showDailyQuestion ? 1.6 : 0)
            }

            if showDailyQuestion {
                WashQuestionDialog(
                    onClose: {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showDailyQuestion = false
                        }
                    },
                    onSkip: {
                        skipWash()
                        withAnimation(.easeOut(duration: 0.18)) {
                            showDailyQuestion = false
                        }
                    },
                    onWash: {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showDailyQuestion = false
                        }
                        isWashing = true
                    }
                )
                .transition(.scale(scale: 0.92).combined(with: .opacity))
                .zIndex(2)
            }
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

private struct WashQuestionDialog: View {
    let onClose: () -> Void
    let onSkip: () -> Void
    let onWash: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.20).ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Text("今天的重大問題")
                        .font(.system(size: 17, weight: .black, design: .rounded))

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .black))
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.07))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.black.opacity(0.62))
                    .accessibilityLabel("關閉")
                }

                Text("欸 Hank，我們今天有要洗頭嗎？")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)

                Text("不用表現良好，選一個就好。")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.62))

                HStack(spacing: 11) {
                    dialogButton(
                        title: "今天不要",
                        foreground: .black,
                        background: .white,
                        action: onSkip
                    )

                    dialogButton(
                        title: "要啊",
                        foreground: .white,
                        background: Color(red: 0.10, green: 0.62, blue: 0.34),
                        action: onWash
                    )
                }
                .padding(.top, 4)
            }
            .padding(22)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.black.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.26), radius: 24, y: 12)
            .padding(.horizontal, 27)
        }
    }

    private func dialogButton(
        title: String,
        foreground: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(foreground)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.black.opacity(0.18), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
    }
}
