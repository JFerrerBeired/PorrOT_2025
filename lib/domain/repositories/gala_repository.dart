import '../entities/gala.dart';

abstract class GalaRepository {
  Future<void> createGala(Gala gala);
  Future<void> updateGala(Gala gala);
  Future<void> updateGalaNominees(String galaId, List<String> nominatedContestantIds);
  Future<List<Gala>> getAllGalas();
  Future<Gala?> getGalaById(String id);
}
