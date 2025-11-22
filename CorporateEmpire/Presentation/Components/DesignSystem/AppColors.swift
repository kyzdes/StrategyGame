//
//  AppColors.swift
//  CorporateEmpire
//
//  Design System - Colors
//

import SwiftUI

enum AppColors {
    // MARK: - Primary Colors

    static let primary = Color("AccentBlue")
    static let secondary = Color("AccentGreen")

    // Fallbacks for development
    static let accentBlue = Color(hex: "007AFF")
    static let accentGreen = Color(hex: "34C759")

    // MARK: - Status Colors

    static let positive = Color(hex: "34C759")  // Green - Profit
    static let negative = Color(hex: "FF3B30")  // Red - Loss
    static let neutral = Color(hex: "8E8E93")   // Gray

    // MARK: - Rarity Colors

    static let common = Color(hex: "9E9E9E")      // Gray
    static let rare = Color(hex: "2196F3")        // Blue
    static let epic = Color(hex: "9C27B0")        // Purple
    static let legendary = Color(hex: "FF9800")   // Orange

    // MARK: - Industry Colors

    static func industryColor(_ industry: Industry) -> Color {
        switch industry {
        case .technology:
            return Color(hex: "2196F3")  // Blue
        case .finance:
            return Color(hex: "4CAF50")  // Green
        case .retail:
            return Color(hex: "FF9800")  // Orange
        case .energy:
            return Color(hex: "FFC107")  // Amber
        case .healthcare:
            return Color(hex: "F44336")  // Red
        case .manufacturing:
            return Color(hex: "795548")  // Brown
        case .entertainment:
            return Color(hex: "E91E63")  // Pink
        case .transportation:
            return Color(hex: "9C27B0")  // Purple
        case .realEstate:
            return Color(hex: "009688")  // Teal
        case .agriculture:
            return Color(hex: "8BC34A")  // Light Green
        }
    }

    // MARK: - Background Colors

    static let background = Color("Background")
    static let cardBackground = Color("CardBackground")
    static let secondaryBackground = Color("SecondaryBackground")

    // Fallbacks
    static let backgroundFallback = Color(hex: "F2F2F7")
    static let cardBackgroundFallback = Color.white

    // MARK: - Text Colors

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(hex: "8E8E93")

    // MARK: - Border Colors

    static let border = Color(hex: "E5E5EA")
    static let borderLight = Color(hex: "F2F2F7")

    // MARK: - Gradient Colors

    static let profitGradient = LinearGradient(
        colors: [Color(hex: "34C759"), Color(hex: "30D158")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let lossGradient = LinearGradient(
        colors: [Color(hex: "FF3B30"), Color(hex: "FF453A")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "007AFF"), Color(hex: "0A84FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
