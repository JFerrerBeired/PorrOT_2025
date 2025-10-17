import '../entities/contestant.dart';
import '../repositories/contestant_repository.dart';

class UpdateContestantStatusUseCase {
  final ContestantRepository _repository;

  UpdateContestantStatusUseCase(this._repository);

  Future<void> execute(String contestantId, ContestantStatus newStatus) {
    return _repository.updateContestantStatus(contestantId, newStatus);
  }
}