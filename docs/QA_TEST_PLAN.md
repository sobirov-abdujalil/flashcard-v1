# QA test plan and verification report — So‘z Atlas 1.0.0

Verification environment:

- Windows 11, Flutter stable 3.47.9 (Dart 3.13.7), Android SDK 36
- JDK: Android Studio bundled JBR 25 (used by Gradle 9.3.1 / AGP 9.1.0)
- **Real Android phone:** Redmi `25028RN03A`, Android 15, 720 × 1640 px,
  320 dpi → 360 × 820 dp. Release APK (`arm64-v8a`) installed via adb.
- Host database tests: `sqflite_common_ffi` SQLite on Windows
- Android emulator (Pixel 10 Pro XL) was used only for the first launch check;
  the emulator process proved unstable on this host (software GPU), so all
  interactive verification was moved to the real phone.
- Automated tests: 92 tests in `test/`, all passing.

Legend: **PASS** = executed and succeeded, **PARTIAL** = partly verified,
**N/A** = could not be verified in this environment, **OWNER** = requires the
app owner's action.

## 1. Automated suites

| # | Check | Command | Result |
| --- | --- | --- | --- |
| A1 | Dependency resolution | `flutter pub get` | PASS |
| A2 | Formatting | `dart format --set-exit-if-changed .` | PASS |
| A3 | Static analysis | `flutter analyze` | PASS — no issues |
| A4 | Unit + database + widget tests | `flutter test` | PASS — 92/92 |
| A5 | Debug APK build | `flutter build apk --debug` | PASS |
| A6 | Release App Bundle build | `flutter build appbundle --release` | PASS (debug-signed fallback; owner upload key required for Play) |
| A7 | Split release APKs (device testing) | `flutter build apk --release --split-per-abi` | PASS |

Test files and coverage:

| File | What it proves |
| --- | --- |
| `test/domain/spaced_repetition_scheduler_test.dart` | 1/3/7/14/30-day intervals, wrong-answer reset, local-day boundaries, leap year, year change |
| `test/domain/session_composer_test.dart` | due-first priority, cap at session size, no duplicates, fallback fill, daily goal session sizes, streak calculator |
| `test/domain/answer_options_generator_test.dart` | exactly 4 options, unique translations, correct answer always present, plausible distractors, randomised order |
| `test/domain/recall_engine_test.dart` | one answer per question, immediate feedback, retry queue, counters, retry never re-retried |
| `test/domain/share_text_builder_test.dart` | share text uses real numbers, omits unearned achievements |
| `test/data/seed_vocabulary_test.dart` | 100 words, 50 A1 + 50 A2, unique ids/words/translations, complete fields, IPA format |
| `test/data/database_and_session_test.dart` | real SQLite: seeding once, persistence across close/reopen, due prioritisation, interval chain, retry counters, streak, dashboard numbers, reset |
| `test/widget/design_system_test.dart` | button/answer/card behaviour, disabled/loading states, 360 dp layout without overflow, both themes |
| `test/widget/full_journey_test.dart` | end-to-end Home → Learn → Recall → Complete → Home with the real SQLite layer, wrong-answer feedback, settings/theme/daily-goal changes |

Additional host test: `test/data/ffi_smoke_test.dart` verifies SQLite FFI
availability.

## 2. Manual scenario checklist (real phone)

The app was installed as a release build on the phone and used for two complete
sessions: 10 answered exercises, 9 words retained (one scheduled for an earlier
review), current streak 1, today's bar in the weekly chart, and 2 lit nodes in
the vocabulary atlas — all numbers came from the SQLite database.

