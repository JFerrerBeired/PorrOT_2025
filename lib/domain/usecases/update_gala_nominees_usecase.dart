import '../repositories/gala_repository.dart';

class UpdateGalaNomineesUseCase {
  final GalaRepository _repository;

  UpdateGalaNomineesUseCase(this._repository);

  Future<void> execute(String galaId, List<String> nominatedContestantIds) {
    return _repository.updateGalaNominees(galaId, nominatedContestantIds);
  }
}
