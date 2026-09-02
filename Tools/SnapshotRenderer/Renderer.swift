import AppKit
import SwiftUI

private struct SnapshotMainScreen: View {
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.91, blue: 0.82)

            VStack(spacing: 8) {
                Text("洗頭了沒？")
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 58)
                    .padding(.horizontal, 8)

                CharacterHeadView(messinessLevel: 0)
                    .frame(height: 590)
                    .frame(maxWidth: .infinity)

                Text("點一下頭髮，再決定一次")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.55))
            }
            .padding(.horizontal, 18)
            .padding(.top, 46)
            .padding(.bottom, 25)
            .blur(radius: 1.6)

            Color.black.opacity(0.20)

            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Text("今天的重大問題")
                        .font(.system(size: 17, weight: .black, design: .rounded))

                    Spacer()

                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .black))
                        .frame(width: 30, height: 30)
                        .background(Color.black.opacity(0.07))
                        .clipShape(Circle())
                        .foregroundStyle(.black.opacity(0.62))
                }

                Text("欸 Hank，我們今天有要洗頭嗎？")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)

                Text("不用表現良好，選一個就好。")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.62))

                HStack(spacing: 11) {
                    snapshotButton(
                        title: "今天不要",
                        foreground: .black,
                        background: .white
                    )

                    snapshotButton(
                        title: "要啊",
                        foreground: .white,
                        background: Color(red: 0.12, green: 0.54, blue: 0.86)
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
        .frame(width: 393, height: 852)
    }

    private func snapshotButton(
        title: String,
        foreground: Color,
        background: Color
    ) -> some View {
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
}

@main
struct SnapshotRenderer {
    @MainActor
    static func main() throws {
        let outputPath = ProcessInfo.processInfo.environment["SNAPSHOT_OUTPUT"]
            ?? "docs/screenshots/main.png"
        let renderer = ImageRenderer(content: SnapshotMainScreen())
        renderer.proposedSize = ProposedViewSize(width: 393, height: 852)
        renderer.scale = 3

        guard let image = renderer.cgImage else {
            throw SnapshotError.renderFailed
        }

        let bitmap = NSBitmapImageRep(cgImage: image)
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw SnapshotError.pngEncodingFailed
        }

        try data.write(to: URL(fileURLWithPath: outputPath), options: .atomic)
    }
}

private enum SnapshotError: Error {
    case renderFailed
    case pngEncodingFailed
}
