import SwiftUI

struct OnboardingView: View {
    var onComplete: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        // Define base index for tags
        let baseStepIndex = 1
        let stepCount = 6
        
        // Calculate iOS 18 adjustment inside the body
        let iOS18Adjustment: Int = {
            if #available(iOS 18.0, *) {
                return 1
            } else {
                return 0
            }
        }()
        
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                // Initial Screen - App Icon with Background Color and Introductory Text
                InitialIconView()
                    .tag(0)
                
                // Step 1: Open Settings
                StepView(
                    title: "Step 1: Open Settings",
                    description: "Open the Settings app on your iPhone. You can do this by tapping the Settings icon on your home screen.",
                    imageName: "settings_icon_pdf"
                )
                .tag(baseStepIndex)
                
                // Step 2 (for iOS 18+): Go to Apps
                if #available(iOS 18.0, *) {
                    StepView(
                        title: "Step 2: Go to Apps",
                        description: "Scroll down and tap on 'Apps'.",
                        imageName: "ios18_settings"
                    )
                    .tag(baseStepIndex + 1)
                }

                // Step 2: Go to Messages (iOS <18) / Step 3 (iOS 18+)
                StepView(
                    title: iOS18Adjustment == 1 ? "Step 3: Go to Messages" : "Step 2: Go to Messages Settings",
                    description: "Scroll down and tap on 'Messages'.",
                    imageName: iOS18Adjustment == 1 ? "ios18_apps" : "messages_screenshot"
                )
                .tag(baseStepIndex + 1 + iOS18Adjustment)

                // Step 3A: Open Unknown & Spam
                StepView(
                    title: "Step \(baseStepIndex + 2 + iOS18Adjustment): Open Unknown & Spam",
                    description: "Tap on 'Unknown & Spam' in the Messages settings.",
                    imageName: "unknown_spam_screenshot"
                )
                .tag(baseStepIndex + 2 + iOS18Adjustment)

                // Step 3B: Enable SMS Filtering
                StepView(
                    title: "Step \(baseStepIndex + 3 + iOS18Adjustment): Enable SMS Filtering",
                    description: "Select 'ElectionDeflection' under SMS Filtering.",
                    imageName: "sms_filtering_screenshot"
                )
                .tag(baseStepIndex + 3 + iOS18Adjustment)

                // NEW Step: Explain Filtering Behavior
                StepView(
                    title: "How It Works",
                    description: "Once enabled, ElectionDeflection will filter political messages into the Spam folder. Don't worry, any political messages from your contacts won't be filtered.",
                    imageName: "junk_folder_screenshot"
                )
                .tag(baseStepIndex + 4 + iOS18Adjustment)

                // Final Screen - All Set!
                StepView(
                    title: "Almost Done!",
                    description: """
                    Just one more step! Make sure to leave this app, go to the Settings app and enable ElectionDeflection to start filtering unwanted political messages. If any political texts slip through, please screenshot them and send them to me on IG (@mattmiller.ai) or X (@mattmiller_ai). If you need to revisit any instructions, you can swipe back through the steps.
                    """,
                    imageName: nil
                )
                .tag(baseStepIndex + 5 + iOS18Adjustment)
            }
            .tabViewStyle(PageTabViewStyle())
            .background(Color.brandNavy.edgesIgnoringSafeArea(.all)) // Background color for the TabView

            // Navigation Button
            VStack(spacing: 12) {
                let isLastPage = currentPage >= (stepCount + iOS18Adjustment)

                Button(action: {
                    if isLastPage {
                        SharedDataManager.shared.hasCompletedOnboarding = true
                        if SharedDataManager.shared.onboardingCompletedDate == nil {
                            SharedDataManager.shared.onboardingCompletedDate = Date()
                            UpgradeNotificationManager.scheduleUpgradeNotification()
                        }
                        if let onComplete = onComplete {
                            onComplete()
                        } else {
                            dismiss()
                        }
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }) {
                    Text(isLastPage ? (onComplete != nil ? "Get Started" : "Done") : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .animation(.easeInOut(duration: 0.2), value: isLastPage)

                Button(action: {
                    withAnimation {
                        currentPage = 1
                    }
                }) {
                    Text("Back to Step 1")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(isLastPage ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isLastPage)
                .allowsHitTesting(isLastPage)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
            .background(Color.brandNavy.edgesIgnoringSafeArea(.bottom))

        }
        .edgesIgnoringSafeArea(.all)  // Ensure this covers the entire screen
    }
}


// Initial Screen with App Icon, Background Color, and Introductory Text
struct InitialIconView: View {
    var body: some View {
        ZStack {
            // Background Color
            Color.brandNavy
                .edgesIgnoringSafeArea(.all) // Ensure the color covers the entire screen
            
            VStack(spacing: 20) {
                
                // Icon in the Center
                Image("app_icon_no_background")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 40)

                // Introductory Text
                VStack(spacing: 20) {
                    Text("Welcome to ElectionDeflection")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white) // Set text color to white
                        .multilineTextAlignment(.center)
                        .padding(.top, 0)
                        .minimumScaleFactor(0.5)

                    Text("ElectionDeflection filters out political spam texts by using your phone's SMS filtering feature.")
                        .font(.body)
                        .foregroundColor(.white) // Set text color to white
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil) // Allow wrapping
                        .minimumScaleFactor(0.75) // Scale down text if necessary

                    Text("Your privacy is important to us. We do not save or transmit any of your data. You can review the full source code below.")
                        .font(.body)
                        .foregroundColor(.white) // Set text color to white
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil) // Allow wrapping
                        .minimumScaleFactor(0.65) // Scale down text if necessary

                    if let url = URL(string: "https://github.com/MillerMedia/ElectionDeflection") {
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

                Spacer(minLength: 10) // Spacer to ensure consistent spacing

                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxWidth: geometry.size.width * 1, // 100% of the screen width
                            maxHeight: geometry.size.height * 0.6 // 40% of the screen height
                        )
                        .padding(.top, 10)
                }

                Spacer() // Bottom spacer to push everything upwards consistently
            }
            .padding()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .previewDisplayName("Review Mode (Done)")
        OnboardingView(onComplete: {})
            .previewDisplayName("Initial Onboarding (Get Started)")
    }
}
