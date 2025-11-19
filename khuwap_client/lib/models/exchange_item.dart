class ExchangeItem {
  final String ownedTitle;
  final String ownedProfessor;
  final String ownedDay;
  final String ownedStart;
  final String ownedEnd;
  final String ownedCourseCode;
  final String ownedRoom;
  final int ownedCredit;

  final String desiredTitle;
  final String desiredProfessor;
  final String desiredDay;
  final String desiredStart;
  final String desiredEnd;
  final String desiredCourseCode;
  final String desiredRoom;
  final int desiredCredit;

  final String note;

  ExchangeItem({
    required this.ownedTitle,
    required this.ownedProfessor,
    required this.ownedDay,
    required this.ownedStart,
    required this.ownedEnd,
    required this.ownedCourseCode,
    required this.ownedRoom,
    required this.ownedCredit,
    required this.desiredTitle,
    required this.desiredProfessor,
    required this.desiredDay,
    required this.desiredStart,
    required this.desiredEnd,
    required this.desiredCourseCode,
    required this.desiredRoom,
    required this.desiredCredit,
    required this.note,
  });
}
