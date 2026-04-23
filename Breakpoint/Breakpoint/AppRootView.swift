//
//  AppRootView.swift
//  Breakpoint
//
//  Splash → walkthrough (first launch) → main interface.
//

import SwiftData
import SwiftUI
import UIKit

struct AppRootView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("breakpoint.walkthrough.completed") private var walkthroughCompleted = false
    @State private var phase: AppPhase = .splash

    private static let minimumSplashNanoseconds: UInt64 = 2_000_000_000

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashView()
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .opacity.combined(with: .scale(scale: 1.02))
                        )
                    )
            case .walkthrough:
                WalkthroughView {
                    walkthroughCompleted = true
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.1)) {
                        phase = .main
                    }
                    if !reduceMotion {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .scale(scale: 0.98, anchor: .top).combined(with: .opacity)
                    )
                )
            case .main:
                ContentView()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .identity
                        )
                    )
            }
        }
        .animation(
            .spring(response: 0.55, dampingFraction: 0.88, blendDuration: 0.15),
            value: phase
        )
        .task {
            try? await Task.sleep(nanoseconds: Self.minimumSplashNanoseconds)
            await MainActor.run {
                let next: AppPhase = walkthroughCompleted ? .main : .walkthrough
                withAnimation { phase = next }
                if next == .main, !reduceMotion {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}

private enum AppPhase: Equatable {
    case splash
    case walkthrough
    case main
}

#Preview {
    AppRootView()
        .modelContainer(for: Item.self, inMemory: true)
}
