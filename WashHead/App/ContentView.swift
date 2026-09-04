import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    let modules: AppModules

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

    init(modules: AppModules = .live) {
        self.modules = modules
    }

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
                        if modules.history != nil {
                            mainControlButton("calendar", label: "月曆") {
                                showHistory = true
                            }
                        }

                        if modules.characterEditor != nil {
                            mainControlButton("face.smiling", label: "捏頭") {
                                showCharacterEditor = true
                            }
                        }

                        if modules.settings != nil {
                            mainControlButton("gearshape.fill", label: "設定") {
                                showSettings = true
                            }
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
                modules.wash.makeQuestion(
                    WashQuestionFeatureInput(
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
                )
                .transition(.scale(scale: 0.92).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .background(Color(red: 0.95, green: 0.91, blue: 0.82).ignoresSafeArea())
        .fullScreenCover(isPresented: $isWashing) {
            modules.wash.makeInteraction(
                WashInteractionFeatureInput(
                    isPresented: $isWashing,
                    messinessLevel: messinessLevel,
                    appearance: appearance,
                    trustUser: $trustUser,
                    onAbandoned: abandonWash,
                    onWashed: finishWash
                )
            )
        }
        .sheet(isPresented: $showHistory) {
            if let history = modules.history {
                history.makeView(
                    HistoryFeatureInput(
                        historyJSON: $historyJSON,
                        onRecordsChanged: recordsDidChange
                    )
                )
            }
        }
        .sheet(isPresented: $showCharacterEditor) {
            if let characterEditor = modules.characterEditor {
                characterEditor.makeView(
                    CharacterEditorFeatureInput(
                        skinTone: $skinTone,
                        hairTone: $hairTone,
                        hairStyle: $hairStyle,
                        faceShape: $faceShape,
                        eyeScale: $eyeScale,
                        eyeYOffset: $eyeYOffset,
                        mouthStyle: $mouthStyle
                    )
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            if let settings = modules.settings {
                settings.makeView(
                    SettingsFeatureInput(
                        scheduleJSON: $scheduleJSON,
                        sleepMinuteOfDay: $sleepMinuteOfDay,
                        notificationsEnabled: $notificationsEnabled,
                        trustUser: $trustUser,
                        iconSyncEnabled: $iconSyncEnabled,
                        messinessLevel: messinessLevel,
                        isUnknown: isUnknownToday,
                        reminders: modules.reminders,
                        appIcons: modules.appIcons,
                        onSettingsChanged: refreshSystemFeatures
                    )
                )
            }
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
        case .some(.none), nil: return "洗頭了沒？"
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
        modules.reminders.cancel(currentRecordDate)
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
            await modules.reminders.refresh(
                ReminderRefreshInput(
                    scheduleJSON: currentSchedule,
                    sleepMinuteOfDay: currentSleepTime,
                    historyJSON: currentHistory,
                    isEnabled: remindersEnabled
                )
            )
        }

        if iconSyncEnabled {
            modules.appIcons.sync(
                AppIconState(
                    messinessLevel: messinessLevel,
                    isUnknown: isUnknownToday
                )
            )
        }
    }
}
