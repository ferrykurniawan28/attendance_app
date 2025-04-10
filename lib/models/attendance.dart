part of 'models.dart';

class Attendance {
  final String? id;
  final String userId;
  final String name;
  final DateTime datetime;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final bool isMocked;
  final double distance;

  Attendance({
    this.id,
    required this.userId,
    required this.name,
    required this.datetime,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.isMocked,
    required this.distance,
  });

  bool get isLate {
    final lateTime = DateTime(
      datetime.year,
      datetime.month,
      datetime.day,
      8,
      30,
    );
    return datetime.isAfter(lateTime);
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      datetime: DateTime.parse(map['datetime']),
      photoUrl: map['photo_url'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isMocked: map['is_mocked'],
      distance: map['distance'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'datetime': datetime.toIso8601String(),
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'is_late': isLate,
      'is_mocked': isMocked,
      'distance': distance,
    };
  }
}
