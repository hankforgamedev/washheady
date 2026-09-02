import SwiftUI

struct WashInteractionView: View {
    @Binding var isPresented: Bool
    let messinessLevel: Int
    @Binding var trustUser: Bool
    let onWashed: (_ trustedAutomatically: Bool) -> Void

    @State private var showerPosition = CGPoint.zero
    @State private var previousDragPosition: CGPoint?
    @State private var wetProgress: CGFloat = 0
    @State private var reachedGoal = false
    @State private var showConfirmation = false
    @State private var rememberTrust = false

    var body: some View {
        GeometryReader { geometry in
            let hairArea = hairHitArea(in: geometry.size)
            let isOverHair = hairArea.contains(showerPosition)

            ZStack {
                Color(red: 0.82, green: 0.92, blue: 0.95).ignoresSafeArea()

                VStack(spacing: 6) {
                    HStack {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .black))
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                        }
                        .foregroundStyle(.black)
                        .accessibilityLabel("離開洗頭")

                        Spacer()

                        Text(wetProgress < 0.82 ? "把蓮蓬頭拖到頭髮上" : "差一點，再淋一下")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, max(8, geometry.safeAreaInsets.top))

                    CharacterHeadView(messinessLevel: messinessLevel, wetProgress: Double(wetProgress))
                        .frame(height: geometry.size.height * 0.68)
                        .frame(maxWidth: .infinity)

                    Text(isOverHair ? "對，就是那裡。" : "抓住藍色蓮蓬頭")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.68))
                        .padding(.bottom, max(16, geometry.safeAreaInsets.bottom))
                }

                if isOverHair {
                    WaterStream()
                        .frame(width: 92, height: 150)
                        .position(x: showerPosition.x, y: showerPosition.y + 92)
                        .allowsHitTesting(false)
                }

                ShowerHandle(isActive: isOverHair)
                    .frame(width: 92, height: 110)
                    .position(showerPosition)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("washSpace"))
                            .onChanged { value in
                                handleDrag(value.location, in: geometry.size)
                            }
                            .onEnded { _ in
                                previousDragPosition = nil
                            }
                    )
                    .accessibilityLabel("可拖曳的蓮蓬頭")
            }
            .coordinateSpace(name: "washSpace")
            .onAppear {
                if showerPosition == .zero {
                    showerPosition = CGPoint(x: geometry.size.width * 0.80, y: geometry.size.height * 0.72)
                }
            }
        }
        .sheet(isPresented: $showConfirmation) {
            confirmationSheet
                .presentationDetents([.height(330)])
                .interactiveDismissDisabled()
        }
    }

    private var confirmationSheet: some View {
        VStack(spacing: 20) {
            Text("你真的洗完了嗎？")
                .font(.system(size: 26, weight: .black, design: .rounded))

            Toggle("不要再提醒我，我很誠實", isOn: $rememberTrust)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .toggleStyle(.switch)

            Button("洗完了！") {
                trustUser = rememberTrust
                showConfirmation = false
                onWashed(rememberTrust)
                isPresented = false
            }
            .font(.system(size: 19, weight: .black, design: .rounded))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            Button("其實還沒") {
                showConfirmation = false
                isPresented = false
            }
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
        }
        .padding(24)
    }

    private func hairHitArea(in size: CGSize) -> CGRect {
        CGRect(x: size.width * 0.10, y: size.height * 0.10, width: size.width * 0.80, height: size.height * 0.50)
    }

    private func handleDrag(_ location: CGPoint, in size: CGSize) {
        let clamped = CGPoint(
            x: min(max(46, location.x), size.width - 46),
            y: min(max(64, location.y), size.height - 64)
        )

        if hairHitArea(in: size).contains(clamped), !reachedGoal {
            let distance: CGFloat
            if let previousDragPosition {
                distance = hypot(clamped.x - previousDragPosition.x, clamped.y - previousDragPosition.y)
            } else {
                distance = 0
            }
            wetProgress = min(1, wetProgress + max(0.012, distance / 780))
        }

        showerPosition = clamped
        previousDragPosition = clamped

        if wetProgress >= 1, !reachedGoal {
            reachedGoal = true
            if trustUser {
                onWashed(true)
                isPresented = false
            } else {
                showConfirmation = true
            }
        }
    }
}

private struct ShowerHandle: View {
    let isActive: Bool

    var body: some View {
        VStack(spacing: -4) {
            Capsule()
                .fill(Color(red: 0.10, green: 0.55, blue: 0.88))
                .frame(width: 74, height: 43)
                .overlay {
                    HStack(spacing: 7) {
                        ForEach(0..<4, id: \.self) { _ in
                            Circle().fill(.white).frame(width: 6, height: 6)
                        }
                    }
                }
            Capsule()
                .fill(Color(red: 0.08, green: 0.38, blue: 0.65))
                .frame(width: 25, height: 70)
        }
        .rotationEffect(.degrees(-25))
        .scaleEffect(isActive ? 1.08 : 1)
        .shadow(color: .black.opacity(0.22), radius: 8, y: 5)
        .animation(.easeOut(duration: 0.15), value: isActive)
    }
}

private struct WaterStream: View {
    var body: some View {
        HStack(spacing: 9) {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(Color(red: 0.12, green: 0.62, blue: 0.94).opacity(0.72))
                    .frame(width: 7, height: index.isMultiple(of: 2) ? 138 : 112)
            }
        }
        .rotationEffect(.degrees(-7))
    }
}
