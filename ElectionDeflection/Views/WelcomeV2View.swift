import SwiftUI

struct WelcomeV2View: View {
    let onDismiss: () -> Void
    let onLearnAboutPro: () -> Void

    var body: some View {
        ZStack {
            Color.brandNavy
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brandGold)
                    .accessibilityHidden(true)

                Text("Welcome to\nElectionDeflection 2.0!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 16) {
                    featureRow(
                        icon: "gift.fill",
                        text: "The app is now **free** for everyone"
                    )
                    featureRow(
                        icon: "text.magnifyingglass",
                        text: "Keyword filtering works just like before"
                    )
                    featureRow(
                        icon: "brain.head.profile.fill",
                        text: "Optional **AI-powered Pro** tier for enhanced filtering"
                    )
                }
                .padding(.horizontal, 24)

                Text("Thank you for being an early supporter!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                Button(action: onDismiss) {
                    Text("Got It")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .accessibilityLabel("Got It, dismiss welcome screen")

                Button(action: onLearnAboutPro) {
                    Text("Learn About Pro")
                        .font(.subheadline)
                        .foregroundColor(.brandGold)
                        .underline()
                }
                .accessibilityLabel("Learn About Pro upgrade options")

                Spacer()
                    .frame(height: 40)
            }
        }
    }

    private func featureRow(icon: String, text: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandGold)
                .frame(width: 28)
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
