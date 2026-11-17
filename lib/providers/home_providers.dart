import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/models/home_snapshot.dart';
import '../data/repositories/dashboard_repository.dart';
import 'app_providers.dart';
import 'settings_provider.dart';

/// Real, database-backed Home statistics.
///
/// Rebuilds when the daily goal changes or when answers are persisted
/// ([progressRevisionProvider] is bumped after every saved answer).
final FutureProvider<HomeSnapshot> homeSnapshotProvider =
    FutureProvider<HomeSnapshot>((Ref ref) async {
      ref.watch(progressRevisionProvider);
      await ref.watch(appBootstrapProvider.future);
      final AppSettings settings = await ref.watch(settingsProvider.future);
      final DashboardRepository dashboard = ref.watch(
        dashboardRepositoryProvider,
      );
      return dashboard.load(dailyGoal: settings.dailyGoal);
    });
