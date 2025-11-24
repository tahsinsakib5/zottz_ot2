// models/user_information.dart
class UserInformation {
  final String? id; // Document ID from Firebase
  final String userName;
  final int userAge;
  final int scissor;
  final int pencil;
  final int pincher;
  final int button;
  final String sessionDate;
  final int timer;
  final DateTime createdAt;

  UserInformation({
    this.id,
    required this.userName,
    required this.userAge,
    required this.scissor,
    required this.pencil,
    required this.pincher,
    required this.button,
    required this.sessionDate,
    required this.timer,
    required this.createdAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userAge': userAge,
      'scissor': scissor,
      'pencil': pencil,
      'pincher': pincher,
      'button': button,
      'sessionDate': sessionDate,
      'timer': timer,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firebase document
  factory UserInformation.fromMap(String id, Map<String, dynamic> map) {
    return UserInformation(
      id: id,
      userName: map['userName'] ?? '',
      userAge: map['userAge'] ?? 0,
      scissor: map['scissor'] ?? 0,
      pencil: map['pencil'] ?? 0,
      pincher: map['pincher'] ?? 0,
      button: map['button'] ?? 0,
      sessionDate: map['sessionDate'] ?? '',
      timer: map['timer'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}