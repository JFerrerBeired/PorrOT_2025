import '../entities/gala.dart';
import '../repositories/gala_repository.dart';

class CreateGalaUseCase {
  final GalaRepository _repository;

  CreateGalaUseCase(this._repository);

  Future<void> execute(Gala gala) {
    return _repository.createGala(gala);
  }
}
