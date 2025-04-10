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
  bool _mocked = false;
  double? _distance;
  final _attendanceService = AttendanceService();
  final LatLng _destination = const LatLng(-6.200000, 106.816666); // Jakarta
  Attendance? _latestAttendance;
  bool _isLoadingAttendance = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _getCurrentLocation();
    await _loadLatestAttendance();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = Location();
      if (!await _ensureLocationPermissions(location)) return;

      final locationData = await location.getLocation().timeout(
        const Duration(seconds: 30),
      );

      if (locationData.latitude == null || locationData.longitude == null) {
        _showSnackBar('Unable to fetch location.');
        return;
      }

      final current = LatLng(locationData.latitude!, locationData.longitude!);
      final distance = Distance().as(LengthUnit.Meter, current, _destination);

      setState(() {
        _userLocation = current;
        _distance = distance;
        _mocked = locationData.isMock ?? false;
      });
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    }
  }

  Future<bool> _ensureLocationPermissions(Location location) async {
    if (!await location.serviceEnabled() && !await location.requestService()) {
      _showSnackBar('Location services are disabled.');
      return false;
    }

    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      _showSnackBar('Location permissions are denied.');
      return false;
    }

    return true;
  }

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (picked != null && mounted) {
      setState(() => _selfie = File(picked.path));
    }
  }

  Future<void> _loadLatestAttendance() async {
    try {
      setState(() => _isLoadingAttendance = true);
      final attendance = await _attendanceService.getLatestAttendance();
      if (mounted) {
        setState(() {
          _latestAttendance = attendance;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading attendance: $e');
        setState(() => _isLoadingAttendance = false);
      }
    }
  }

  Future<void> _submitAttendance() async {
    if (!_validateSubmission()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final now = DateTime.now();
      final isLate = now.hour > 8 || (now.hour == 8 && now.minute > 30);
      final fileName = '${user!.id}_${now.millisecondsSinceEpoch}.jpg';

      final selfiePath = 'selfies/$fileName';
      await Supabase.instance.client.storage
          .from('attendance')
          .upload(selfiePath, _selfie!);

      final selfieUrl = Supabase.instance.client.storage
          .from('attendance')
          .getPublicUrl(selfiePath);

      final userData = await UserService.getCurrentUser();

      await Supabase.instance.client.from('attendance').insert({
        'user_id': user.id,
        'name': userData!.name,
        'datetime': now.toIso8601String(),
        'photo_url': selfieUrl,
        'latitude': _userLocation!.latitude,
        'longitude': _userLocation!.longitude,
        'is_late': isLate,
        'distance': _distance,
      });

      _showSnackBar('Attendance submitted!');
      await _loadLatestAttendance(); // Refresh the latest attendance
    } catch (e) {
      _showSnackBar('Error submitting attendance: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _selfie = null;
        });
      }
    }
  }

  bool _validateSubmission() {
    if (_selfie == null || _userLocation == null) {
      _showSnackBar('Please take a selfie and allow GPS.');
      return false;
    }

    if (_mocked || _distance! > 100) {
      _showSnackBar('Invalid location or fake GPS detected.');
      return false;
    }

    if (_distance! > 50) {
      _showSnackBar('You are too far from the target location.');
      return false;
    }

    if (_distance! <= 0) {
      _showSnackBar('You are already at the target location.');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _getCurrentLocation();
              await _loadLatestAttendance();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Modular.to.pushNamed('/attendance-history'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoadingAttendance) {
      return Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return _latestAttendance != null
        ? _alreadyAttendanceWidget(_latestAttendance!)
        : _attendanceWidget();
  }

  Widget _alreadyAttendanceWidget(Attendance attendance) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(attendance.photoUrl),
        const SizedBox(height: 20),
        Text(
          'Attendance already submitted today at: ${DateFormat('HH:mm').format(attendance.datetime)}',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          attendance.isLate ? 'You are late!' : 'You are on time!',
          style: TextStyle(
            color: attendance.isLate ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Distance: ${attendance.distance.toStringAsFixed(2)} m',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Mocked: ${attendance.isMocked ? "Yes" : "No"}',
          style: TextStyle(
            color: attendance.isMocked ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _attendanceWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickSelfie,
            child: Stack(
              children: [
                Container(
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
                if (_selfie != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _selfie = null),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_distance != null) ...[
          Text(
            "Distance to target: ${_distance!.toStringAsFixed(2)} m",
            style: TextStyle(
              color:
                  _distance! >= 100
                      ? Colors.red
                      : _distance! < 50
                      ? Colors.green
                      : Colors.yellow,
            ),
          ),
          Text(
            "Mock location: ${_mocked ? "Yes" : "No"}",
            style: TextStyle(color: _mocked ? Colors.red : Colors.green),
          ),
          const SizedBox(height: 10),
        ],
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitAttendance,
          child:
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
        ),
      ],
    );
  }
}
