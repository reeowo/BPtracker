import Foundation
import SwiftData

@Model
final class BloodPressureRecord {
    var systolic: Int        // 收缩压（高压）
    var diastolic: Int       // 舒张压（低压）
    var heartRate: Int       // 心率
    var timestamp: Date      // 记录时间
    var note: String         // 备注

    init(systolic: Int, diastolic: Int, heartRate: Int, timestamp: Date = .now, note: String = "") {
        self.systolic = systolic
        self.diastolic = diastolic
        self.heartRate = heartRate
        self.timestamp = timestamp
        self.note = note
    }

    /// 血压等级
    var level: BPLevel {
        BPLevel.evaluate(systolic: systolic, diastolic: diastolic)
    }

    /// 格式化时间 HH:mm
    var timeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: timestamp)
    }

    /// 格式化日期 yyyy-MM-dd
    var dateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: timestamp)
    }

    /// 日期分组 key（当天 0 点）
    var dayStart: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
}
