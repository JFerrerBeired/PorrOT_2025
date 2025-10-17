import '../entities/gala.dart';

abstract class GalaRepository {
  Future<void> createGala(Gala gala);
  Future<void> updateGala(Gala gala);
  Future<List<Gala>> getAllGalas();
  Future<Gala> getGalaById(String id);
}
