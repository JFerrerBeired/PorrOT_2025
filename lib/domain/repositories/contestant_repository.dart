import '../entities/contestant.dart';

abstract class ContestantRepository {
  Future<void> createContestant(Contestant contestant);
  Future<void> updateContestant(Contestant contestant);
  Future<void> updateContestantStatus(
    String contestantId,
    ContestantStatus newStatus,
  );
  Future<List<Contestant>> getAllContestants();
  Future<Contestant> getContestantById(String id);
}
