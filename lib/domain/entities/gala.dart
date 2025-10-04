class Gala {
  final String galaId;
  final int galaNumber;
  final DateTime date;
  final List<String> nominatedContestants;
  final Map<String, dynamic> results;

  Gala({
    required this.galaId,
    required this.galaNumber,
    required this.date,
    required this.nominatedContestants,
    required this.results,
  });
}
