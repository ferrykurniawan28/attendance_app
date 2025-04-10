part of 'pages.dart';

class AttendnceHistory extends StatelessWidget {
  const AttendnceHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceService = AttendanceService();
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: FutureBuilder(
        future: attendanceService.fetchUserAttendances(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.white,
                    ),
                  ),
                  title: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          } else {
            final attendances = snapshot.data!;
            return ListView.builder(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                final attendance = attendances[index];
                return ListTile(
                  onTap:
                      () => Modular.to.pushNamed(
                        '/attendance-detail',
                        arguments: attendance,
                      ),
                  title: Text(attendance.name),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(attendance.datetime),
                  ),
                  leading: Image.network(attendance.photoUrl),
                  trailing: Icon(
                    attendance.isLate ? Icons.close : Icons.check,
                    color: attendance.isLate ? Colors.red : Colors.green,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
