import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct ECortezLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        ECortezProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct ECortezBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct ECortezProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var particles: [ProgressParticle] = []

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startShimmerAnimation()
                    startPulseAnimation()
                    generateParticles(width: geometry.size.width)
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            particleOverlay(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0A0A0A"), Color(hex: "#1A1A2E"), Color(hex: "#16213E"),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#00D4FF").opacity(0.3),
                                Color(hex: "#7B68EE").opacity(0.2),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основной неоновый градиент
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#00D4FF"), Color(hex: "#5B73FF"), Color(hex: "#9D50BB"),
                            Color(hex: "#FF006E"),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .scaleEffect(pulseScale)
                .shadow(color: Color(hex: "#00D4FF").opacity(0.6), radius: 12, y: 0)
                .shadow(color: Color(hex: "#5B73FF").opacity(0.4), radius: 20, y: 0)

            // Анимированный блеск
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.3, height: height)
                .offset(x: shimmerOffset * width)
                .clipped()
                .frame(width: width, height: height)

            // Внутреннее свечение
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: height / 2
                    )
                )
                .frame(width: width, height: height * 0.6)
        }
        .animation(.easeInOut(duration: 0.3), value: value)
    }

    private func particleOverlay(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width

        return ZStack {
            ForEach(particles.indices, id: \.self) { index in
                if particles[index].x <= width {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#00D4FF").opacity(0.8),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 2
                            )
                        )
                        .frame(width: 4, height: 4)
                        .position(x: particles[index].x, y: particles[index].y)
                        .opacity(particles[index].opacity)
                }
            }
        }
    }

    private func startShimmerAnimation() {
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.2
        }
    }

    private func startPulseAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }

    private func generateParticles(width: CGFloat) {
        particles = (0..<15).map { _ in
            ProgressParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.3...0.9)
            )
        }
    }
}

private struct ProgressParticle {
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

// MARK: - Превью

#Preview("Vertical") {
    ECortezLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    ECortezLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
