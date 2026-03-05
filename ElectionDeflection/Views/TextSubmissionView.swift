import SwiftUI

struct TextSubmissionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeService = StoreKitService.shared

    @State private var textContent = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var clipboardHasText = false
    @State private var didAttemptPaste = false
    @FocusState private var isTextFieldFocused: Bool

    private let submissionService = TextSubmissionService.shared

    var body: some View {
        ZStack {
            (storeService.isProTier ? Color.proNavy : Color.brandNavy)
                .edgesIgnoringSafeArea(.all)

            if showSuccess {
                successView
            } else {
                mainContent
            }
        }
        .onAppear {
            clipboardHasText = UIPasteboard.general.hasStrings
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                }
                .disabled(isSubmitting)
                .opacity(isSubmitting ? 0.3 : 1)
                .accessibilityLabel("Cancel")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 20) {
                    // Icon and description
                    VStack(spacing: 8) {
                        Image(systemName: "envelope.badge.person.crop")
                            .font(.system(size: 36))
                            .foregroundColor(.brandGold)

                        Text("Help Improve Filtering")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("Submit a political text you received to help train better filters for everyone.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)

                    // Text input area
                    VStack(alignment: .leading, spacing: 8) {
                        if !didAttemptPaste && clipboardHasText {
                            // Paste from clipboard button (only shown when clipboard has text)
                            Button {
                                pasteFromClipboard()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Paste from Clipboard")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.brandNavy)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                            .accessibilityLabel("Paste text from clipboard")
                        }

                        TextEditor(text: $textContent)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 120)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                Group {
                                    if textContent.isEmpty {
                                        Text("Paste or type the political text here...")
                                            .foregroundColor(.white.opacity(0.3))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                            .accessibilityLabel("Text to submit")
                            .accessibilityHint(textContent.isEmpty ? "Paste or type the political text here" : "")

                        HStack {
                            if trimmedCount > 0 && trimmedCount < 20 {
                                Text("\(20 - trimmedCount) more characters needed")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            Spacer()
                            Text("\(textContent.count)/2000")
                                .font(.caption)
                                .foregroundColor(textContent.count > 2000 ? .red : .white.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 20)

                    // Privacy disclosure (always visible per AC 3)
                    privacyDisclosure

                    // Error message
                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .accessibilityElement(children: .combine)
                    }

                    // Submit button
                    Button {
                        submitText()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(canSubmit ? Color.orange : Color.white.opacity(0.2))
                        .cornerRadius(14)
                    }
                    .disabled(!canSubmit)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .accessibilityLabel(isSubmitting ? "Submitting text" : "Submit text")
                }
            }
            .modifier(NoBounceModifier())
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }

    // MARK: - Privacy Disclosure

    private var privacyDisclosure: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                Text("Privacy Disclosure")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                disclosureRow(icon: "checkmark.circle.fill", color: .green,
                              text: "Only the text below will be sent")
                disclosureRow(icon: "xmark.circle.fill", color: .red,
                              text: "No personal info, device ID, or metadata")
                disclosureRow(icon: "checkmark.circle.fill", color: .green,
                              text: "Your filter still works 100% on-device")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Privacy disclosure. Only the text will be sent. No personal info, device ID, or metadata. Your filter still works 100% on device.")
    }

    private func disclosureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Thank You!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Your contribution helps improve filtering for everyone.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.brandGold)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .accessibilityLabel("Done")
        }
    }

    // MARK: - Logic

    private var trimmedCount: Int {
        textContent.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    private var canSubmit: Bool {
        !isSubmitting && trimmedCount >= 20 && textContent.count <= 2000
    }

    private func pasteFromClipboard() {
        didAttemptPaste = true
        // UIPasteboard.general.string triggers iOS paste permission banner
        if let clipboardText = UIPasteboard.general.string, !clipboardText.isEmpty {
            textContent = clipboardText
        }
    }

    private func submitText() {
        guard canSubmit else { return }
        errorMessage = nil
        isSubmitting = true

        Task {
            do {
                try await submissionService.submitText(textContent)
                await MainActor.run {
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSubmitting = false
                }
            }
        }
    }
}

struct OpaqueSheetBackground: ViewModifier {
    let isProTier: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationBackground(isProTier ? Color.proNavy : Color.brandNavy)
        } else {
            content
        }
    }
}

private struct NoBounceModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}