| # | Scenario | How verified | Result |
| --- | --- | --- | --- |
| 1 | Fresh installation | Clean install on the phone; app opened to Home with zero progress | PASS |
| 2 | Initial vocabulary seeding | First session contained A1 words (apple, water, bread, house, friend) | PASS |
| 3 | Starting a session | "Boshlash" opens Learn with `1 / 5` and a new word | PASS |
| 4 | Reveal meaning | "Ma’nosini ko‘rish" animates in the translation, definition and example | PASS |
| 5 | Pronunciation | Speaker button is wired to the device TTS engine; no crash. Audible output not verified by the tester | PARTIAL |
| 6 | Correct answer | Mint glow, check icon, "To‘g‘ri javob!" feedback | PASS |
| 7 | Incorrect answer | Wrong option shakes gently, correct option revealed, honest feedback text | PARTIAL (feedback verified by automated widget test; DB stats show one word not retained) |
| 8 | Next question | "Keyingi so‘z" advances only after the answer is persisted | PASS |
| 9 | Session completion | Completion screen with real statistics | PASS (automated journey test) |
| 10 | Daily progress update | Home shows `5 / 5 bajarildi`, 100 % ring and updated counters | PASS |
| 11 | Streak calculation | After the completed session the home streak showed `1 kun` | PASS |
| 12 | Review scheduling | "O‘rganilgan 10" vs "Yodda qolgan 9" — the incorrect word is no longer counted as retained; due counter shown on Home | PASS |
| 13 | App restart / persistence | App was force-stopped and relaunched; progress kept | PASS |
| 14 | Database persistence | Same as above; SQLite only | PASS |
| 15 | Light theme | Phone system theme was light; the independent light palette rendered correctly | PASS |
| 16 | Dark theme | Automated widget tests cover the dark theme; layout not captured on the phone | PARTIAL |
| 17 | Changing daily target | Covered by widget test (Home updates to `0 / 10`; session size changes) | PASS (automated) |
| 18 | Reset confirmation | Confirmation dialog and reset behaviour covered by widget/data tests | PASS (automated) |
| 19 | Native sharing | Button calls the Android share sheet; not exercised on the phone | PARTIAL |
| 20 | Offline use | The app makes no network calls and the release manifest requests no INTERNET permission | PASS |
| 21 | Small-screen layout | 360 × 820 dp phone plus automated 360 × 740 dp widget layout test; no overflow errors | PASS |
| 22 | Large text / accessibility | Not specifically tested beyond default scale | PARTIAL |
| 23 | Reduced motion | Code respects `MediaQuery.disableAnimations`; not device-tested | PARTIAL |
| 24 | TTS unavailable | Defensive error handling and message path implemented; not device-tested | PARTIAL |
| 25 | Kill mid-session | Progress is saved per answer; remaining daily goal resumes next session (verified by tests) | PASS (automated) |

## 3. Edge cases covered by automated tests

- Session larger than due reviews → fills with new words.
- More due words than the goal → only the oldest `size` are used.
- Incorrect answer schedules a 1-day review and resets the stage.
- Retry inside the same session cannot double-apply the scheduler.
- A partially completed daily goal creates a session with the remaining size.
- Completing the daily goal still offers a full extra practice session.
- Streak: today-only, yesterday-only, consecutive, gap, month/year boundary.
- Reset clears progress but not vocabulary.
- Reopening the database does not duplicate seeded vocabulary.
- Foreign keys reject progress for unknown words.
- Multiple taps on one answer cannot register twice (engine throws).
- Share text never fabricates achievements.
- 360 dp layout: no render overflow.
- Full journey with real SQLite database through the widget tree.

## 4. Screenshots

Real screenshots captured from the app are in `screenshots/`; Play-formatted
(1080 × 1920, valid 9:16 aspect) versions are in `store_assets/screenshots/`:

- `01_home_light.png` — Home (light theme, zero state)
- `02_learn_light.png` — Learn screen with a new word
- `03_recall_light.png` — Recall screen with four Uzbek options

Remaining screenshots for the Play listing (dark theme Home/Learn/Recall,
Session Complete, Settings, atlas) should be captured by the owner on the final
signed build; the plan is in `docs/PLAY_STORE_LISTING.md`.

## 5. Not verified in this environment

- Audible TTS output quality on physical devices (depends on the installed
  engine/voice data).
- Dark-theme screenshots on the real phone (covered by automated widget tests).
- Play Console internal testing, content rating, data safety review.
- A release AAB signed with the owner's upload key.
- Google Play approval. **No claim of Play approval is made.**
- The Android emulator was unstable on this host; it was only used for a first
  launch/render check. All interactive checks above were done on the real phone.

## 6. Re-running verification

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

For device verification:

```powershell
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n uz.sozatlas.app/.MainActivity
```
