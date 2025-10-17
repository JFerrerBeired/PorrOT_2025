import '../repositories/app_config_repository.dart';

class GetActiveGalaIdUseCase {
  final AppConfigRepository appConfigRepository;

  GetActiveGalaIdUseCase(this.appConfigRepository);

  Future<String?> call() async {
    final config = await appConfigRepository.getAppConfig();
    return config.activeGalaId;
  }
}
