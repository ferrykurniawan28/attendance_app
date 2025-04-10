part of 'services.dart';

class AttendanceService {
  final supabase = Supabase.instance.client;

  Future<void> submitAttendance(Attendance attendance) async {
    await supabase.from('attendance').insert(attendance.toMap());
  }

  Future<List<Attendance>> fetchUserAttendances() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await supabase
        .from('attendance')
        .select()
        .eq('user_id', userId)
        .order('datetime', ascending: false);

    return (response as List).map((e) => Attendance.fromMap(e)).toList();
  }

  Future<Attendance?> getLatestAttendance() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final response = await supabase
        .from('attendance')
        .select()
        .eq('user_id', userId)
        .gte('datetime', startOfDay.toIso8601String())
        .order('datetime', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      return Attendance.fromMap(response.first);
    }
    return null;
  }
}
