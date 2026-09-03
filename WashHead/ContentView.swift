import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(WashHistory.storageKey) private var historyJSON = "{}"
    @AppStorage("lastStatus") private var lastStatusRaw = WashStatus.none.rawValue
    @AppStorage("lastStatusDate") private var lastStatusDate = 0.0
    @AppStorage("trustUser") private var trustUser = false
    @AppStorage("showerScheduleJSON") private var scheduleJSON = ""
    @AppStorage("sleepMinuteOfDay") private var sleepMinuteOfDay = 60
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("iconSyncEnabled") private var iconSyncEnabled = false

    @AppStorage("skinTone") private var skinTone = 0
    @AppStorage("hairTone") private var hairTone = 0
    @AppStorage("hairStyle") private var hairStyle = 0
    @AppStorage("faceShape") private var faceShape = 0
    @AppStorage("eyeScale") private var eyeScale = 1.0
    @AppStorage("eyeYOffset") private var eyeYOffset = 0.0
    @AppStorage("mouthStyle") private var mouthStyle = 0

    @State private var isWashing = false
    @State private var showDailyQuestion = true
    @State private var characterLine: String?
    @State private var showHistory = false
    @State private var showCharacterEditor = false
    @State private var showSettings = false

    private var messinessLevel: Int {
        WashHistory.messinessLevel(in: historyJSON)
    }

    private var currentRecordDate: Date {
        WashHistory.effectiveRecordDate(
            sleepMinuteOfDay: sleepMinuteOfDay
        )
    }

    private var isUnknownToday: Bool {
        let status = WashHistory.status(on: currentRecordDate, in: historyJSON)
        return status == .unknown
            || (status == nil && WashHistory.hasReachedUnknownTime(sleepMinuteOfDay: sleepMinuteOfDay))
    }

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
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 8) {
                    Text(characterLine ?? headline)
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 58)
                        .padding(.horizontal, 8)
                        .accessibilityAddTraits(.isHeader)

                    CharacterHeadView(
                        messinessLevel: messinessLevel,
                        isUnknown: isUnknownToday,
                        appearance: appearance
                    )
                    .frame(height: max(390, geometry.size.height * 0.65))
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            showDailyQuestion = true
                        }
                    }
                    .accessibilityLabel("Hank 的大頭。點一下回答今天要不要洗頭。")

                    HStack(spacing: 16) {
                        mainControlButton("calendar", label: "月曆") {
                            showHistory = true
                        }
                        mainControlButton("face.smiling", label: "捏頭") {
                            showCharacterEditor = true
                        }
                        mainControlButton("gearshape.fill", label: "設定") {
                            showSettings = true
                        }
                    }
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
                appearance: appearance,
                trustUser: $trustUser,
                onAbandoned: abandonWash,
                onWashed: finishWash
            )
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(historyJSON: $historyJSON, onRecordsChanged: recordsDidChange)
        }
        .sheet(isPresented: $showCharacterEditor) {
            CharacterEditorView(
                skinTone: $skinTone,
                hairTone: $hairTone,
                hairStyle: $hairStyle,
                faceShape: $faceShape,
                eyeScale: $eyeScale,
                eyeYOffset: $eyeYOffset,
                mouthStyle: $mouthStyle
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                scheduleJSON: $scheduleJSON,
                sleepMinuteOfDay: $sleepMinuteOfDay,
                notificationsEnabled: $notificationsEnabled,
                trustUser: $trustUser,
                iconSyncEnabled: $iconSyncEnabled,
                messinessLevel: messinessLevel,
                isUnknown: isUnknownToday,
                onSettingsChanged: refreshSystemFeatures
            )
        }
        .onAppear {
            migrateLegacyRecordIfNeeded()
            refreshDailyState()
            handlePendingNotificationAction()
            refreshSystemFeatures()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            refreshDailyState()
            handlePendingNotificationAction()
            refreshSystemFeatures()
        }
    }

    private var headline: String {
        switch WashHistory.status(on: currentRecordDate, in: historyJSON) {
        case .some(.washed): return "今天有洗。"
        case .some(.notWashed): return "今天沒洗，也很好。"
        case .some(.unknown): return "我不確定。"
        case .some(.none), .none: return "洗頭了沒？"
        }
    }

    private func mainControlButton(
        _ systemName: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemName)
                    .font(.system(size: 19, weight: .black))
                Text(label)
                    .font(.system(size: 12, weight: .black, design: .rounded))
            }
            .frame(width: 72, height: 56)
            .background(.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(.black.opacity(0.14), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.black)
        .accessibilityLabel(label)
    }

    private func skipWash() {
        record(.notWashed)
        characterLine = "噢耶，賺到一點時間，我可以躺床上看平板。"
    }

    private func abandonWash() {
        record(.notWashed)
        characterLine = "好，今天算沒洗完。"
    }

    private func finishWash(trustedAutomatically: Bool) {
        record(.washed)
        characterLine = trustedAutomatically ? "行，我信你。" : "好，現在頭髮很乖。"
    }

    private func record(_ status: WashStatus) {
        historyJSON = WashHistory.updating(historyJSON, status: status, on: currentRecordDate)
        lastStatusRaw = status.rawValue
        lastStatusDate = Date().timeIntervalSince1970
        NotificationManager.cancel(for: currentRecordDate)
        refreshSystemFeatures()
    }

    private func recordsDidChange() {
        characterLine = nil
        refreshDailyState()
        refreshSystemFeatures()
    }

    private func migrateLegacyRecordIfNeeded() {
        guard WashHistory.records(from: historyJSON).isEmpty,
              lastStatusDate > 0 else {
            return
        }

        let status = WashStatus(rawValue: lastStatusRaw)
            ?? (lastStatusRaw == "notWashed" ? .notWashed : nil)
        guard let status, status != .none else { return }

        historyJSON = WashHistory.updating(
            historyJSON,
            status: status,
            on: Date(timeIntervalSince1970: lastStatusDate)
        )
    }

    private func refreshDailyState() {
        guard WashHistory.status(on: currentRecordDate, in: historyJSON) == nil,
              WashHistory.hasReachedUnknownTime(sleepMinuteOfDay: sleepMinuteOfDay) else {
            return
        }

        historyJSON = WashHistory.updating(historyJSON, status: .unknown, on: currentRecordDate)
        lastStatusRaw = WashStatus.unknown.rawValue
        lastStatusDate = Date().timeIntervalSince1970
    }

    private func handlePendingNotificationAction() {
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: "pendingOpenWash") {
            defaults.set(false, forKey: "pendingOpenWash")
            showDailyQuestion = false
            isWashing = true
        }

        if defaults.bool(forKey: "pendingShowQuestion") {
            defaults.set(false, forKey: "pendingShowQuestion")
            showDailyQuestion = true
        }
    }

    private func refreshSystemFeatures() {
        let currentHistory = historyJSON
        let currentSchedule = scheduleJSON
        let currentSleepTime = sleepMinuteOfDay
        let remindersEnabled = notificationsEnabled

        Task {
            await NotificationManager.refresh(
                scheduleJSON: currentSchedule,
                sleepMinuteOfDay: currentSleepTime,
                historyJSON: currentHistory,
                isEnabled: remindersEnabled
            )
        }

        if iconSyncEnabled {
            AppIconManager.sync(
                messinessLevel: messinessLevel,
                isUnknown: isUnknownToday
            )
        }
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
