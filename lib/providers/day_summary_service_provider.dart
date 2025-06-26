import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/day_summary_service.dart';

/// Provider for DaySummaryService
///
/// This provider exposes the DaySummaryService which includes:
/// - getDaySummary method for fetching a summary for a specific day in a trip
final daySummaryServiceProvider = Provider<DaySummaryService>((ref) {
  return DaySummaryService();
});
