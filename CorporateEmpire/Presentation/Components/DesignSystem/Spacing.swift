//
//  Spacing.swift
//  CorporateEmpire
//
//  Design System - Spacing
//

import SwiftUI

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

enum CornerRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let round: CGFloat = 999 // Fully rounded
}

// MARK: - Shadow

enum ShadowStyle {
    case none
    case small
    case medium
    case large

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .small: return 4
        case .medium: return 8
        case .large: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .none: return 0
        case .small: return 2
        case .medium: return 4
        case .large: return 8
        }
    }

    var opacity: Double {
        switch self {
        case .none: return 0
        case .small: return 0.1
        case .medium: return 0.15
        case .large: return 0.2
        }
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(shadow: ShadowStyle = .small) -> some View {
        self
            .background(AppColors.cardBackground)
            .cornerRadius(CornerRadius.md)
            .shadow(
                color: Color.black.opacity(shadow.opacity),
                radius: shadow.radius,
                y: shadow.y
            )
    }

    func primaryButton() -> some View {
        self
            .font(AppFonts.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(AppColors.primary)
            .cornerRadius(CornerRadius.md)
    }

    func secondaryButton() -> some View {
        self
            .font(AppFonts.headline)
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(AppColors.primary.opacity(0.1))
            .cornerRadius(CornerRadius.md)
    }
}
