import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = !SharedDataManager.shared.hasCompletedOnboarding

    var body: some View {
        if showOnboarding {
            OnboardingView {
                showOnboarding = false
            }
        } else {
            MainAppView()
        }
    }
}
