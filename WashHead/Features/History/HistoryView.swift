import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var historyJSON: String
    let onRecordsChanged: () -> Void

    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text("只負責回憶，不打分數。")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.58))

                HStack {
                    monthButton(systemName: "chevron.left", amount: -1)
                    Spacer()
                    Text(monthTitle)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                    Spacer()
                    monthButton(systemName: "chevron.right", amount: 1)
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdayLabels, id: \.self) { label in
                        Text(label)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(.black.opacity(0.50))
                            .frame(height: 26)
                    }

                    ForEach(Array(monthCells.enumerated()), id: \.offset) { _, date in
                        if let date {
                            dayCell(date)
                        } else {
                            Color.clear.frame(height: 58)
                        }
                    }
                }

                Spacer()

                HStack(spacing: 16) {
                    legend("洗了", symbol: "drop.fill", color: .blue)
                    legend("沒洗", symbol: "cloud.fill", color: .brown)
                    legend("不知道", symbol: "questionmark", color: .gray)
                }
            }
            .padding(18)
            .background(Color(red: 0.96, green: 0.93, blue: 0.86))
            .navigationTitle("我們洗頭了嗎？")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .fontWeight(.black)
                }
            }
        }
        .confirmationDialog(
            selectedDate.map(dayTitle) ?? "更正紀錄",
            isPresented: Binding(
                get: { selectedDate != nil },
                set: { if !$0 { selectedDate = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("洗了") { setSelectedStatus(.washed) }
            Button("沒洗") { setSelectedStatus(.notWashed) }
            Button("不知道") { setSelectedStatus(.unknown) }
            Button("刪除這天的紀錄", role: .destructive) { setSelectedStatus(nil) }
            Button("取消", role: .cancel) { selectedDate = nil }
        }
    }

    private var monthTitle: String {
        let components = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        return "\(components.year ?? 0) 年 \(components.month ?? 0) 月"
    }

    private var monthCells: [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let start = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: start) else {
            return []
        }

        let leading = calendar.component(.weekday, from: start) - 1
        let dates = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
        return Array(repeating: nil, count: leading) + dates.map(Optional.some)
    }

    private func dayCell(_ date: Date) -> some View {
        let status = WashHistory.status(on: date, in: historyJSON)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 5) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 15, weight: .black, design: .rounded))

                Image(systemName: symbol(for: status))
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(color(for: status))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(status == nil ? Color.white.opacity(0.55) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(.black.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func monthButton(systemName: String, amount: Int) -> some View {
        Button {
            if let next = Calendar.current.date(byAdding: .month, value: amount, to: displayedMonth) {
                displayedMonth = next
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .black))
                .frame(width: 44, height: 44)
                .background(.white)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.black)
    }

    private func setSelectedStatus(_ status: WashStatus?) {
        guard let selectedDate else { return }
        historyJSON = WashHistory.updating(historyJSON, status: status, on: selectedDate)
        self.selectedDate = nil
        onRecordsChanged()
    }

    private func symbol(for status: WashStatus?) -> String {
        switch status {
        case .some(.washed): return "drop.fill"
        case .some(.notWashed): return "cloud.fill"
        case .some(.unknown): return "questionmark"
        case .some(.none), nil: return "minus"
        }
    }

    private func color(for status: WashStatus?) -> Color {
        switch status {
        case .some(.washed): return .blue
        case .some(.notWashed): return .brown
        case .some(.unknown): return .gray
        case .some(.none), nil: return .black.opacity(0.18)
        }
    }

    private func dayTitle(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        return "更正 \(components.month ?? 0) 月 \(components.day ?? 0) 日"
    }

    private func legend(_ title: String, symbol: String, color: Color) -> some View {
        Label(title, systemImage: symbol)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(color)
    }
}
