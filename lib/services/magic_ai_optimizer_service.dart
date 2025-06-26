import 'dart:async';
import 'dart:math';
import '../widgets/trip_itinerary/magic_ai_optimizer_bottom_sheet.dart';

/// Service that handles the magic AI trip optimization functionality.
/// This service simulates API calls to an AI optimization endpoint.
class MagicAiOptimizerService {
  /// Simulates calling the magic AI optimization endpoint.
  /// 
  /// [strategy] - The optimization strategy selected by the user
  /// [tripId] - The ID of the trip to optimize
  /// 
  /// Returns a [Future] that completes after simulating the API call delay.
  /// In a real implementation, this would make an actual HTTP request.
  Future<MagicAiOptimizationResult> optimizeTrip({
    required OptimizationStrategy strategy,
    required String tripId,
  }) async {
    // Simulate network delay (2-4 seconds)
    final random = Random();
    final delaySeconds = 2 + random.nextInt(3);
    await Future.delayed(Duration(seconds: delaySeconds));
    
    // Simulate occasional failures (10% chance)
    if (random.nextInt(10) == 0) {
      throw MagicAiOptimizationException('Network error occurred during optimization');
    }
    
    // Return success result with simulated improvements
    return MagicAiOptimizationResult(
      success: true,
      strategy: strategy,
      tripId: tripId,
      improvementsFound: _generateImprovements(strategy),
      optimizationTime: delaySeconds,
    );
  }
  
  /// Generates simulated improvements based on the selected strategy
  List<String> _generateImprovements(OptimizationStrategy strategy) {
    final random = Random();
    final improvements = <String>[];
    
    switch (strategy) {
      case OptimizationStrategy.timeEfficient:
        final timeImprovements = [
          'Reordered locations to reduce travel time by 25%',
          'Found faster routes between destinations',
          'Optimized daily schedules to avoid rush hours',
          'Grouped nearby attractions for efficient visits',
          'Suggested optimal departure times',
        ];
        improvements.addAll(_selectRandomItems(timeImprovements, 2 + random.nextInt(2)));
        break;
        
      case OptimizationStrategy.costEffective:
        final costImprovements = [
          'Found budget-friendly alternatives saving \$150',
          'Identified free activities and attractions',
          'Suggested cost-effective transportation options',
          'Recommended affordable dining options',
          'Found discount opportunities and deals',
        ];
        improvements.addAll(_selectRandomItems(costImprovements, 2 + random.nextInt(2)));
        break;
        
      case OptimizationStrategy.experienceMaximizer:
        final experienceImprovements = [
          'Discovered 3 hidden gems off the beaten path',
          'Added unique local experiences to your itinerary',
          'Found exclusive cultural events during your visit',
          'Suggested authentic local dining experiences',
          'Identified Instagram-worthy photo spots',
        ];
        improvements.addAll(_selectRandomItems(experienceImprovements, 2 + random.nextInt(2)));
        break;
    }
    
    return improvements;
  }
  
  /// Selects random items from a list without duplicates
  List<String> _selectRandomItems(List<String> items, int count) {
    final random = Random();
    final shuffled = List<String>.from(items)..shuffle(random);
    return shuffled.take(count).toList();
  }
}

/// Result of a magic AI optimization operation
class MagicAiOptimizationResult {
  /// Whether the optimization was successful
  final bool success;
  
  /// The strategy that was used for optimization
  final OptimizationStrategy strategy;
  
  /// The ID of the trip that was optimized
  final String tripId;
  
  /// List of improvements found during optimization
  final List<String> improvementsFound;
  
  /// Time taken for optimization in seconds
  final int optimizationTime;
  
  const MagicAiOptimizationResult({
    required this.success,
    required this.strategy,
    required this.tripId,
    required this.improvementsFound,
    required this.optimizationTime,
  });
  
  /// Gets a human-readable name for the strategy
  String get strategyName {
    switch (strategy) {
      case OptimizationStrategy.timeEfficient:
        return 'Time Efficient';
      case OptimizationStrategy.costEffective:
        return 'Cost Effective';
      case OptimizationStrategy.experienceMaximizer:
        return 'Experience Maximizer';
    }
  }
}

/// Exception thrown when magic AI optimization fails
class MagicAiOptimizationException implements Exception {
  final String message;
  
  const MagicAiOptimizationException(this.message);
  
  @override
  String toString() => 'MagicAiOptimizationException: $message';
}