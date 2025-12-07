//
//  Spacing.swift
//  Tic-Tac-Toe_WatchOS_2025 Watch App
//
//  Created by Xcode Developer on 12/7/25.
//

import SwiftUI
import WatchKit

struct ScreenMetrics {
    static let shared = ScreenMetrics()

    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let screenSize: CGFloat

    private init() {
        let bounds = WKInterfaceDevice.current().screenBounds
        self.screenWidth = bounds.width
        self.screenHeight = bounds.height
        self.screenSize = min(bounds.width, bounds.height)
    }

    func spacing(_ ratio: CGFloat) -> CGFloat {
        return screenSize * ratio
    }

    func width(_ ratio: CGFloat) -> CGFloat {
        return screenWidth * ratio
    }

    func height(_ ratio: CGFloat) -> CGFloat {
        return screenHeight * ratio
    }
}

extension CGFloat {
    static let xxxSmall = ScreenMetrics.shared.spacing(0.01)
    static let xxSmall = ScreenMetrics.shared.spacing(0.015)
    static let xSmall = ScreenMetrics.shared.spacing(0.02)
    static let small = ScreenMetrics.shared.spacing(0.03)
    static let medium = ScreenMetrics.shared.spacing(0.04)
    static let large = ScreenMetrics.shared.spacing(0.06)
    static let xLarge = ScreenMetrics.shared.spacing(0.08)
    static let xxLarge = ScreenMetrics.shared.spacing(0.10)
    static let xxxLarge = ScreenMetrics.shared.spacing(0.12)

    static let cornerRadiusSmall = ScreenMetrics.shared.spacing(0.04)
    static let cornerRadiusMedium = ScreenMetrics.shared.spacing(0.05)
    static let cornerRadiusLarge = ScreenMetrics.shared.spacing(0.06)

    static let borderWidthThin = ScreenMetrics.shared.spacing(0.015)
    static let borderWidthMedium = ScreenMetrics.shared.spacing(0.02)
    static let borderWidthThick = ScreenMetrics.shared.spacing(0.025)

    static let iconSize = ScreenMetrics.shared.spacing(0.18)
    static let cellAspectRatio: CGFloat = 1.0

    static let fontSizeSmall = ScreenMetrics.shared.spacing(0.08)
    static let fontSizeMedium = ScreenMetrics.shared.spacing(0.10)
    static let fontSizeLarge = ScreenMetrics.shared.spacing(0.14)
    static let fontSizeXLarge = ScreenMetrics.shared.spacing(0.18)

    static let previewCellSize = ScreenMetrics.shared.spacing(0.19)
}

extension View {
    func responsivePadding(_ edges: Edge.Set = .all, _ ratio: CGFloat) -> some View {
        self.padding(edges, ScreenMetrics.shared.spacing(ratio))
    }

    func responsiveFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self.frame(
            width: width.map { ScreenMetrics.shared.width($0) },
            height: height.map { ScreenMetrics.shared.height($0) }
        )
    }
}
