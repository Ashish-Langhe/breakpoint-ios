//
//  WalkthroughView.swift
//  Breakpoint
//
//  Onboarding: problem → differentiator → how it works → intelligence → start.
//

import SwiftUI
import UIKit

struct WalkthroughView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var page: Int = 0

    var onComplete: () -> Void

    private var steps: [WalkStep] {
        WalkStep.breakpointSet
    }

    private var isLastPage: Bool { page == steps.count - 1 }
    private var isLargeType: Bool { dynamicTypeSize >= .accessibility1 }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                topBar
                pageContent
                bottomBar
            }
        }
    }

    private var background: some View {
        ZStack {
            BreakpointDesign.screenBackground.ignoresSafeArea()
            if !reduceMotion {
                softGlow
            }
        }
    }

    private var softGlow: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [BreakpointDesign.accentCyan.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 400, height: 280)
                .offset(y: -120)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [BreakpointDesign.accentViolet.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 340, height: 240)
                .offset(x: 80, y: 200)
        }
        .allowsHitTesting(false)
    }

    private var topBar: some View {
        HStack {
            if page > 0 {
                Button {
                    hapticLight()
                    withPageAnimation { page -= 1 }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                }
                .tint(.white.opacity(0.9))
            } else {
                Color.clear.frame(width: 44, height: 36)
            }
            Spacer()
            Button {
                hapticLight()
                completeJourney()
            } label: {
                Text("Skip")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(.white.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var pageContent: some View {
        VStack(spacing: 0) {
            if reduceMotion {
                staticPage(for: steps[page])
            } else {
                TabView(selection: $page) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        stepPage(step)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }

    private func staticPage(for step: WalkStep) -> some View {
        stepPage(step)
            .padding(.top, 12)
    }

    private func stepPage(_ step: WalkStep) -> some View {
        let column = VStack(alignment: .center, spacing: 24) {
            hero(for: step)
            VStack(alignment: .center, spacing: 12) {
                Text(step.title)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BreakpointDesign.titleGradient)
                Text(step.subtitle)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                Text(step.body)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 24)
        }
        return Group {
            if isLargeType {
                ScrollView {
                    column
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            } else {
                column
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    @ViewBuilder
    private func hero(for step: WalkStep) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [step.orbColor.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 110
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 8)
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    .linearGradient(
                        colors: [
                            .white.opacity(0.12),
                            .white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(
                            .linearGradient(
                                colors: [.white.opacity(0.35), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .frame(height: 220)
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.35), radius: 20, y: 12)
            step.heroContent
                .padding(.vertical, 24)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            i == page
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [BreakpointDesign.accentCyan, BreakpointDesign.accentViolet],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyShapeStyle(.white.opacity(0.2))
                        )
                        .frame(width: i == page ? 18 : 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step \(page + 1) of \(steps.count)")

            Button {
                hapticLight()
                if isLastPage {
                    completeJourney()
                } else {
                    withPageAnimation { page += 1 }
                }
            } label: {
                Text(isLastPage ? "Get started" : "Continue")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(BreakpointPrimaryButtonStyle())
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }

    private func withPageAnimation(_ body: @escaping () -> Void) {
        if reduceMotion {
            body()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { body() }
        }
    }

    private func completeJourney() {
        onComplete()
    }

    private func hapticLight() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}

// MARK: - Steps

private struct WalkStep {
    let title: String
    let subtitle: String
    let body: String
    let orbColor: Color
    let heroContent: AnyView

    static let breakpointSet: [WalkStep] = [
        WalkStep(
            title: "The best debuggers know when to pause.",
            subtitle: "You still have a body",
            body: "Developers sit for 10–12 hours a day. Pain builds slowly: you do not feel it in the moment — you feel it over months. The real issue is the forgetting while you are deep in a run.",
            orbColor: .cyan,
            heroContent: AnyView(DeveloperStillHero())
        ),
        WalkStep(
            title: "Not another 45-minute timer",
            subtitle: "Fixed nudges miss context",
            body: "Break reminders on a schedule fire whether you are in a standup, a focus block, or already walking. Snooze twice, delete the app. Breakpoint nudges when it actually makes sense for you.",
            orbColor: .orange,
            heroContent: AnyView(TimerVsFocusHero())
        ),
        WalkStep(
            title: "Stillness, not a countdown",
            subtitle: "Motion, not a clock",
            body: "Using Core Motion, Breakpoint senses real inactivity — not an arbitrary clock. When you have been genuinely still long enough, you get a thoughtful nudge to move, breathe, and reset before strain accumulates.",
            orbColor: Color(red: 0.3, green: 0.85, blue: 0.6),
            heroContent: AnyView(StillnessHero())
        ),
        WalkStep(
            title: "Smarter the longer you use it",
            subtitle: "Focus, habits, and guidance",
            body: "Respect for focus windows, room to learn from your behaviour, and a conversational AI Genie when you want clear, personal guidance in plain language. Wellness that fits a shipping schedule.",
            orbColor: BreakpointDesign.accentViolet,
            heroContent: AnyView(IntelligenceHero())
        ),
        WalkStep(
            title: "Welcome to Breakpoint",
            subtitle: "Breathe, move, return sharper",
            body: "We will help you protect your next debugging session with body awareness, not shame. You can change notification and motion settings anytime in the app. Ready when you are.",
            orbColor: BreakpointDesign.accentCyan,
            heroContent: AnyView(ReadyHero())
        )
    ]
}

// MARK: - Hero illustrations (SwiftUI, SF Symbol–based)

private struct DeveloperStillHero: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.08))
                        .frame(width: 56, height: 64)
                    Image(systemName: "laptopcomputer")
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(width: 100, height: 8)
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(width: 80, height: 8)
                }
            }
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.white, .cyan.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                VStack(alignment: .leading, spacing: 6) {
                    Text("Deep focus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(.red.opacity(0.7))
                                .frame(width: 3, height: 18)
                        }
                    }
                }
            }
        }
    }
}

private struct TimerVsFocusHero: View {
    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(spacing: 10) {
                Image(systemName: "timer")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange.opacity(0.9))
                Text("Arbitrary\nintervals")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title2)
                .foregroundStyle(Color.white.opacity(0.6))
            VStack(spacing: 10) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 32))
                    .foregroundStyle(BreakpointDesign.accentCyan)
                Text("Your real\nday, not a grid")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

