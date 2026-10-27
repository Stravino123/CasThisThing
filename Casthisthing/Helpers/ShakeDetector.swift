import SwiftUI
import UIKit

// MARK: - Shake detection
// SwiftUI non espone lo shake: lo intercettiamo su UIWindow e lo ripubblichiamo come notifica.

extension UIDevice {
    static let deviceDidShake = Notification.Name("casthisthing.deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShake, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShake)) { _ in
            action()
        }
    }
}

// MARK: - Easter egg

/// Scritta in sovraimpressione che compare scuotendo il telefono e sparisce da sola.
struct ShakeEasterEgg: ViewModifier {
    @State private var visible = false
    @State private var hideTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay {
                if visible {
                    Text("Irene sei grande")
                        .font(DS.Font.excon(size: 32, weight: 700))
                        .foregroundStyle(DS.Color.onPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Space.xl)
                        .padding(.vertical, DS.Space.lg)
                        .background(Capsule().fill(DS.Color.primary))
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                        .allowsHitTesting(false)
                }
            }
            .onShake {
                withAnimation(.spring(duration: 0.4, bounce: 0.4)) { visible = true }
                hideTask?.cancel()
                hideTask = Task {
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeOut(duration: 0.3)) { visible = false }
                }
            }
    }
}

extension View {
    func shakeEasterEgg() -> some View { modifier(ShakeEasterEgg()) }
}
