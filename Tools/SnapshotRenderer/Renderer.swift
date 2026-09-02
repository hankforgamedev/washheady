import AppKit
import SwiftUI

private struct SnapshotMainScreen: View {
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.91, blue: 0.82)

            VStack(spacing: 14) {
                Text("欸 Hank，我們今天有要洗頭嗎？")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 62)
                    .padding(.horizontal, 8)

                CharacterHeadView(messinessLevel: 0)
                    .frame(height: 490)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 12) {
                    snapshotButton(
                        title: "要啊",
                        foreground: .white,
                        background: .black
                    )

                    snapshotButton(
                        title: "今天不要",
                        foreground: .black,
                        background: .white
                    )
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 18)
            .padding(.top, 58)
            .padding(.bottom, 34)
        }
        .frame(width: 393, height: 852)
    }

    private func snapshotButton(
        title: String,
        foreground: Color,
        background: Color
    ) -> some View {
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
