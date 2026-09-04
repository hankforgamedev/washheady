import SwiftUI

struct WashQuestionView: View {
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
