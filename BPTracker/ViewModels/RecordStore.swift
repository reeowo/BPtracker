import Foundation
import SwiftData

/// 记录聚合计算工具
struct RecordStore {

    /// 按天分组
    static func groupByDay(_ records: [BloodPressureRecord]) -> [(date: Date, records: [BloodPressureRecord])] {
        let grouped = Dictionary(grouping: records) { $0.dayStart }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, records: $0.value.sorted { $0.timestamp > $1.timestamp }) }
    }

    /// 某天的平均值
    static func dailyAverage(_ records: [BloodPressureRecord]) -> (systolic: Int, diastolic: Int, heartRate: Int)? {
        guard !records.isEmpty else { return nil }
        let count = records.count
        let sys = records.map(\.systolic).reduce(0, +) / count
        let dia = records.map(\.diastolic).reduce(0, +) / count
        let hr  = records.map(\.heartRate).reduce(0, +) / count
        return (sys, dia, hr)
    }

    /// 今日记录
    static func todayRecords(from records: [BloodPressureRecord]) -> [BloodPressureRecord] {
        let start = Calendar.current.startOfDay(for: .now)
        return records.filter { $0.timestamp >= start }
    }

    /// 最近 N 天每日平均（用于图表）
    static func recentDailyAverages(from records: [BloodPressureRecord], days: Int) -> [(date: Date, sys: Int, dia: Int, hr: Int)] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: .now))!

        let filtered = records.filter { $0.timestamp >= startDate }
        let grouped = Dictionary(grouping: filtered) { $0.dayStart }

        var result: [(date: Date, sys: Int, dia: Int, hr: Int)] = []
        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            if let dayRecords = grouped[date], !dayRecords.isEmpty {
                let count = dayRecords.count
                let sys = dayRecords.map(\.systolic).reduce(0, +) / count
                let dia = dayRecords.map(\.diastolic).reduce(0, +) / count
                let hr  = dayRecords.map(\.heartRate).reduce(0, +) / count
                result.append((date: date, sys: sys, dia: dia, hr: hr))
            }
        }
        return result
    }

    /// 格式化日期
    static func formatDate(_ date: Date, style: String = "M月d日") -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = style
        fmt.locale = Locale(identifier: "zh_CN")
        return fmt.string(from: date)
    }

    /// 星期几
    static func weekday(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "zh_CN")
        fmt.dateFormat = "EEEE"
        return fmt.string(from: date)
    }
}
