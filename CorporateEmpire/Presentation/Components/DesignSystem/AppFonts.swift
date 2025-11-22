//
//  AppFonts.swift
//  CorporateEmpire
//
//  Design System - Typography
//

import SwiftUI

enum AppFonts {
    // MARK: - Display

    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // MARK: - Body

    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)

    // MARK: - Monospaced (for numbers/money)

    static let moneyLarge = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let moneyMedium = Font.system(size: 20, weight: .semibold, design: .monospaced)
    static let moneyRegular = Font.system(size: 17, weight: .medium, design: .monospaced)
    static let moneySmall = Font.system(size: 15, weight: .medium, design: .monospaced)

    // MARK: - Rounded (for stats/metrics)

    static let statLarge = Font.system(size: 24, weight: .bold, design: .rounded)
    static let statMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let statSmall = Font.system(size: 17, weight: .medium, design: .rounded)
}

// MARK: - Text Styles

struct TextStyle {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat?

    static let largeTitle = TextStyle(
        font: AppFonts.largeTitle,
        color: AppColors.textPrimary,
        lineSpacing: nil
    )

    static let title = TextStyle(
        font: AppFonts.title,
        color: AppColors.textPrimary,
        lineSpacing: nil
    )

    static let headline = TextStyle(
        font: AppFonts.headline,
        color: AppColors.textPrimary,
        lineSpacing: nil
    )

    static let body = TextStyle(
        font: AppFonts.body,
        color: AppColors.textPrimary,
        lineSpacing: 4
    )

    static let caption = TextStyle(
        font: AppFonts.caption,
        color: AppColors.textSecondary,
        lineSpacing: nil
    )
}

// MARK: - View Extension

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing ?? 0)
    }
}
