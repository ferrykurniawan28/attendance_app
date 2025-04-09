part of 'pages.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  File? _selfie;
  LatLng? _userLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();

    if (!await location.serviceEnabled()) {
      await location.requestService();
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      await location.requestPermission();
    }

    final locationData = await location.getLocation();
    setState(() {
      _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() {
        _selfie = File(picked.path);
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_selfie == null || _userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a selfie and allow GPS.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final name = user?.userMetadata?['name'] ?? 'User';
      final now = DateTime.now();
      final fileName = '${user!.id}_${now.millisecondsSinceEpoch}.jpg';

      final selfiePath = 'selfies/$fileName';
      await Supabase.instance.client.storage
          .from('attendance')
          .upload(selfiePath, _selfie!);

      final selfieUrl = Supabase.instance.client.storage
          .from('attendance')
          .getPublicUrl(selfiePath);

      await Supabase.instance.client.from('attendance').insert({
        'user_id': user.id,
        'name': name,
        'datetime': now.toIso8601String(),
        'photo_url': selfieUrl,
        'latitude': _userLocation!.latitude,
        'longitude': _userLocation!.longitude,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Attendance submitted!')));

      setState(() {
        _selfie = null;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickSelfie,
                  child: Container(
                    // height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                      image:
                          _selfie != null
                              ? DecorationImage(
                                image: FileImage(_selfie!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _selfie == null
                            ? Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey[700],
                              ),
                            )
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAttendance,
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
