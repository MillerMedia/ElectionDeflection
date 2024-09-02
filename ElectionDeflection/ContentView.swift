import SwiftUI

struct ContentView: View {
    var body: some View {
        OnboardingView()
            .onAppear{
                print("Initial view loaded.")
            }
    }
}
