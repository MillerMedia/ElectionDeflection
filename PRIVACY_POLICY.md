# Privacy Policy

**ElectionDeflection**
Effective Date: February 2026
Last Updated: February 2026

## Summary

ElectionDeflection does not collect, store, or transmit any user data. All message filtering happens entirely on your device.

## Information We Collect

**None.**

ElectionDeflection does not collect any personal information, usage data, analytics, or telemetry. We do not have servers, databases, or any backend infrastructure that receives data from your device.

## How Your Messages Are Processed

When you receive a text message, iOS routes it through ElectionDeflection's message filter extension. The extension:

1. Reads the message content in a sandboxed environment
2. Checks it against local keyword lists or an on-device machine learning model
3. Returns a filter decision to iOS (allow or junk)
4. Discards the message content immediately — nothing is stored, logged, or transmitted

The filter extension runs in Apple's ILMessageFilterExtension sandbox, which prevents it from making network requests or writing data outside its process.

## Third-Party Services

ElectionDeflection uses **Apple StoreKit** for In-App Purchases. When you view the upgrade screen, StoreKit communicates with Apple's servers to load product pricing and process transactions. This is managed entirely by Apple — ElectionDeflection does not operate any payment servers or receive transaction details.

No other third-party services, SDKs, or analytics frameworks are included in the app.

## Data Storage

ElectionDeflection stores a small amount of configuration data locally on your device:

- Whether filtering is enabled or disabled
- Your selected filter method (keywords or AI)
- Whether you have Pro tier access
- Your keyword filter list

This data is stored in iOS App Groups UserDefaults and never leaves your device. No message content, phone numbers, or sender information is ever stored.

## Tracking

ElectionDeflection does not track you. The app does not use advertising identifiers (IDFA), device identifiers, or any form of user tracking.

## Your Rights

Because we do not collect any data, there is no personal data to access, export, or delete. Your filter preferences are stored only on your device and can be removed by uninstalling the app.

## Children's Privacy

ElectionDeflection does not collect any data from any user, including children under the age of 13.

## Changes to This Policy

If we update this privacy policy, we will update the "Last Updated" date above. Material changes will be noted in the app's release notes.

## Verify Our Claims

ElectionDeflection is open source. You can verify every privacy claim by:

- Inspecting the [source code on GitHub](https://github.com/MillerMedia/ElectionDeflection)
- Reading our [Privacy Architecture documentation](https://github.com/MillerMedia/ElectionDeflection/blob/main/PRIVACY.md)
- Monitoring network traffic with Charles Proxy or mitmproxy (instructions in PRIVACY.md)

## Contact

If you have questions about this privacy policy, please open an issue on our [GitHub repository](https://github.com/MillerMedia/ElectionDeflection/issues).
