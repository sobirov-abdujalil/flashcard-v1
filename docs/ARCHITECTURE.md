# Architecture — So‘z Atlas

So‘z Atlas is a single-module Flutter application (Android only) built around a
local SQLite database. It deliberately avoids heavy architecture frameworks;
the goal is a small, readable, tested codebase that a single developer can
maintain.

## 1. Layers

```
┌─────────────────────────────────────────────────────────────┐
│ UI (lib/features + lib/shared)                              │
│  Home · Learn · Recall · Session Complete · Settings sheet  │
├─────────────────────────────────────────────────────────────┤
│ Application state (lib/providers)                           │
│  Riverpod Notifiers: settings, session controller, revision │
├─────────────────────────────────────────────────────────────┤
│ Domain (lib/domain) — pure Dart, no Flutter widgets          │
│  SpacedRepetitionScheduler · SessionComposer ·             │
│  AnswerOptionsGenerator · RecallEngine · share text builder │
├─────────────────────────────────────────────────────────────┤
│ Data (lib/data)                                             │
│  AppDatabase (schema + seed) · repositories (SQL)          │
├─────────────────────────────────────────────────────────────┤
│ SQLite (sqflite) · shared_preferences · flutter_tts         │
└─────────────────────────────────────────────────────────────┘
```

Dependency direction is strictly downward: widgets never execute SQL, domain
classes never import Flutter widgets, and repositories know nothing about UI.

## 2. Folder map

| Path | Responsibility |
| --- | --- |
| `lib/core/theme/` | `SozAtlasColors` theme extension (dark + light palettes), `AppTheme`, Manrope typography, context extensions |
| `lib/core/constants/` | app constants, route names, parts of speech |
| `lib/core/utils/` | `LocalDate`, `StreakCalculator`, `DailyGoalPlanner`, haptics |
| `lib/data/database/` | `AppDatabase` (DDL, migrations, seeding, reset), `StudyDayDao` |
| `lib/data/models/` | `Word`, `WordProgress`, `StudyDay`, `HomeSnapshot`, `AppSettings` |
| `lib/data/seed/` | 50 A1 + 50 A2 words and dataset validation |
| `lib/data/repositories/` | `VocabularyRepository`, `ProgressRepository`, `DashboardRepository`, `SessionRepository`, `SettingsRepository` |
| `lib/domain/scheduler/` | interval scheduler (1/3/7/14/30 days) |
| `lib/domain/session/` | session composition, answer option generation, recall state machine |
| `lib/domain/models/` | session models (`LearningSession`, `SessionQuestion`, `SessionSummary`, …) |
| `lib/domain/summary/` | share text builder (pure) |
| `lib/providers/` | Riverpod wiring, `SessionController`, settings notifier |
| `lib/services/` | `TtsService` (offline TTS), `ShareService` (native share) |
| `lib/shared/widgets/` | design system: `GlassCard`, `GradientButton`, `WordCard`, `AnswerOption`, `ProgressRing`, `AtlasVisualization`, etc. |
| `lib/features/*` | the four screens and settings/privacy screens |

## 3. Database

SQLite file: `<app databases dir>/soz_atlas.db` (via `sqflite`).

Schema version **1**. `AppDatabase` accepts an injected `DatabaseFactory` and
path so every data path is exercised by host tests with `sqflite_common_ffi`.

### `words`

| column | notes |
| --- | --- |
| `id` INTEGER PK | stable seed id (1–50 A1, 101–150 A2) |
| `word`, `phonetic`, `part_of_speech`, `cefr_level` | learning metadata |
| `translation`, `definition`, `example`, `example_translation` | content |

Unique case-insensitive index on `word`, index on `cefr_level`.

### `word_progress`

| column | notes |
| --- | --- |
| `word_id` UNIQUE FK → `words(id)` ON DELETE CASCADE | one row per studied word |
| `last_review_at`, `next_review_at` | epoch milliseconds, due dates at **local midnight** |
| `successful_repetitions`, `lapse_count` | scheduler stage and lapses |
| `total_correct`, `total_attempts` | honest attempt counters |

Index on `next_review_at` for due queries.

### `study_days`

One row per local calendar date (`yyyy-MM-dd` UNIQUE) with
`completed_exercises`, `correct_answers`, `new_words_studied`,
`session_completed`.

### Seeding and migrations

- Vocabulary is inserted inside a transaction **only when `words` is empty**.
  Reopening the app never resets progress.
- `onUpgrade` contains a documented, ordered place for future migrations
  (`schemaVersion = 1` is the initial release).
- `resetLearningProgress()` deletes `word_progress` and `study_days` only; the
  vocabulary and settings survive.

## 4. Spaced repetition

`SpacedRepetitionScheduler` is a pure function:

