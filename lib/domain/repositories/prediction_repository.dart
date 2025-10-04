import '../entities/prediction.dart';

abstract class PredictionRepository {
  Future<void> savePrediction(Prediction prediction);
  Future<Prediction?> getPredictionForGala(String userId, String galaId);
  Future<List<Prediction>> getPredictionsForGala(String galaId);
}
