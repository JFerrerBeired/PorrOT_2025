import '../entities/prediction.dart';
import '../repositories/prediction_repository.dart';

class GetPredictionForGalaUseCase {
  final PredictionRepository predictionRepository;

  GetPredictionForGalaUseCase(this.predictionRepository);

  Future<Prediction?> call(String userId, String galaId) {
    return predictionRepository.getPredictionForGala(userId, galaId);
  }
}
