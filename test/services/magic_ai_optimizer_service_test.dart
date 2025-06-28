import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/services/magic_ai_optimizer_service.dart';
import 'package:travel_genie/widgets/trip_itinerary/magic_ai_optimizer_bottom_sheet.dart';

void main() {
  group('MagicAiOptimizerService', () {
    late MagicAiOptimizerService service;

    setUp(() {
      service = MagicAiOptimizerService();
    });

    test('should successfully optimize trip with time efficient strategy', () async {
      final result = await service.optimizeTrip(
        strategy: OptimizationStrategy.timeEfficient,
        tripId: 'test-trip-123',
      );

      expect(result.success, isTrue);
      expect(result.strategy, OptimizationStrategy.timeEfficient);
      expect(result.tripId, 'test-trip-123');
      expect(result.strategyName, 'Time Efficient');
      expect(result.improvementsFound, isNotEmpty);
      expect(result.optimizationTime, greaterThan(0));
    });

    test('should successfully optimize trip with cost effective strategy', () async {
      final result = await service.optimizeTrip(
        strategy: OptimizationStrategy.costEffective,
        tripId: 'test-trip-456',
      );

      expect(result.success, isTrue);
      expect(result.strategy, OptimizationStrategy.costEffective);
      expect(result.tripId, 'test-trip-456');
      expect(result.strategyName, 'Cost Effective');
      expect(result.improvementsFound, isNotEmpty);
      expect(result.optimizationTime, greaterThan(0));
    });

    test('should successfully optimize trip with experience maximizer strategy', () async {
      final result = await service.optimizeTrip(
        strategy: OptimizationStrategy.experienceMaximizer,
        tripId: 'test-trip-789',
      );

      expect(result.success, isTrue);
      expect(result.strategy, OptimizationStrategy.experienceMaximizer);
      expect(result.tripId, 'test-trip-789');
      expect(result.strategyName, 'Experience Maximizer');
      expect(result.improvementsFound, isNotEmpty);
      expect(result.optimizationTime, greaterThan(0));
    });

    test('should return different improvements for different strategies', () async {
      final timeResult = await service.optimizeTrip(
        strategy: OptimizationStrategy.timeEfficient,
        tripId: 'test-trip',
      );
      
      final costResult = await service.optimizeTrip(
        strategy: OptimizationStrategy.costEffective,
        tripId: 'test-trip',
      );

      // Results should be different (though this might occasionally fail due to randomness)
      expect(timeResult.improvementsFound, isNot(equals(costResult.improvementsFound)));
    });

    test('should have reasonable optimization time', () async {
      final stopwatch = Stopwatch()..start();
      
      await service.optimizeTrip(
        strategy: OptimizationStrategy.timeEfficient,
        tripId: 'test-trip',
      );
      
      stopwatch.stop();
      
      // Should take at least 2 seconds (minimum delay) but not more than 10 seconds
      expect(stopwatch.elapsedMilliseconds, greaterThan(2000));
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });
  });

  group('MagicAiOptimizationResult', () {
    test('should return correct strategy names', () {
      final timeResult = MagicAiOptimizationResult(
        success: true,
        strategy: OptimizationStrategy.timeEfficient,
        tripId: 'test',
        improvementsFound: [],
        optimizationTime: 3,
      );

      final costResult = MagicAiOptimizationResult(
        success: true,
        strategy: OptimizationStrategy.costEffective,
        tripId: 'test',
        improvementsFound: [],
        optimizationTime: 3,
      );

      final experienceResult = MagicAiOptimizationResult(
        success: true,
        strategy: OptimizationStrategy.experienceMaximizer,
        tripId: 'test',
        improvementsFound: [],
        optimizationTime: 3,
      );

      expect(timeResult.strategyName, 'Time Efficient');
      expect(costResult.strategyName, 'Cost Effective');
      expect(experienceResult.strategyName, 'Experience Maximizer');
    });
  });
}