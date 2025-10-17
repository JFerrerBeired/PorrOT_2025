import '../entities/gala.dart';
import '../repositories/gala_repository.dart';

class GetGalaDetailsUseCase {
  final GalaRepository galaRepository;

  GetGalaDetailsUseCase(this.galaRepository);

  Future<Gala> call(String galaId) {
    return galaRepository.getGalaById(galaId);
  }
}
