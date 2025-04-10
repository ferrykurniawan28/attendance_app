part of 'pages.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () async {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return; // Exit if the service is not enabled
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return; // Exit if the permission is not granted
        }
      }

      Modular.to.navigate('/auth');
    });

    return Scaffold(
      body: Center(
        child: const Text('Attendance App', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
