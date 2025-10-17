import '../entities/app_config.dart';

abstract class AppConfigRepository {
  Future<AppConfig> getAppConfig();
  Future<void> updateAppConfig(AppConfig config);
}
