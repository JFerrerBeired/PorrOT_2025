import '../entities/app_config.dart';
import '../repositories/app_config_repository.dart';

class SetActiveGalaIdUseCase {
  final AppConfigRepository appConfigRepository;

  SetActiveGalaIdUseCase(this.appConfigRepository);

  Future<void> call(String galaId) async {
    final newConfig = AppConfig(activeGalaId: galaId);
    await appConfigRepository.updateAppConfig(newConfig);
  }
}
