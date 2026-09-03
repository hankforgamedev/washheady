import SwiftUI

struct WashInteractionView: View {
    @Binding var isPresented: Bool
    let messinessLevel: Int
    @Binding var trustUser: Bool
    let onAbandoned: () -> Void
    let onWashed: (_ trustedAutomatically: Bool) -> Void

    @State private var wateringCanPosition = CGPoint.zero
    @State private var previousDragPosition: CGPoint?
    @State private var wetProgress: CGFloat = 0
    @State private var reachedGoal = false
    @State private var showConfirmation = false
    @State private var showExitConfirmation = false
    @State private var rememberTrust = false

    var body: some View {
        GeometryReader { geometry in
            let hairArea = hairHitArea(in: geometry.size)
            let isOverHair = hairArea.contains(wateringCanPosition)

            ZStack {
                Color(red: 0.82, green: 0.92, blue: 0.95).ignoresSafeArea()

                VStack(spacing: 6) {
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                                showExitConfirmation = true
                            }
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

                        Text(wetProgress < 0.82 ? "把澆水蓮蓬頭拖到頭髮上" : "差一點，再澆一下")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, max(8, geometry.safeAreaInsets.top))

                    CharacterHeadView(messinessLevel: messinessLevel, wetProgress: Double(wetProgress))
                        .frame(height: geometry.size.height * 0.68)
                        .frame(maxWidth: .infinity)

                    Text(isOverHair ? "對，就是那裡。" : "抓住綠色澆水蓮蓬頭")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.68))
                        .padding(.bottom, max(16, geometry.safeAreaInsets.bottom))
                }

                if isOverHair {
                    WaterStream()
                        .frame(width: 86, height: 146)
                        .position(x: wateringCanPosition.x - 54, y: wateringCanPosition.y + 72)
                        .allowsHitTesting(false)
                }

                WateringCan(isActive: isOverHair)
                    .frame(width: 126, height: 100)
                    .position(wateringCanPosition)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("washSpace"))
                            .onChanged { value in
                                handleDrag(value.location, in: geometry.size)
                            }
                            .onEnded { _ in
                                previousDragPosition = nil
                            }
                    )
                    .accessibilityLabel("可拖曳、外觀像澆花器的蓮蓬頭")

                if showExitConfirmation {
                    exitConfirmationDialog
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                        .zIndex(5)
                }
            }
            .coordinateSpace(name: "washSpace")
            .onAppear {
                if wateringCanPosition == .zero {
                    wateringCanPosition = CGPoint(
                        x: geometry.size.width * 0.78,
                        y: geometry.size.height * 0.76
                    )
                }
            }
        }
        .sheet(isPresented: $showConfirmation) {
            confirmationSheet
                .presentationDetents([.height(330)])
                .interactiveDismissDisabled()
        }
    }

    private var exitConfirmationDialog: some View {
        ZStack {
            Color.black.opacity(0.24).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 15) {
                Text("還沒洗完喔")
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Text("現在離開，今天就會記成沒洗頭。確定嗎？")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 11) {
                    exitDialogButton(
                        title: "確定離開",
                        foreground: .black,
                        background: .white
                    ) {
                        onAbandoned()
                        isPresented = false
                    }

                    exitDialogButton(
                        title: "繼續澆",
                        foreground: .white,
                        background: Color(red: 0.10, green: 0.62, blue: 0.34)
                    ) {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showExitConfirmation = false
                        }
                    }
                }
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

    private func exitDialogButton(
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
        CGRect(
            x: size.width * 0.10,
            y: size.height * 0.10,
            width: size.width * 0.80,
            height: size.height * 0.50
        )
    }

    private func handleDrag(_ location: CGPoint, in size: CGSize) {
        let clamped = CGPoint(
            x: min(max(63, location.x), size.width - 63),
            y: min(max(54, location.y), size.height - 54)
        )

        if hairHitArea(in: size).contains(clamped), !reachedGoal {
            let distance: CGFloat
            if let previousDragPosition {
                distance = hypot(
                    clamped.x - previousDragPosition.x,
                    clamped.y - previousDragPosition.y
                )
            } else {
                distance = 0
            }
            wetProgress = min(1, wetProgress + max(0.012, distance / 780))
        }

        wateringCanPosition = clamped
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

private struct WateringCan: View {
    let isActive: Bool

    var body: some View {
        Image(systemName: "wateringcan.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(
                isActive
                    ? Color(red: 0.10, green: 0.62, blue: 0.34)
                    : Color(red: 0.15, green: 0.48, blue: 0.28)
            )
            .overlay {
                Image(systemName: "drop.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
                    .offset(x: 14, y: 6)
            }
            .rotationEffect(.degrees(isActive ? -12 : -5))
            .scaleEffect(isActive ? 1.07 : 1)
            .shadow(color: .black.opacity(0.24), radius: 8, y: 5)
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
        .rotationEffect(.degrees(7))
    }
}