private struct StillnessHero: View {
    @State private var fillPhase = 0.0
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(
                        .linearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 88, height: 88)
                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(
                            i < 2
                            ? .green
                            : .white.opacity(0.12 + 0.08 * sin(fillPhase + Double(i)))
                        )
                        .frame(width: 6, height: 6)
                }
            }
            Text("Genuine stillness detected")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.75))
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1.2).repeatForever(autoreverses: true)
            ) { fillPhase = 5 }
        }
    }
}

private struct IntelligenceHero: View {
    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 10) {
                iconChip("lock.shield.fill", .indigo, "Focus")
                iconChip("chart.line.uptrend.xyaxis", .mint, "Habits")
            }
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            .linearGradient(
                                colors: [
                                    BreakpointDesign.accentViolet.opacity(0.4),
                                    BreakpointDesign.accentCyan.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 110)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("AI Genie")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                            Image(systemName: "sparkles")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.yellow)
                        }
                        Text("“Short stretch. Right now.”")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(12)
                }
            }
        }
    }

    @ViewBuilder
    private func iconChip(_ name: String, _ color: Color, _ text: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: name)
                .font(.title2)
                .foregroundStyle(color)
            Text(text)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ReadyHero: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(
                            .white.opacity(0.1 + 0.08 * Double(i)),
                            lineWidth: 1
                        )
                        .frame(width: 72 + CGFloat(i) * 22, height: 72 + CGFloat(i) * 22)
                }
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.teal)
            }
            Text("Your schedule. Your line.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.75))
        }
    }
}

// MARK: - Button

private struct BreakpointPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                .linearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.2),
                        Color(red: 0.1, green: 0.15, blue: 0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        .linearGradient(
                            colors: [
                                BreakpointDesign.accentCyan,
                                Color(red: 0.3, green: 0.55, blue: 0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(
                .spring(response: 0.2, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

#Preview {
    WalkthroughView(onComplete: {})
}
