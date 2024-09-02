import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                // Initial Screen - App Icon with Background Color and Introductory Text
                InitialIconView()
                    .tag(0)

                // Step 1: Open Settings
                StepView(
                    title: "Step 1: Open Settings",
                    description: "Open the Settings app on your iPhone. You can do this by tapping the Settings icon on your home screen or by clicking the 'Go to Settings' button at the end of this guide.",
                    imageName: "settings_icon_pdf"
                )
                .tag(1)

                // Step 2: Go to Messages
                StepView(
                    title: "Step 2: Go to Messages Settings",
                    description: "Scroll down and tap on 'Messages'.",
                    imageName: "messages_screenshot"
                )
                .tag(2)

                // Step 3A: Open Unknown & Spam
                StepView(
                    title: "Step 3: Open Unknown & Spam",
                    description: "Tap on 'Unknown & Spam' in the Messages settings.",
                    imageName: "unknown_spam_screenshot"
                )
                .tag(3)

                // Step 3B: Enable SMS Filtering
                StepView(
                    title: "Step 4: Enable SMS Filtering",
                    description: "Select 'ElectionDeflection' under SMS Filtering.",
                    imageName: "sms_filtering_screenshot"
                )
                .tag(4)

                // NEW Step: Explain Filtering Behavior
                StepView(
                    title: "How It Works",
                    description: "Once enabled, ElectionDeflection will filter political messages into the newly created 'Junk' folder. Don't worry, any political messages from your contacts won't be filtered.",
                    imageName: "junk_folder_screenshot"
                )
                .tag(5)

                // Final Screen - All Set!
                StepView(
                    title: "You're All Set!",
                    description: "ElectionDeflection will now filter unwanted political messages for you. If you need to revisit any instructions, you can swipe back through the steps.",
                    imageName: nil
                )
                .tag(6)
            }
            .tabViewStyle(PageTabViewStyle())
            .background(Color(hex: "#304789").edgesIgnoringSafeArea(.all)) // Background color for the TabView

            if currentPage < 6 {
                Button(action: {
                    withAnimation {
                        currentPage += 1
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]),
                                           startPoint: .leading,
                                           endPoint: .trailing) // Custom button color gradient
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)  // Add more padding at the bottom for more space
                .background(Color(hex: "#304789").edgesIgnoringSafeArea(.bottom))  // Ensure background color covers the bottom
            } else {
                Button(action: {
                    // Open the Settings app to the app's settings page
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Go to Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]),
                                           startPoint: .leading,
                                           endPoint: .trailing) // Custom button color gradient
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)  // Add more padding at the bottom for more space
                .background(Color(hex: "#304789").edgesIgnoringSafeArea(.bottom))  // Ensure background color covers the bottom
            }
        }
        .edgesIgnoringSafeArea(.all)  // Ensure this covers the entire screen
    }
}

// Initial Screen with App Icon, Background Color, and Introductory Text
struct InitialIconView: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "#304789")
                .edgesIgnoringSafeArea(.all) // Ensure the color covers the entire screen
            
            VStack(spacing: 20) {
                
                // Icon in the Center
                Image("app_icon_no_background")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 60)

                // Introductory Text
                VStack(spacing: 20) {
                    Text("Welcome to ElectionDeflection")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white) // Set text color to white
                        .multilineTextAlignment(.center)
                        .padding(.top, 0)

                    Text("ElectionDeflection helps you filter out unwanted political messages by utilizing the SMS filtering feature on your iPhone.")
                        .font(.body)
                        .foregroundColor(.white) // Set text color to white
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Your privacy is important to us. We do not save or transmit any of your data. You can review the full source code at the link below.")
                        .font(.body)
                        .foregroundColor(.white) // Set text color to white
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if let url = URL(string: "https://your-repo-link-here.com") {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "chevron.left.slash.chevron.right") // SF Symbol for "code" or custom GitHub logo
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                Text("View Source Code")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack fills the entire ZStack
        }
    }
}

// Step View for Each Onboarding Step
struct StepView: View {
    let title: String
    let description: String
    let imageName: String?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))  // Custom system font
                    .foregroundColor(.white) // Set text color to white
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                // Align description text directly below the title
                Text(description)
                    .font(.body)
                    .foregroundColor(.white) // Set text color to white
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer(minLength: 20) // Spacer to ensure consistent spacing

                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxWidth: geometry.size.width * 1, // 100% of the screen width
                            maxHeight: geometry.size.height * 0.6 // 40% of the screen height
                        )
                        .padding(.top, 20)
                }

                Spacer() // Bottom spacer to push everything upwards consistently
            }
            .padding()
        }
    }
}

// Extension to use Hex colors in SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
