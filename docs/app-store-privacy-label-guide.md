# App Store Connect Privacy Label Configuration

Internal guide for configuring ElectionDeflection's App Store privacy nutrition label.

## Current State: Zero Data Collection

ElectionDeflection does not collect any user data. The privacy label configuration is straightforward.

## App Store Connect Steps

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → **ElectionDeflection**
3. Select the app version under **App Store** tab
4. Scroll to **App Privacy** section
5. Click **Get Started** (or **Edit** if already configured)

### Privacy Questions

| Question | Answer |
|----------|--------|
| **Do you or your third-party partners collect data from this app?** | **No** |

That's it. With "No" selected, Apple displays **"Data Not Collected"** on the App Store listing. No further data type selections are needed.

### Tracking Question

| Question | Answer |
|----------|--------|
| **Do you or your third-party partners use data for tracking?** | **No** |

### Privacy Policy URL

Enter the URL for `PRIVACY_POLICY.md`:

- **Option A (GitHub raw):** `https://raw.githubusercontent.com/MillerMedia/ElectionDeflection/main/PRIVACY_POLICY.md`
- **Option B (GitHub Pages):** Configure GitHub Pages and use a cleaner URL
- **Option C (External):** Host on developer website

## Result

After submitting, the App Store listing displays:

> **Data Not Collected**
> The developer does not collect any data from this app.

## Story 8.1 Impact Warning

If Story 8.1 (Crowdsourced Text Submission) ships, the privacy label **must** be updated:

| Question | New Answer |
|----------|-----------|
| Do you or your third-party partners collect data? | **Yes** |
| Data type | **Other User Content** (user-submitted text messages) |
| Is the data linked to the user's identity? | **No** (anonymous submission) |
| Is the data used to track the user? | **No** |
| Purpose | **Product Improvement** (ML model training) |

This changes the label from "Data Not Collected" to showing a data collection disclosure. Update both this guide and `PRIVACY_POLICY.md` when Story 8.1 ships.
