import '../entities/gala.dart';
import '../repositories/gala_repository.dart';

class GetAllGalasUseCase {
  final GalaRepository galaRepository;

  GetAllGalasUseCase(this.galaRepository);

  Future<List<Gala>> call() {
    return galaRepository.getAllGalas();
  }
}
