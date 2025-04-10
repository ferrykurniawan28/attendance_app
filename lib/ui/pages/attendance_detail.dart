part of 'pages.dart';

class AttendanceDetail extends StatelessWidget {
  final Attendance attendance;
  const AttendanceDetail({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${attendance.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd HH-MM').format(attendance.datetime)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${attendance.isLate ? 'Late' : 'On Time'}',
              style: TextStyle(
                fontSize: 16,
                color: attendance.isLate ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Image.network(attendance.photoUrl),
          ],
        ),
      ),
    );
  }
}
