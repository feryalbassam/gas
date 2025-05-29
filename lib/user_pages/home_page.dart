/*import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_on_go/authentication/login_screen.dart';
import 'package:gas_on_go/gloabl/global_var.dart';
import 'package:gas_on_go/methods/common_methods.dart';
import 'package:gas_on_go/user_pages/profile_screen.dart';
import 'package:gas_on_go/welcome/welcome_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'order_placement.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUsers;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes('themes/standard_style.json')
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUsers = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUsers!.latitude, currentPositionOfUsers!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    saveLocationToFirestore(positionOfUser);
    await getUserInfoAndCheckBlockStatus();
  }

  void saveLocationToFirestore(Position position) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        }
      });
    }
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child(FirebaseAuth.instance.currentUser!.uid);
    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)['blockStatus'] == 'no') {
          setState(() {
            userName = (snap.snapshot.value as Map)['name'];
          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => LoginScreen()));
          cMethods.displaySnackBar(
              'You are blocked. Contact Company .', context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                updateMapTheme(controllerGoogleMap!);
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLiveLocationOfUser();
              },
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
          ],
        ),
      ),
    );
  }
}*/
// Updated: Replaced GoogleMap with OpenStreetMap and integrated live location

// Updated HomePage to show live order tracking for current user with driver marker and order status

// Updated HomePage to show live order tracking, driver marker, order status, and zoom controls

// Updated HomePage with driver auto-follow and polyline route to user

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_on_go/authentication/login_screen.dart';
import 'package:gas_on_go/gloabl/global_var.dart';
import 'package:gas_on_go/methods/common_methods.dart';
import 'package:gas_on_go/user_pages/profile_screen.dart';
import 'package:gas_on_go/welcome/welcome_page.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
            : StreamBuilder<QuerySnapshot>(
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

                  return Stack(
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
                      ),
                      Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 15, 15, 41),
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
                              child: const Icon(Icons.zoom_in,
                                  color: Colors.black),
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
                              child: const Icon(Icons.zoom_out,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
