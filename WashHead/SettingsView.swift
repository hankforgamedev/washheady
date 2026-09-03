import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var scheduleJSON: String
    @Binding var sleepMinuteOfDay: Int
    @Binding var notificationsEnabled: Bool
    @Binding var trustUser: Bool
    @Binding var iconSyncEnabled: Bool

    let messinessLevel: Int
    let isUnknown: Bool
    let onSettingsChanged: () -> Void

    @State private var schedules: [DaySchedule]
    @State private var notificationMessage = ""

    init(
        scheduleJSON: Binding<String>,
        sleepMinuteOfDay: Binding<Int>,
        notificationsEnabled: Binding<Bool>,
        trustUser: Binding<Bool>,
        iconSyncEnabled: Binding<Bool>,
        messinessLevel: Int,
        isUnknown: Bool,
        onSettingsChanged: @escaping () -> Void
    ) {
        _scheduleJSON = scheduleJSON
        _sleepMinuteOfDay = sleepMinuteOfDay
        _notificationsEnabled = notificationsEnabled
        _trustUser = trustUser
        _iconSyncEnabled = iconSyncEnabled
        self.messinessLevel = messinessLevel
        self.isUnknown = isUnknown
        self.onSettingsChanged = onSettingsChanged
        _schedules = State(initialValue: ShowerScheduleCodec.decode(scheduleJSON.wrappedValue))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(notificationsEnabled ? "重新確認通知權限" : "啟用通知") {
                        Task {
                            let granted = await NotificationManager.requestAuthorization()
                            notificationsEnabled = granted
                            notificationMessage = granted
                                ? "可以了。通知會按照下面七天的時間出現。"
                                : "通知沒有開啟；可以稍後到 iPhone 設定修改。"
                            persistAndRefresh()
                        }
                    }

                    if !notificationMessage.isEmpty {
                        Text(notificationMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("通知")
                } footer: {
                    Text("通知上可以直接選「要／不要」；選「要」會打開澆水互動。")
                }

                Section("每週平常洗澡時間") {
                    ForEach($schedules) { $schedule in
                        HStack {
                            Toggle(dayName(schedule.weekday), isOn: $schedule.isEnabled)
                                .fontWeight(.bold)

                            DatePicker(
                                "",
                                selection: minuteBinding(for: $schedule),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .disabled(!schedule.isEnabled)
                        }
                    }
                }

                Section {
                    DatePicker(
                        "平常睡覺時間",
                        selection: sleepTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                } footer: {
                    Text("睡前 10 分鐘仍沒有紀錄，頭會進入「我不知道」狀態。")
                }

                Section("信任") {
                    Toggle("澆完後直接相信我", isOn: $trustUser)
                }

                Section {
                    Toggle("讓桌面圖示跟著頭髮狀態", isOn: $iconSyncEnabled)

                    Button("現在同步一次 App icon") {
                        AppIconManager.sync(
                            messinessLevel: messinessLevel,
                            isUnknown: isUnknown
                        )
                    }
                    .disabled(!UIApplication.shared.supportsAlternateIcons)
                } header: {
                    Text("動態 App icon")
                } footer: {
                    Text("iOS 會顯示系統確認視窗；目前提供乾淨、澎、最大與問號四種圖示。")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        persistAndRefresh()
                        dismiss()
                    }
                    .fontWeight(.black)
                }
            }
            .onChange(of: schedules) { _, _ in
                scheduleJSON = ShowerScheduleCodec.encode(schedules)
            }
            .onDisappear(perform: persistAndRefresh)
        }
    }

    private var sleepTimeBinding: Binding<Date> {
        Binding(
            get: { date(for: sleepMinuteOfDay) },
            set: { sleepMinuteOfDay = minuteOfDay(for: $0) }
        )
    }

    private func minuteBinding(for schedule: Binding<DaySchedule>) -> Binding<Date> {
        Binding(
            get: { date(for: schedule.wrappedValue.minuteOfDay) },
            set: { schedule.wrappedValue.minuteOfDay = minuteOfDay(for: $0) }
        )
    }

    private func date(for minuteOfDay: Int) -> Date {
        Calendar.current.date(
            bySettingHour: minuteOfDay / 60,
            minute: minuteOfDay % 60,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private func minuteOfDay(for date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private func dayName(_ weekday: Int) -> String {
        switch weekday {
        case 1: return "週日"
        case 2: return "週一"
        case 3: return "週二"
        case 4: return "週三"
        case 5: return "週四"
        case 6: return "週五"
        default: return "週六"
        }
    }

    private func persistAndRefresh() {
        scheduleJSON = ShowerScheduleCodec.encode(schedules)
        onSettingsChanged()
    }
}
