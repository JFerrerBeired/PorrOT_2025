import '../entities/contestant.dart';
import '../repositories/contestant_repository.dart';

class CreateContestantUseCase {
  final ContestantRepository _repository;

  CreateContestantUseCase(this._repository);

  Future<void> execute(Contestant contestant) {
    return _repository.createContestant(contestant);
  }
}
