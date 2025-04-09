part of 'pages.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationService _locationService = LocationService();
  LatLng? _userLocation;
  final LatLng _destination = const LatLng(
    -6.200000,
    106.816666,
  ); // Set your destination here
  double? _distance;
  String? _userName;
  // ignore: prefer_final_fields
  bool _mocked = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _initializeData();
  }

  void _initializeData() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      _userName = user?.name ?? 'Unknown';
    });
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue,
          child: Row(
            children: [
              const CircleAvatar(radius: 30),
              const SizedBox(width: 16),
              Text(
                _userName ?? 'Loading...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Work Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard("Working Hours", "8 hrs", Colors.green),
            _buildStatCard("Current Hours", "5 hrs", Colors.orange),
          ],
        ),
        const SizedBox(height: 16),

        // Map section
        Container(
          height: 300,
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
                    : FlutterMap(
                      options: MapOptions(
                        initialCenter: _userLocation!,
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _userLocation!,
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                            Marker(
                              point: _destination,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        CircleLayer(
                          circles: [
                            // CircleMarker(
                            //   point: _userLocation!,
                            //   color: Colors.blue.withOpacity(0.5),
                            //   radius: 10,
                            // ),
                            CircleMarker(
                              point: _destination,
                              color: Colors.red.withOpacity(0.5),
                              radius: 10000,
                              useRadiusInMeter: true,
                            ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [_userLocation!, _destination],
                              color: Colors.blue,
                              strokeWidth: 4.0,
                            ),
                          ],
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
                Text("Distance: ${_distance!.toStringAsFixed(2)} meters"),
                Text(
                  "Mock location detected: ${_mocked ? 'Yes' : 'No'}",
                  style: TextStyle(color: _mocked ? Colors.red : Colors.green),
                ),
              ],
            ),
          ),

        const Spacer(),
      ],
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
