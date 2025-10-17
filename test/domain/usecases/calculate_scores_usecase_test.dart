import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:porrot_2025/domain/entities/gala.dart';
import 'package:porrot_2025/domain/entities/prediction.dart';
import 'package:porrot_2025/domain/entities/user.dart';
import 'package:porrot_2025/domain/repositories/gala_repository.dart';
import 'package:porrot_2025/domain/repositories/prediction_repository.dart';
import 'package:porrot_2025/domain/repositories/user_repository.dart';
import 'package:porrot_2025/domain/services/score_calculator.dart';
import 'package:porrot_2025/domain/usecases/calculate_scores_usecase.dart';
import 'package:mockito/annotations.dart';

import 'calculate_scores_usecase_test.mocks.dart';

@GenerateMocks([
  GalaRepository,
  PredictionRepository,
  UserRepository,
  ScoreCalculator,
])
void main() {
  group('CalculateScoresUseCase', () {
    late CalculateScoresUseCase useCase;
    late MockGalaRepository mockGalaRepository;
    late MockPredictionRepository mockPredictionRepository;
    late MockUserRepository mockUserRepository;
    late MockScoreCalculator mockScoreCalculator;

    setUp(() {
      mockGalaRepository = MockGalaRepository();
      mockPredictionRepository = MockPredictionRepository();
      mockUserRepository = MockUserRepository();
      mockScoreCalculator = MockScoreCalculator();
      useCase = CalculateScoresUseCase(
        mockGalaRepository,
        mockPredictionRepository,
        mockUserRepository,
        mockScoreCalculator,
      );
    });

    // --- Test Data ---
    final gala = Gala(
        galaId: 'gala1',
        galaNumber: 1,
        date: DateTime.now(),
        results: {'favoriteId': 'c1'},
        nominatedContestants: []);
    final predictions = [
      Prediction(userId: 'user1', galaId: 'gala1', score: 10),
      Prediction(userId: 'user2', galaId: 'gala1', score: 5),
    ];
    final user1 = User(id: 'user1', displayName: 'User 1', totalScore: 100);
    final user2 = User(id: 'user2', displayName: 'User 2', totalScore: 50);

    test(
        'should fetch data, calculate scores, and update predictions and users',
        () async {
      // Arrange
      when(mockGalaRepository.getGalaById('gala1'))
          .thenAnswer((_) async => gala);
      when(mockPredictionRepository.getPredictionsForGala('gala1'))
          .thenAnswer((_) async => predictions);
      when(mockScoreCalculator.calculateScore(any, any)).thenReturn({
        'score': 10,
        'scoreBreakdown': {'favorite': 10}
      });
      when(mockUserRepository.getUserById('user1'))
          .thenAnswer((_) async => user1);
      when(mockUserRepository.getUserById('user2'))
          .thenAnswer((_) async => user2);
      when(mockPredictionRepository.savePrediction(any))
          .thenAnswer((_) async => {});
      when(mockUserRepository.updateUser(any)).thenAnswer((_) async => {});

      // Act
      await useCase.execute('gala1');

      // Assert
      verify(mockGalaRepository.getGalaById('gala1')).called(1);
      verify(mockPredictionRepository.getPredictionsForGala('gala1')).called(1);
      verify(mockScoreCalculator.calculateScore(any, any)).called(2);
      verify(mockPredictionRepository.savePrediction(any)).called(2);
      verify(mockUserRepository.getUserById('user1')).called(1);
      verify(mockUserRepository.getUserById('user2')).called(1);
      verify(mockUserRepository.updateUser(any)).called(2);
    });
  });
}