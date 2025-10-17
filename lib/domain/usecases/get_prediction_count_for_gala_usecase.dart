import '../repositories/prediction_repository.dart';

class GetPredictionCountForGalaUseCase {
  final PredictionRepository _repository;

  GetPredictionCountForGalaUseCase(this._repository);

  Future<int> execute(String galaId) {
    return _repository.getPredictionCountForGala(galaId);
  }
}
