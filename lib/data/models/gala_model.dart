import '../../domain/entities/gala.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GalaModel extends Gala {
  GalaModel({
    super.galaId,
    required super.galaNumber,
    required super.date,
    required super.nominatedContestants,
    required super.results,
  });

  factory GalaModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return GalaModel(
      galaId: documentId,
      galaNumber: data['galaNumber'],
      date: (data['date'] as Timestamp).toDate(),
      nominatedContestants: List<String>.from(data['nominatedContestants']),
      results: Map<String, dynamic>.from(data['results']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'galaNumber': galaNumber,
      'date': Timestamp.fromDate(date),
      'nominatedContestants': nominatedContestants,
      'results': results,
    };
  }
}
