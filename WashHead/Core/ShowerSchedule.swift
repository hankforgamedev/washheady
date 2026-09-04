import Foundation

struct DaySchedule: Codable, Equatable, Identifiable {
    let weekday: Int
    var isEnabled: Bool
    var minuteOfDay: Int

    var id: Int { weekday }
}

enum ShowerScheduleCodec {
    static var defaults: [DaySchedule] {
        [2, 3, 4, 5, 6, 7, 1].map {
            DaySchedule(weekday: $0, isEnabled: true, minuteOfDay: 21 * 60 + 30)
        }
    }

    static func decode(_ json: String) -> [DaySchedule] {
        guard let data = json.data(using: .utf8),
              let schedules = try? JSONDecoder().decode([DaySchedule].self, from: data),
              schedules.count == 7 else {
            return defaults
        }
        return schedules
    }

    static func encode(_ schedules: [DaySchedule]) -> String {
        guard let data = try? JSONEncoder().encode(schedules),
              let json = String(data: data, encoding: .utf8) else {
            return ""
        }
        return json
    }
}
