import '../../domain/entities/app_config.dart';

class AppConfigModel extends AppConfig {
  AppConfigModel({required super.activeGalaId});

  factory AppConfigModel.fromFirestore(Map<String, dynamic> data) {
    return AppConfigModel(activeGalaId: data['activeGalaId']);
  }

  Map<String, dynamic> toFirestore() {
    return {'activeGalaId': activeGalaId};
  }
}
