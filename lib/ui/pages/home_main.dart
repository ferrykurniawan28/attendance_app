part of 'pages.dart';

class Home extends StatefulWidget {
  final Function? toProfile;
  const Home({super.key, this.toProfile});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationService _locationService = LocationService();
  late Future<UserModel?> _userFuture;
  final mapCnontroller = MapController();
  LatLng? _userLocation;
  final LatLng _destination = const LatLng(
    -6.200000,
    106.816666,
  ); // Set your destination here
  double? _distance;
  Timer? _locationUpdateTimer;
  bool _mocked = false;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.getCurrentUser();
    _getUserLocation();
    _startLocationUpdates();
  }

  void _refresh() {
    setState(() {
      _userLocation = null;
      _distance = null;
    });
    _userFuture = UserService.getCurrentUser();
    _getUserLocation();
  }

  void _startLocationUpdates() {
    if (_userLocation != null) {
      _locationUpdateTimer?.cancel();
    } else {
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 15), (
        timer,
      ) {
        _getUserLocation();
      });
    }
  }

  void _getUserLocation() async {
    final result = await _locationService.getLocationWithDistance(
      destination: _destination,
      context: context,
    );

    if (result == null) return;

    setState(() {
      _userLocation = result.position;
      _distance = result.distanceFromTarget ?? 0.0;
      _mocked = result.isMocked;
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue,
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.toProfile as void Function()?,
                      child: FutureBuilder(
                        future: _userFuture, // Use the stored Future
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 25,
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.error),
                            );
                          }
                          final user = snapshot.data;
                          final profileUrl = user?.photoProfileUrl;
                          if (profileUrl == null || profileUrl.isEmpty) {
                            return const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.person),
                            );
                          }
                          return CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(profileUrl),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    FutureBuilder(
                      future: _userFuture, // Use the same stored Future
                      builder: (_, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            'Error',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        final user = snapshot.data;
                        final userName = user?.name ?? 'Unknown';
                        return Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Map section
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child:
                    _userLocation == null
                        ? const Center(child: Text('Loading map...'))
                        : Stack(
                          children: [
                            FlutterMap(
                              mapController: mapCnontroller,
                              options: MapOptions(
                                initialCenter: _userLocation!,
                                initialZoom: 16.0,
                                interactionOptions: InteractionOptions(),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: [_userLocation!, _destination],
                                      color: Colors.green,
                                      strokeWidth: 4.0,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  alignment: Alignment.topCenter,
                                  markers: [
                                    Marker(
                                      point: _userLocation!,
                                      child: const Icon(
                                        Icons.person_pin_circle,
                                        color: Colors.blue,
                                      ),
                                      alignment: Alignment.topCenter,
                                    ),
                                    Marker(
                                      point: _destination,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                      ),
                                      alignment: Alignment.topCenter,
                                    ),
                                  ],
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: _destination,
                                      color: Colors.red.withOpacity(0.5),
                                      radius: 50,
                                      useRadiusInMeter: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (_distance != null)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: _buildStatCard(
                                  "Distance",
                                  "${_distance!.toStringAsFixed(2)} m",
                                  Colors.blue,
                                ),
                              ),
                            if (_mocked)
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: _buildStatCard(
                                  "Mocked",
                                  "Yes",
                                  Colors.red,
                                ),
                              ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (_userLocation != null) {
                                    mapCnontroller.move(_userLocation!, 16.0);
                                  }
                                },
                                shape: const CircleBorder(),
                                child: const Icon(Icons.my_location),
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 8),

            // Distance & Anti-GPS Spoofing Info
            if (_distance != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      "Distance: ${_distance!.toStringAsFixed(2)} meters",
                      style: TextStyle(
                        color:
                            _distance! < 50
                                ? Colors.green
                                : _distance! < 100
                                ? Colors.yellow
                                : Colors.red,
                      ),
                    ),
                    Text(
                      "Mock location detected: ${_mocked ? 'Yes' : 'No'}",
                      style: TextStyle(
                        color: _mocked ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
