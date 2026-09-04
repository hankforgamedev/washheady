import SwiftUI

struct CharacterEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var skinTone: Int
    @Binding var hairTone: Int
    @Binding var hairStyle: Int
    @Binding var faceShape: Int
    @Binding var eyeScale: Double
    @Binding var eyeYOffset: Double
    @Binding var mouthStyle: Int

    private var appearance: CharacterAppearance {
        CharacterAppearance(
            skinTone: skinTone,
            hairTone: hairTone,
            hairStyle: hairStyle,
            faceShape: faceShape,
            eyeScale: eyeScale,
            eyeYOffset: eyeYOffset,
            mouthStyle: mouthStyle
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    CharacterHeadView(messinessLevel: 0, appearance: appearance)
                        .frame(height: 310)
                        .frame(maxWidth: .infinity)
                        .background(
                            Color(red: 0.95, green: 0.91, blue: 0.82),
                            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                        )

                    editorSection("膚色") {
                        paletteRow(
                            selection: $skinTone,
                            colors: [
                                Color(red: 0.98, green: 0.73, blue: 0.50),
                                Color(red: 0.82, green: 0.55, blue: 0.36),
                                Color(red: 0.61, green: 0.37, blue: 0.25),
                                Color(red: 0.36, green: 0.22, blue: 0.17)
                            ]
                        )
                    }

                    editorSection("髮色") {
                        paletteRow(
                            selection: $hairTone,
                            colors: [
                                Color(red: 0.16, green: 0.10, blue: 0.08),
                                Color(red: 0.38, green: 0.20, blue: 0.08),
                                Color(red: 0.06, green: 0.05, blue: 0.05),
                                Color(red: 0.67, green: 0.48, blue: 0.18),
                                Color(red: 0.35, green: 0.12, blue: 0.32)
                            ]
                        )
                    }

                    editorSection("輪廓") {
                        Picker("臉型", selection: $faceShape) {
                            Text("圓").tag(0)
                            Text("長").tag(1)
                            Text("寬").tag(2)
                        }
                        .pickerStyle(.segmented)

                        Picker("髮型", selection: $hairStyle) {
                            Text("澎").tag(0)
                            Text("平").tag(1)
                            Text("炸").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }

                    editorSection("五官") {
                        labeledSlider("眼睛大小", value: $eyeScale, range: 0.75...1.35)
                        labeledSlider("眼睛高度", value: $eyeYOffset, range: -0.06...0.06)

                        Picker("嘴巴", selection: $mouthStyle) {
                            Text("無言").tag(0)
                            Text("蛤").tag(1)
                            Text("厭世").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(18)
            }
            .background(Color(red: 0.91, green: 0.94, blue: 0.90))
            .navigationTitle("捏一顆頭")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .fontWeight(.black)
                }
            }
        }
    }

    private func editorSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .rounded))
            content()
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func paletteRow(selection: Binding<Int>, colors: [Color]) -> some View {
        HStack(spacing: 14) {
            ForEach(colors.indices, id: \.self) { index in
                Button {
                    selection.wrappedValue = index
                } label: {
                    Circle()
                        .fill(colors[index])
                        .frame(width: 42, height: 42)
                        .overlay {
                            Circle()
                                .stroke(
                                    selection.wrappedValue == index ? Color.green : Color.black.opacity(0.18),
                                    lineWidth: selection.wrappedValue == index ? 4 : 1
                                )
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func labeledSlider(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Slider(value: value, in: range)
                .tint(Color(red: 0.10, green: 0.62, blue: 0.34))
        }
    }
}
