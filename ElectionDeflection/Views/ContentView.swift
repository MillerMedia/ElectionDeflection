import SwiftUI

struct ContentView: View {
    private static let modalTransitionDelay: TimeInterval = 0.3

    @State private var showOnboarding = !SharedDataManager.shared.hasCompletedOnboarding
    @State private var showWelcomeV2 = false
    @State private var showingProUpgrade = false

    var body: some View {
        if showOnboarding {
            OnboardingView {
                showOnboarding = false
            }
        } else {
            MainAppView()
                .fullScreenCover(isPresented: $showWelcomeV2) {
                    WelcomeV2View(
                        onDismiss: {
                            SharedDataManager.shared.hasSeenV2Welcome = true
                            showWelcomeV2 = false
                        },
                        onLearnAboutPro: {
                            SharedDataManager.shared.hasSeenV2Welcome = true
                            showWelcomeV2 = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + Self.modalTransitionDelay) {
                                showingProUpgrade = true
                            }
                        }
                    )
                }
                .fullScreenCover(isPresented: $showingProUpgrade) {
                    ProUpgradeView()
                }
                .onAppear {
                    if !SharedDataManager.shared.hasSeenV2Welcome {
                        showWelcomeV2 = true
                    }
                }
        }
    }
}
