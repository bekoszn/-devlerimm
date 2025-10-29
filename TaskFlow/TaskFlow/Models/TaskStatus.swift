import SwiftUI

public enum TaskStatus: String, Codable, Sendable, CaseIterable {
    case planlandi = "planned"
    case yapilacak = "todo"
    case devamEdiyor = "inProgress"
    case kontrol = "review"
    case bitti = "done"
}


public extension TaskStatus {
    var order: Int {
        switch self {
        case .planlandi:    return 0
        case .yapilacak:    return 1
        case .devamEdiyor:  return 2
        case .kontrol:      return 3
        case .bitti:        return 4
        }
    }

    var displayTitle: String {
        switch self {
        case .planlandi:    return "Planlandı"
        case .yapilacak:    return "Yapılacak"
        case .devamEdiyor:  return "Devam Ediyor"
        case .kontrol:      return "Kontrol"
        case .bitti:        return "Bitti"
        }
    }

    var tintColor: Color {
        switch self {
        case .planlandi:    return Color(hex: 0x5E5CE6)
        case .yapilacak:    return Color(hex: 0x34C759)
        case .devamEdiyor:  return Color(hex: 0x0A84FF)
        case .kontrol:      return Color(hex: 0xFF9F0A)
        case .bitti:        return Color(hex: 0xBF5AF2)
        }
    }

    var gradientColors: [Color] { [tintColor.opacity(0.55), tintColor.opacity(0.15)] }

    func next() -> TaskStatus? {
        let all = TaskStatus.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    func previous() -> TaskStatus? {
        let all = TaskStatus.allCases
        guard let idx = all.firstIndex(of: self), idx - 1 >= 0 else { return nil }
        return all[idx - 1]
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF)/255.0,
                  green: Double((hex >> 8)  & 0xFF)/255.0,
                  blue:  Double( hex        & 0xFF)/255.0,
                  opacity: alpha)
    }
}
