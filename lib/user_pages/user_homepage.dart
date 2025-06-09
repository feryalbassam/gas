/*import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_on_go/gloabl/global_var.dart';
import 'package:gas_on_go/methods/common_methods.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../user_authentication/login_screen.dart';
import 'order_placement.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? _currentLatLng;
  LatLng? _driverLatLng;
  List<LatLng> _route = [];
  double _zoomLevel = 15;
  final MapController _mapController = MapController();
  CommonMethods cMethods = CommonMethods();
  final TextEditingController _searchController = TextEditingController();

  getCurrentLiveLocationOfUser() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position positionOfUser = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    if (!mounted) return;

    setState(() {
      _currentLatLng =
          LatLng(positionOfUser.latitude, positionOfUser.longitude);
    });

    saveLocationToFirestore(positionOfUser);
    await getUserInfoAndCheckBlockStatus();
  }

  void saveLocationToFirestore(Position position) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String addressText =
          "${placemarks.first.street}, ${placemarks.first.locality}";

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'address': addressText
      });
    }
  }

  getUserInfoAndCheckBlockStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child("users").child(uid);

    final snap = await usersRef.get();

    if (!mounted) return;

    if (snap.exists) {
      final data = snap.value as Map;
      final blockStatus = data['blockStatus'];

      if (blockStatus == 'no') {
        setState(() {
          userName = data['name'] ?? '';
        });
      } else {
        FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => LoginScreen()),
        );
        cMethods.displaySnackBar(
            'You are blocked. Contact the company.', context);
      }
    } else {
      FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => LoginScreen()),
      );
      cMethods.displaySnackBar(
          'Account data not found. Please sign up again.', context);
    }
  }

  Future<void> fetchRoute() async {
    if (_currentLatLng == null || _driverLatLng == null) return;
    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
        '${_driverLatLng!.longitude},${_driverLatLng!.latitude};'
        '${_currentLatLng!.longitude},${_currentLatLng!.latitude}?overview=full&geometries=polyline');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(geometry);
      setState(() {
        _route = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    }
  }

  void _goToMyLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    LatLng newLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLatLng = newLatLng;
      _mapController.move(newLatLng, _zoomLevel);
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String addressText =
          "${placemarks.first.street}, ${placemarks.first.locality}";

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'address': addressText,
      });
    }
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text;
    if (query.isEmpty) return;

    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      final searchedLatLng =
          LatLng(locations.first.latitude, locations.first.longitude);

      setState(() {
        _currentLatLng = searchedLatLng;
        _mapController.move(searchedLatLng, _zoomLevel);
      });

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          searchedLatLng.latitude,
          searchedLatLng.longitude,
        );

        String addressText =
            "${placemarks.first.street}, ${placemarks.first.locality}";

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'location': {
            'lat': searchedLatLng.latitude,
            'lng': searchedLatLng.longitude,
          },
          'address': addressText
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLiveLocationOfUser();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return SafeArea(
      child: Scaffold(
        body: _currentLatLng == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: currentUserId)
                        .where('status', whereIn: ['pending', 'accepted'])
                        .orderBy(FieldPath.documentId, descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final order = snapshot.data!.docs.first;
                        final data = order.data() as Map<String, dynamic>;

                        if (data['driverLocation'] != null) {
                          _driverLatLng = LatLng(
                            data['driverLocation']['lat'],
                            data['driverLocation']['lng'],
                          );
                          _mapController.move(_driverLatLng!, _zoomLevel);
                          fetchRoute();
                        }
                      }

                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLatLng!,
                          initialZoom: _zoomLevel,
                          onTap: (tapPosition, point) async {
                            setState(() {
                              _currentLatLng = point;
                            });
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              List<Placemark> placemarks =
                                  await placemarkFromCoordinates(
                                point.latitude,
                                point.longitude,
                              );
                              String addressText =
                                  "${placemarks.first.street}, ${placemarks.first.locality}";

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .update({
                                'location': {
                                  'lat': point.latitude,
                                  'lng': point.longitude
                                },
                                'address': addressText
                              });
                            }
                          },
                          onMapEvent: (event) {
                            setState(() {
                              _zoomLevel = _mapController.camera.zoom;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          PolylineLayer(
                            polylines: [
                              if (_route.isNotEmpty)
                                Polyline(
                                  points: _route,
                                  strokeWidth: 4.0,
                                  color: Colors.red,
                                ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLatLng!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.person_pin_circle,
                                    color: Color.fromARGB(255, 15, 15, 41),
                                    size: 40),
                              ),
                              if (_driverLatLng != null)
                                Marker(
                                  point: _driverLatLng!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.local_shipping,
                                      color: Colors.green, size: 40),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 70,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (value) => _searchLocation(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: "searchBtn",
                      backgroundColor: Colors.white,
                      onPressed: _searchLocation,
                      child: const Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrderPlacementPage()),
                        );
                      },
                      child: const Text(
                        "Place New Order",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 10,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          mini: true,
                          heroTag: "zoomIn",
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _zoomLevel += 1;
                              _mapController.move(
                                  _mapController.camera.center, _zoomLevel);
                            });
                          },
                          child: const Icon(Icons.zoom_in, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          mini: true,
                          heroTag: "zoomOut",
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _zoomLevel -= 1;
                              _mapController.move(
                                  _mapController.camera.center, _zoomLevel);
                            });
                          },
                          child:
                              const Icon(Icons.zoom_out, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          mini: true,
                          heroTag: "myLocation",
                          backgroundColor: Colors.white,
                          onPressed: _goToMyLocation,
                          child: const Icon(Icons.my_location,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../methods/common_methods.dart';
import 'order_placement.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? _currentLatLng;
  double _zoomLevel = 15;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final CommonMethods cMethods = CommonMethods();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
    await saveLocation(position.latitude, position.longitude);
  }

  Future<void> saveLocation(double lat, double lng) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      String addressText =
          "${placemarks.first.street}, ${placemarks.first.locality}";
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': {'lat': lat, 'lng': lng},
        'address': addressText,
      });
    }
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      final latLng =
          LatLng(locations.first.latitude, locations.first.longitude);
      setState(() {
        _currentLatLng = latLng;
        _mapController.move(latLng, _zoomLevel);
      });
      await saveLocation(latLng.latitude, latLng.longitude);
    }
  }

  void _goToMyLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    LatLng latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentLatLng = latLng;
      _mapController.move(latLng, _zoomLevel);
    });
    await saveLocation(latLng.latitude, latLng.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLatLng!,
                    initialZoom: _zoomLevel,
                    onTap: (tapPosition, point) async {
                      setState(() {
                        _currentLatLng = point;
                      });
                      await saveLocation(point.latitude, point.longitude);
                    },
                    onMapEvent: (event) {
                      setState(() {
                        _zoomLevel = _mapController.camera.zoom;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLatLng!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.person_pin_circle,
                              color: Color.fromARGB(255, 15, 15, 41), size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 70,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (value) => _searchLocation(),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: "searchBtn",
                    backgroundColor: Colors.white,
                    onPressed: _searchLocation,
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 15, 15, 41),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrderPlacementPage()),
                      );
                    },
                    child: const Text(
                      "Place New Order",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomIn",
                        backgroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _zoomLevel += 1;
                            _mapController.move(
                                _mapController.camera.center, _zoomLevel);
                          });
                        },
                        child: const Icon(Icons.zoom_in, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomOut",
                        backgroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _zoomLevel -= 1;
                            _mapController.move(
                                _mapController.camera.center, _zoomLevel);
                          });
                        },
                        child: const Icon(Icons.zoom_out, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        mini: true,
                        heroTag: "myLocation",
                        backgroundColor: Colors.white,
                        onPressed: _goToMyLocation,
                        child:
                            const Icon(Icons.my_location, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