```
success: stage = min(previous + 1, 5); interval = [1, 3, 7, 14, 30][stage - 1]
failure: stage = 0; lapses += 1; interval = 1 day
due date: local midnight of (today + interval)
```

- Calendar arithmetic uses `DateTime(y, m, d + n)` rather than `Duration`, so
  daylight-saving transitions cannot shift review dates.
- Due words are selected with `next_review_at <= now` ordered by oldest due
  first, which guarantees priority per the product definition.
- A retry inside the same session only updates attempt counters; the schedule is
  written once per word per session (the first attempt).

## 5. Session flow

`SessionRepository.createSession()`

1. Reads today's study day to determine how much of the daily goal remains.
2. Fetches due words (limit = size), then new words (A1 first), then least
   recently reviewed words if the session is still short.
3. `SessionComposer` orders and de-duplicates them.
4. `AnswerOptionsGenerator` builds one question per word: 4 unique Uzbek
   translations, distractors preferred from the same CEFR level and part of
   speech, correct index randomised.

`SessionController` (Riverpod `Notifier`):

```
startSession() → learning phase
revealMeaning() → nextLearnWord() → recall phase
answer(i) → persists first attempt (progress + study day), schedules retry
nextQuestion() → completeSession() → complete phase
```

Every answer is written in a transaction. While a write is in flight
`state.isSavingAnswer` disables the "next" action so an answer can never be
lost or counted twice.

## 6. State management

- `flutter_riverpod` (`Notifier` / `AsyncNotifier`, no code generation).
- `settingsProvider` — persisted theme mode and daily goal.
- `progressRevisionProvider` — bumped after every persisted change so the Home
  dashboard refetches real numbers.
- `homeSnapshotProvider` — one database pass producing a `HomeSnapshot`.
- `sessionProvider` — the whole Home → Learn → Recall → Complete journey.
- Providers are lazy; only the session controller is kept alive across routes.

## 7. Design system

- `SozAtlasColors` is a `ThemeExtension` with **separately designed** dark and
  light palettes (not an inversion).
- Glass surfaces (`GlassCard`) use translucent gradient layers + fine borders.
  `BackdropFilter` blur is opt-in and only used on the Home goal card, dialogs,
  the settings sheet and the completion screen medallion — never on lists or
  every card.
- Gradients: `#927CFF → #65C8F5 → #74E4C0` (dark) and a deeper equivalent for
  light-mode contrast.
- Custom painters: brand mark, constellation background, vocabulary atlas,
  progress rings, completion arc/sparkles, weekly chart uses widgets.
- Animation budget: 120–180 ms microinteractions, 180–280 ms transitions,
  ~560–760 ms completion; all decorative animations respect
  `MediaQuery.disableAnimations` (reduced motion).
- Text contrast: dark theme uses near-white on translucent navy; gradient
  buttons use a dark navy label (`#081120`) in dark mode and white in light
  mode for sufficient contrast on the bright gradient.

## 8. Error handling

- Database bootstrap failure → branded retry screen.
- Session creation failure → friendly snackbar with the reason.
- TTS missing/language unavailable → snackbar, learning continues.
- Persistence failure during an answer → warning message; UI stays usable.
- All plugin calls (TTS, share, haptics) are wrapped in `try/catch` and cannot
  crash the app.

## 9. Testing strategy

| Area | Tests |
| --- | --- |
| Scheduler rules, local dates | `test/domain/spaced_repetition_scheduler_test.dart` |
| Session composition, daily goal, streak | `test/domain/session_composer_test.dart` |
| Answer options uniqueness/plausibility | `test/domain/answer_options_generator_test.dart` |
| One-answer rule, retry queue, counters | `test/domain/recall_engine_test.dart` |
| Share text honesty | `test/domain/share_text_builder_test.dart` |
| Seed dataset validation | `test/data/seed_vocabulary_test.dart` |
| Real SQLite: seeding, persistence across reopen, scheduling, dashboard, reset | `test/data/database_and_session_test.dart` |
| Design system widgets, 360dp layout | `test/widget/design_system_test.dart` |
| Full Home → Learn → Recall → Complete journey with SQLite | `test/widget/full_journey_test.dart` |

Host database tests use `sqflite_common_ffi`; widget tests use the no-isolate
FFI factory so SQLite futures resolve inside the fake-async test zone.

## 10. Android

- `applicationId` / `namespace`: `uz.sozatlas.app`
- `minSdk` 24, `targetSdk` 36, `compileSdk` 36 (current Flutter stable defaults;
  satisfies Google Play's target API requirement at the time of writing).
- Adaptive launcher icon (foreground PNG + navy background + monochrome layer),
  branded Android 12+ splash screen and legacy splash.
- Release signing is read from an untracked `android/key.properties`; a missing
  file falls back to debug signing so builds remain reproducible for smoke
  tests.
- No runtime permissions are requested in release builds.
