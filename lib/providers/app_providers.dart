import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/vocabulary_repository.dart';
import '../services/share_service.dart';
import '../services/tts_service.dart';

/// The single database instance for the app. Closed with the provider scope.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((
  Ref ref,
) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<VocabularyRepository> vocabularyRepositoryProvider =
    Provider<VocabularyRepository>((Ref ref) {
      return VocabularyRepository(ref.watch(appDatabaseProvider));
    });

final Provider<ProgressRepository> progressRepositoryProvider =
    Provider<ProgressRepository>((Ref ref) {
      return ProgressRepository(ref.watch(appDatabaseProvider));
    });

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((Ref ref) {
      return DashboardRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(progressRepositoryProvider),
      );
    });

final Provider<SessionRepository> sessionRepositoryProvider =
    Provider<SessionRepository>((Ref ref) {
      return SessionRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(vocabularyRepositoryProvider),
        ref.watch(progressRepositoryProvider),
      );
    });

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) => SettingsRepository());

final Provider<TtsService> ttsServiceProvider = Provider<TtsService>((Ref ref) {
  final TtsService service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final Provider<ShareService> shareServiceProvider = Provider<ShareService>(
  (Ref ref) => const ShareService(),
);

/// Completes once the local database is open and the vocabulary is seeded.
final FutureProvider<void> appBootstrapProvider = FutureProvider<void>((
  Ref ref,
) async {
  await ref.watch(appDatabaseProvider).database;
});
