# Google Play — Data safety guide

Use this document to fill in Play Console → **App content → Data safety**. The
answers below reflect the actual implemented behaviour of So‘z Atlas 1.0.0.

> Do not copy answers blindly: re-check the final build and privacy policy
> before submitting. If the app changes, update both this document and the
> privacy policy.

## Overview answers

| Question | Answer |
| --- | --- |
| Does your app collect or share any of the required user data types? | **No** |
| Does your app collect any data? | **No** |
| Does your app share any data with third parties? | **No** |
| Is all of the user data collected by your app encrypted in transit? | **N/A** (no data leaves the device) |
| Do you provide a way for users to request that their data be deleted? | **N/A** — all data is local; users can erase it in Settings or by uninstalling |

## Data types

No user data type is collected:

- Personal info: none
- Financial info: none
- Health and fitness: none
- Messages: none
- Photos and videos: none
- Audio: none (TTS output is generated on device; no microphone access)
- Files and docs: none
- Calendar: none
- Contacts: none
- App activity: none (learning progress is local and is not collected)
- Web browsing: none
- App info and performance: none (no analytics or crash reporting SDK)
- Device or other IDs: none

## Security practices

- App uses local SQLite on the device; nothing is transmitted.
- `android:allowBackup="false"`; learning data is not backed up to Google Drive.
- No account or authentication.
- No third-party SDKs (ads, analytics, crash reporting) are included.

## Permissions used

Release manifest requests **no permissions**. The app uses:

- the device's text-to-speech engine through the standard Android
  `TTS_SERVICE` query (no permission required);
- the system share sheet through an `ACTION_SEND` intent (no permission
  required).

Debug builds only (not release) include Flutter's standard `INTERNET`
permission so the Flutter tool can attach for hot reload.

## Ads / monetisation

- Contains ads: **No**
- In-app purchases: **No**
- Subscriptions: **No**

## Accounts

- Does the app require users to log in? **No**

## Families / children

The app does not collect data, has no ads and no external links. If the owner
targets children, complete the "Designed for Families" declarations honestly;
the current app is suitable for a general audience but this is the owner's
decision and declaration.

## App content declarations (separate from Data safety)

- **Privacy policy:** required — host `docs/PRIVACY_POLICY.md` at a public URL.
- **Ads:** No ads.
- **Content rating:** complete the questionnaire. Expected outcome:
  Everyone / 3+ (no violence, no mature content, no user-generated content, no
  data sharing).
- **Target audience:** owner decision. If only adults/general audience, select
  the relevant age group honestly.
- **News app / COVID / financial / government features:** none.
- **Data deletion:** since nothing is collected remotely, no deletion request
  flow is required. The in-app reset fulfils local deletion.
