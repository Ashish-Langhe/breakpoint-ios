//
//  SplashView.swift
//  Breakpoint
//
//  Created for Breakpoint — animated launch experience.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var lineTrim: CGFloat = 0
    @State private var titleRevealed = false
    @State private var logoRevealed = false
    @State private var glowActive = false

    var body: some View {
        ZStack {
            backgroundLayer
            if !reduceMotion {
                TimelineView(.animation) { t in
                    let p = t.date.timeIntervalSinceReferenceDate
                    ZStack {
                        softOrbs(phase: p)
                        particleHaze(phase: p)
                    }
                }
            } else {
                softOrbs(phase: 0)
            }
            VStack(spacing: 28) {
                ZStack {
                    if glowActive {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.25, green: 0.9, blue: 0.95).opacity(0.45),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .blur(radius: 20)
                    }
                    if reduceMotion {
                        BreakpointMarkView(phase: 0, trim: 1, reveal: logoRevealed)
                    } else {
                        TimelineView(.animation) { t in
                            BreakpointMarkView(
                                phase: t.date.timeIntervalSinceReferenceDate,
                                trim: lineTrim,
                                reveal: logoRevealed
                            )
                        }
                    }
                }
                .frame(height: 120)
                VStack(spacing: 8) {
                    Text("BREAKPOINT")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .tracking(6)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    Color(red: 0.7, green: 0.92, blue: 0.98)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(titleRevealed ? 1 : 0)
                        .offset(y: titleRevealed ? 0 : 18)
                    Text("Define the pause. Resume stronger.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(titleRevealed ? 1 : 0)
                }
            }
        }
        .onAppear(perform: playEntrance)
    }

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.08, blue: 0.18),
                Color(red: 0.02, green: 0.12, blue: 0.24),
                Color(red: 0.06, green: 0.2, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func softOrbs(phase: Double) -> some View {
        let float = sin(phase * 0.4) * 4
        return ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.18), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: CGFloat(-80 + float), y: -220)
                .blur(radius: 30)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.2), .clear],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: CGFloat(100 - float * 0.75), y: 200)
                .blur(radius: 28)
        }
        .allowsHitTesting(false)
    }

    private func particleHaze(phase: Double) -> some View {
        Canvas { context, size in
            for i in 0..<28 {
                let x = (CGFloat(sin(phase * 0.3 + Double(i) * 0.7)) * 0.4 + 0.5) * size.width
                let y = (CGFloat(cos(phase * 0.2 + Double(i) * 0.5)) * 0.25 + 0.4) * size.height
                let s = 1.0 + CGFloat(sin(phase * 2.0 + Double(i))) * 0.3
                let p = 0.12 + 0.1 * abs(sin(Double(i) + phase))
                let path = Path(ellipseIn: CGRect(
                    x: x - s,
                    y: y - s,
                    width: s * 2,
                    height: s * 2
                ))
                context.fill(path, with: .color(Color.white.opacity(p)))
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .opacity(0.4)
    }

    private func playEntrance() {
        if reduceMotion {
            lineTrim = 1
            logoRevealed = true
            titleRevealed = true
            glowActive = true
            return
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
            lineTrim = 1
        }
        withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
            logoRevealed = true
            glowActive = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.86).delay(0.3)) {
            titleRevealed = true
        }
    }
}

// MARK: - Mark

private struct BreakpointMarkView: View {
    var phase: Double
    var trim: CGFloat
    var reveal: Bool

    @State private var didPlayFlash = false
    @State private var flash = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            segment(mirrored: false)
            Image(systemName: "bolt.fill")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(flash && reveal ? 1.1 : 1.0)
                .shadow(color: .orange.opacity(0.5), radius: flash ? 16 : 8)
            segment(mirrored: true)
        }
        .scaleEffect(reveal ? 1 : 0.65)
        .rotationEffect(.degrees(sin(phase * 0.25) * 2.5 + (reveal ? 0 : -6)))
        .onChange(of: reveal) { _, new in
            guard new, !didPlayFlash else { return }
            didPlayFlash = true
            withAnimation(
                .easeInOut(duration: 0.45).repeatCount(1, autoreverses: true)
            ) {
                flash = true
            }
        }
    }

    @ViewBuilder
    private func segment(mirrored: Bool) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.85, blue: 0.9),
                        Color(red: 0.3, green: 0.55, blue: 0.95)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 52, height: 5)
            .offset(x: (mirrored ? 1 : -1) * (1 - trim) * 12)
    }
}

#Preview {
    SplashView()
}
