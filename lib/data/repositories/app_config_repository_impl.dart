import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/repositories/app_config_repository.dart';
import '../models/app_config_model.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'app_config';
  static const String _documentPath = 'settings';

  AppConfigRepositoryImpl(this._firestore);

  @override
  Future<AppConfig> getAppConfig() async {
    final doc = await _firestore
        .collection(_collectionPath)
        .doc(_documentPath)
        .get();
    if (doc.exists) {
      return AppConfigModel.fromFirestore(doc.data()!);
    } else {
      // Return a default config if the document doesn't exist
      return AppConfig(activeGalaId: '');
    }
  }

  @override
  Future<void> updateAppConfig(AppConfig config) async {
    final configModel = AppConfigModel(activeGalaId: config.activeGalaId);
    await _firestore
        .collection(_collectionPath)
        .doc(_documentPath)
        .set(configModel.toFirestore());
  }
}
