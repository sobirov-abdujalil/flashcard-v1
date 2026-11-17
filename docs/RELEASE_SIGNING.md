# Android release signing — So‘z Atlas

The repository **does not contain any keystore or passwords**. Release signing is
read from an untracked file at `android/key.properties` (template:
`android/key.properties.example`).

If `android/key.properties` is missing, the release build falls back to the debug
signing key automatically. That keeps local builds working, but **an AAB signed
with the debug key cannot be uploaded to Google Play**.

## 1. Create the upload keystore (once)

Run from the `android/` directory (or use any keytool from JDK 17+):

```powershell
keytool -genkeypair -v `
  -keystore soz-atlas-upload.jks `
  -alias soz-atlas `
  -keyalg RSA -keysize 2048 -validity 10000
```

Tips:

- Use a strong password and store it in a password manager.
- Keep the `.jks` file outside the repository or in the git-ignored
  `android/` directory.
- If you lose this keystore, you cannot update the same Play listing unless you
  use Play App Signing key reset (possible, but painful). Back it up securely.
- Enrol in **Play App Signing** in Play Console (recommended; default for new
  apps). The keystore above then becomes your *upload* key.

## 2. Configure `android/key.properties`

Copy `android/key.properties.example` to `android/key.properties` and fill in:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=soz-atlas
storeFile=soz-atlas-upload.jks
```

`storeFile` is resolved relative to the `android/` directory.

`android/key.properties`, `*.jks` and `*.keystore` are ignored by git.

## 3. Build a signed release

```powershell
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

Verify the signature:

```powershell
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

or upload the AAB to Play Console → internal testing (Play validates it).

The `versionName` and `versionCode` come from `pubspec.yaml`
(`version: 1.0.0+1`). **Every Play upload needs a higher versionCode.**

## 4. Current state in this workspace

- No upload keystore was created here and no signing credentials were invented.
- The generated `app-release.aab` in this workspace is signed with the **debug
  key** (see the build report in `docs/PLAY_STORE_RELEASE_CHECKLIST.md`).
- The owner must follow steps 1–3 above before submitting to Google Play.

## 5. CI / secrets

For GitHub Actions or similar:

- store the keystore as a base64 secret, decode it before the build;
- create `android/key.properties` from repository secrets;
- never echo passwords in logs.
