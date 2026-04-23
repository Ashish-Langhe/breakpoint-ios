//
//  BreakpointDesign.swift
//  Breakpoint
//
//  Shared visual tokens (splash, walkthrough, and future home).
//

import SwiftUI

enum BreakpointDesign {
    static let backgroundDeep = Color(red: 0.04, green: 0.08, blue: 0.18)
    static let backgroundMid = Color(red: 0.02, green: 0.12, blue: 0.24)
    static let backgroundBase = Color(red: 0.06, green: 0.2, blue: 0.32)

    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [backgroundDeep, backgroundMid, backgroundBase],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var titleGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white,
                Color(red: 0.7, green: 0.92, blue: 0.98)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var accentCyan = Color(red: 0.1, green: 0.85, blue: 0.9)
    static var accentViolet = Color(red: 0.55, green: 0.4, blue: 0.95)
}
