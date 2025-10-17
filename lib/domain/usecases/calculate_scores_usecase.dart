import '../entities/gala.dart';
import '../entities/prediction.dart';
import '../repositories/gala_repository.dart';
import '../repositories/prediction_repository.dart';
import '../repositories/user_repository.dart';
import '../services/score_calculator.dart';

class CalculateScoresUseCase {
  final GalaRepository _galaRepository;
  final PredictionRepository _predictionRepository;
  final UserRepository _userRepository;
  final ScoreCalculator _scoreCalculator;

  CalculateScoresUseCase(
    this._galaRepository,
    this._predictionRepository,
    this._userRepository,
    this._scoreCalculator,
  );

  Future<void> execute(String galaId) async {
    // 1. Fetch the gala with the results
    final gala = await _galaRepository.getGalaById(galaId);
    if (gala == null || gala.results.isEmpty) {
      throw Exception('Gala not found or results not available.');
    }

    // 2. Fetch all predictions for that gala
    final predictions = await _predictionRepository.getPredictionsForGala(galaId);

    // 3. For each prediction, calculate the score
    for (final prediction in predictions) {
      final scoreResult = _scoreCalculator.calculateScore(prediction, gala);
      final updatedPrediction = Prediction(
        userId: prediction.userId,
        galaId: prediction.galaId,
        favoriteId: prediction.favoriteId,
        eliminatedId: prediction.eliminatedId,
        nomineeProposalIds: prediction.nomineeProposalIds,
        savedByProfessorsId: prediction.savedByProfessorsId,
        savedByPeersId: prediction.savedByPeersId,
        score: scoreResult['score'],
        scoreBreakdown: scoreResult['scoreBreakdown'],
      );

      // 4. Update the prediction document
      await _predictionRepository.savePrediction(updatedPrediction);
    }

    // 5. Recalculate and update the totalScore for each user
    await _updateUserTotalScores(predictions);
  }

  Future<void> _updateUserTotalScores(List<Prediction> predictions) async {
    final userScores = <String, int>{};

    // Aggregate scores for each user
    for (final prediction in predictions) {
      final score = prediction.score ?? 0;
      userScores.update(prediction.userId, (value) => value + score,
          ifAbsent: () => score);
    }

    // Update each user's total score
    for (final entry in userScores.entries) {
      final userId = entry.key;
      final newScore = entry.value;

      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(totalScore: user.totalScore + newScore);
        await _userRepository.updateUser(updatedUser);
      }
    }
  }
}
