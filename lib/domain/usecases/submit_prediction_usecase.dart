import '../entities/prediction.dart';
import '../repositories/prediction_repository.dart';

class SubmitPredictionUseCase {
  final PredictionRepository predictionRepository;

  SubmitPredictionUseCase(this.predictionRepository);

  Future<void> call(Prediction prediction) {
    return predictionRepository.savePrediction(prediction);
  }
}
