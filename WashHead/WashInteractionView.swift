import SwiftUI

struct WashInteractionView: View {
    @Binding var isPresented: Bool
    let messinessLevel: Int
    @Binding var trustUser: Bool
    let onWashed: (_ trustedAutomatically: Bool) -> Void

    @State private var previousDragPosition: CGPoint?
    @State private var touchPosition = CGPoint.zero
    @State private var hairOffset = CGSize.zero
    @State private var wetProgress: CGFloat = 0
    @State private var isTouchingHair = false
    @State private var reachedGoal = false
    @State private var showConfirmation = false
    @State private var rememberTrust = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.82, green: 0.92, blue: 0.95).ignoresSafeArea()

                VStack(spacing: 4) {
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

                        Text(instruction)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, max(8, geometry.safeAreaInsets.top))

                    GeometryReader { headGeometry in
                        ZStack {
                            CharacterHeadView(
                                messinessLevel: messinessLevel,
                                wetProgress: Double(wetProgress),
                                hairOffset: hairOffset
                            )
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { value in
                                        handleHairDrag(value.location, in: headGeometry.size)
                                    }
                                    .onEnded { _ in
                                        endHairDrag()
                                    }
                            )
                            .accessibilityLabel("可直接搓揉的頭髮")

                            if isTouchingHair {
                                FingerWaterEffect()
                                    .frame(width: 92, height: 92)
                                    .position(touchPosition)
                                    .transition(.scale.combined(with: .opacity))
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .frame(height: geometry.size.height * 0.74)

                    Text(isTouchingHair ? "對，就直接搓它。" : "不用找工具，手指放上去。")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.66))
                        .padding(.bottom, max(16, geometry.safeAreaInsets.bottom))
                }
            }
        }
        .sheet(isPresented: $showConfirmation) {
            confirmationSheet
                .presentationDetents([.height(330)])
                .interactiveDismissDisabled()
        }
    }

    private var instruction: String {
        if wetProgress > 0.82 {
            return "差一點，再搓兩下"
        }
        if wetProgress > 0.22 {
            return "有濕，繼續玩頭髮"
        }
        return "直接把頭髮搓濕"
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

    private func handleHairDrag(_ location: CGPoint, in size: CGSize) {
        let isInsideHair = location.y <= size.height * 0.60
            && location.x >= 0
            && location.x <= size.width

        touchPosition = location
        isTouchingHair = isInsideHair

        guard isInsideHair, !reachedGoal else {
            previousDragPosition = location
            return
        }

        let distance: CGFloat
        if let previousDragPosition {
            distance = hypot(
                location.x - previousDragPosition.x,
                location.y - previousDragPosition.y
            )
        } else {
            distance = 0
        }

        hairOffset = CGSize(
            width: (location.x - size.width / 2) * 0.085,
            height: (location.y - size.height * 0.24) * 0.045
        )
        wetProgress = min(1, wetProgress + max(0.010, distance / 620))
        previousDragPosition = location

        if wetProgress >= 1 {
            reachedGoal = true
            if trustUser {
                onWashed(true)
                isPresented = false
            } else {
                showConfirmation = true
            }
        }
    }

    private func endHairDrag() {
        previousDragPosition = nil
        isTouchingHair = false
        withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
            hairOffset = .zero
        }
    }
}

private struct FingerWaterEffect: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(red: 0.10, green: 0.60, blue: 0.92).opacity(0.55),
                    lineWidth: 5
                )
                .frame(width: 66, height: 66)

            Image(systemName: "drop.fill")
                .offset(x: -30, y: 28)
            Image(systemName: "drop.fill")
                .offset(x: 31, y: 16)
            Image(systemName: "drop.fill")
                .offset(x: 7, y: -34)
        }
        .font(.system(size: 18, weight: .bold))
        .foregroundStyle(Color(red: 0.10, green: 0.60, blue: 0.92))
        .shadow(color: .white.opacity(0.7), radius: 2)
    }
}
