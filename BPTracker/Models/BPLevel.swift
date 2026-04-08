import SwiftUI

/// 血压等级分类（依据中国高血压指南）
enum BPLevel: String, CaseIterable {
    case low = "偏低"
    case normal = "正常"
    case elevated = "正常高值"
    case hypertension1 = "高血压1级"
    case hypertension2 = "高血压2级"
    case hypertension3 = "高血压3级"

    var color: Color {
        switch self {
        case .low:            return .blue
        case .normal:         return .green
        case .elevated:       return .yellow
        case .hypertension1:  return .orange
        case .hypertension2:  return .red
        case .hypertension3:  return .purple
        }
    }

    var icon: String {
        switch self {
        case .low:            return "arrow.down.heart"
        case .normal:         return "heart.fill"
        case .elevated:       return "exclamationmark.heart"
        case .hypertension1:  return "heart.slash"
        case .hypertension2:  return "heart.slash.fill"
        case .hypertension3:  return "bolt.heart.fill"
        }
    }

    static func evaluate(systolic: Int, diastolic: Int) -> BPLevel {
        if systolic < 90 || diastolic < 60 {
            return .low
        } else if systolic < 120 && diastolic < 80 {
            return .normal
        } else if systolic < 140 && diastolic < 90 {
            return .elevated
        } else if systolic < 160 && diastolic < 100 {
            return .hypertension1
        } else if systolic < 180 && diastolic < 110 {
            return .hypertension2
        } else {
            return .hypertension3
        }
    }
}
