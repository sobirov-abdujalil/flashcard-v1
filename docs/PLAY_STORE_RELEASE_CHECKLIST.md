# Google Play release checklist — So‘z Atlas

Status of this workspace: the app is implemented and both required build
artifacts are produced. Google Play submission itself has **not** been done and
cannot be done from this workspace. Items marked **[OWNER]** require the app
owner's Play Console account, signing secrets or public hosting.

## 0. Before anything else

- [ ] **[OWNER]** Confirm the final application id: `uz.sozatlas.app`.
      Changing it after the first upload creates a different app identity.
- [ ] **[OWNER]** Decide the developer/publisher name and contact email.
- [ ] **[OWNER]** Create the Play Console developer account (one-time $25 fee
      applies, Google's fee).
- [ ] **[OWNER]** Host `docs/PRIVACY_POLICY.md` at a public HTTPS URL and fill in
      the contact details.
- [ ] **[OWNER]** Enrol in Play App Signing (recommended) and create an upload
      keystore — see `docs/RELEASE_SIGNING.md`.
- [ ] Configure `android/key.properties`, build a signed AAB and verify its
      signature.

## 1. Android build configuration (verified in this workspace)

- [x] `applicationId = "uz.sozatlas.app"`, namespace `uz.sozatlas.app`.
- [x] App label `So‘z Atlas`.
- [x] Version name `1.0.0`, version code `1` (from `pubspec.yaml`).
- [x] `minSdk 24`, `targetSdk 36`, `compileSdk 36` (Flutter 3.47.9 stable
      defaults; meets the Play target API requirement at the time of build).
- [x] Release signing reads untracked `android/key.properties`, falls back to
      debug signing with a clear warning.
- [x] Adaptive launcher icon (background + foreground + monochrome).
- [x] Legacy launcher icons for every density.
- [x] Branded Android 12+ splash screen and pre-12 launch background.
- [x] No unnecessary permissions in the release manifest (no `INTERNET`).
- [x] `android:allowBackup="false"` (learning data never leaves the device).
- [x] Locale: app UI is Uzbek (Latin); no runtime locale switch required.

## 2. Build and test

- [x] `flutter pub get`
- [x] `dart format --set-exit-if-changed .`
- [x] `flutter analyze` — no issues
- [x] `flutter test` — 92 tests pass
- [x] `flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk`
- [x] `flutter build appbundle --release` →
      `build/app/outputs/bundle/release/app-release.aab`
- [x] Release APK (`arm64-v8a`) installed on a real Android 15 phone; two full
      sessions completed and progress persisted (see `docs/QA_TEST_PLAN.md`)
- [ ] **[OWNER]** Build with the real upload keystore and upload the AAB to
      **internal testing** first.
- [ ] **[OWNER]** Install from the internal testing track on at least one real
      Android phone and complete a full session on the Play-signed build.
      (Uninstall the debug-signed test build first — Android rejects a
      signature change on upgrade.)

## 3. Google Play Console — app content

Complete these sections in Play Console → App content. Answer honestly; the
guidance below matches the current app.

- [ ] **Privacy policy** — add the public URL of the hosted privacy policy.
- [ ] **Ads** — "No, my app does not contain ads".
- [ ] **App access** — "All functionality is available without special access"
      (no login).
- [ ] **Content rating** — complete the IARC questionnaire. Expected outcome:
      Everyone / 3+. No violence, no user-generated content, no purchases, no
      data sharing.
- [ ] **Target audience** — owner decision. If the app is for a general
      audience, select 13+ or 18+ honestly. Do not select "Designed for
      Families" unless you intend to meet the additional Families policy
      requirements.
- [ ] **News app** — No.
- [ ] **Data safety** — use `docs/DATA_SAFETY_GUIDE.md`: no data collected, no
      data shared.
- [ ] **Government app** — No.
- [ ] **Financial features** — No.
- [ ] **Health** — No.
- [ ] **Advertising ID** — the app does not use the advertising ID.
- [ ] **Permissions declarations** — none needed.

## 4. Store listing assets

- [x] App title: `So‘z Atlas — ingliz so‘zlari` (from `docs/PLAY_STORE_LISTING.md`)
- [x] Short description (≤80 chars)
- [x] Full description (≤4000 chars)
- [x] App icon 512×512 → `store_assets/icon_512.png`
- [x] Feature graphic 1024×500 → `store_assets/feature_graphic_1024x500.png`
- [x] 3 Play-formatted phone screenshots (1080×1920): Home (light), Learn
      (light), Recall (light) → `store_assets/screenshots/`
- [ ] **[OWNER]** Capture the remaining screenshots from the final signed build
      (min 2 required in total; 8 max): dark Home / Learn / Recall, Session
      Complete, Settings sheet, vocabulary atlas. Raw captures are in
      `screenshots/`; reframe with `tool/make_store_screenshots.py`.
- [ ] **[OWNER]** Optional: 7-inch/10-inch tablet screenshots — the app is
      portrait phone-first; tablets are not specifically designed for. If you
      do not provide tablet screenshots, the listing still works for phones.
- [ ] Localised listing: default language Uzbek (`uz-UZ`). Adding English
      localisation is optional and not part of the current build.

## 5. Testing tracks

- [ ] **[OWNER]** Create an internal testing release with the signed AAB.
- [ ] **[OWNER]** Add testers (internal testing allows up to 100 email
      addresses).
- [ ] **[OWNER]** Run a closed test if required for new personal developer
      accounts (Google currently requires a 12-tester/14-day closed test for
      new personal accounts — check the current Play Console requirement).
- [ ] Collect a few real feedback items and fix blocking issues.

## 6. Production rollout

- [ ] **[OWNER]** Complete the "Review and roll out" checklist in Play Console.
- [ ] **[OWNER]** Choose staged rollout (recommended: 20% → 50% → 100%).
- [ ] **[OWNER]** Monitor Android vitals for crashes/ANRs for a few days.
- [ ] **[OWNER]** Keep the upload keystore and passwords backed up safely.

## 7. Known limitations to keep honest

- The app UI is Uzbek only.
- Content is 100 words (A1/A2); no audio files are bundled — pronunciation
  depends on the device's TTS engine and English voice data.
- UI is phone portrait focused; landscape/tablet layouts are usable but not
  specially designed.
- No cloud sync: uninstalling the app deletes all learning progress.
- The AAB in this workspace is **debug-signed** until the owner configures a
  release keystore.

## 8. Artifact record (this workspace)

| Artifact | Path | Status |
| --- | --- | --- |
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` | built |
| Release AAB | `build/app/outputs/bundle/release/app-release.aab` | built (debug-signed fallback) |
| Split release APKs | `build/app/outputs/flutter-apk/app-*-release.apk` | built for device testing |
| App icon 512 | `store_assets/icon_512.png` | generated |
| Feature graphic | `store_assets/feature_graphic_1024x500.png` | generated |
| Raw screenshots | `screenshots/` | captured from the real phone / emulator |
| Play screenshots | `store_assets/screenshots/` | 3 framed 1080×1920 screenshots |

The release build installed on the test phone is signed with the debug key
because no upload keystore exists in this workspace. This is expected and does
not affect functionality; it only means the owner must produce a properly signed
build before publishing (see `docs/RELEASE_SIGNING.md`).
