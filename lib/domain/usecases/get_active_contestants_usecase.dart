import '../entities/contestant.dart';
import '../repositories/contestant_repository.dart';

class GetActiveContestantsUseCase {
  final ContestantRepository contestantRepository;

  GetActiveContestantsUseCase(this.contestantRepository);

  Future<List<Contestant>> call() async {
    final allContestants = await contestantRepository.getAllContestants();
    return allContestants
        .where((contestant) => contestant.status == ContestantStatus.active)
        .toList();
  }
}
