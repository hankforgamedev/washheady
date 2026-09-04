import Foundation

enum WashHistory {
    static let storageKey = "washHistoryJSON"

    static func records(from json: String) -> [String: WashStatus] {
        guard let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: WashStatus].self, from: data) else {
            return [:]
        }
        return decoded
    }

    static func json(from records: [String: WashStatus]) -> String {
        guard let data = try? JSONEncoder().encode(records),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    static func updating(
        _ json: String,
        status: WashStatus?,
        on date: Date,
        calendar: Calendar = .current
    ) -> String {
        var records = records(from: json)
        let key = dayKey(for: date, calendar: calendar)
        records[key] = status
        return self.json(from: records)
    }

    static func status(
        on date: Date,
        in json: String,
        calendar: Calendar = .current
    ) -> WashStatus? {
        records(from: json)[dayKey(for: date, calendar: calendar)]
    }

    static func messinessLevel(
        in json: String,
        through date: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
        let ordered = records(from: json)
            .compactMap { key, status -> (Date, WashStatus)? in
                guard let recordDate = WashHistory.date(from: key, calendar: calendar),
                      recordDate <= end else {
                    return nil
                }
                return (recordDate, status)
            }
            .sorted { $0.0 < $1.0 }

        var missedWashes = 0
        for (_, status) in ordered {
            switch status {
            case .washed:
                missedWashes = 0
            case .notWashed:
                missedWashes += 1
            case .unknown, .none:
                break
            }
        }
        return min(3, missedWashes)
    }

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    static func date(from key: String, calendar: Calendar = .current) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    static func hasReachedUnknownTime(
        now: Date = Date(),
        sleepMinuteOfDay: Int,
        calendar: Calendar = .current
    ) -> Bool {
        let recordDay = effectiveRecordDate(
            for: now,
            sleepMinuteOfDay: sleepMinuteOfDay,
            calendar: calendar
        )
        let sleepDay = sleepMinuteOfDay < 6 * 60
            ? (calendar.date(byAdding: .day, value: 1, to: recordDay) ?? recordDay)
            : recordDay
        guard let sleepTime = calendar.date(
            bySettingHour: sleepMinuteOfDay / 60,
            minute: sleepMinuteOfDay % 60,
            second: 0,
            of: sleepDay
        ), let unknownTime = calendar.date(byAdding: .minute, value: -10, to: sleepTime) else {
            return false
        }
        return now >= unknownTime
    }

    static func effectiveRecordDate(
        for now: Date = Date(),
        sleepMinuteOfDay: Int,
        calendar: Calendar = .current
    ) -> Date {
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let currentMinute = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        if sleepMinuteOfDay < 6 * 60, currentMinute < 6 * 60 {
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        }
        return now
    }
}
