import '../entities/contestant.dart';

abstract class ContestantRepository {
  Future<void> createContestant(Contestant contestant);
  Future<void> updateContestant(Contestant contestant);
  Future<List<Contestant>> getAllContestants();
  Future<Contestant> getContestantById(String id);
}
