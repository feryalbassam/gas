// Full implementation of a driver app screen using OpenStreetMap, Firestore, and live location updates
// This code assumes Firebase is initialized in your main.dart

/*import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (!mounted) return;
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); // ✅ إلغاء الاشتراك
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // واجهتك هنا
        );
  }
}*/
/*import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'openstreetmap.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  LatLng? driverLocation;
  final mapController = MapController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      driverLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _acceptOrder(String orderId, String userId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (driverLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver location not available")),
      );
      return;
    }

    // ✅ تحديث الطلب في Firestore
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'accepted',
      'driverId': user.uid,
      'driverLocation': {
        'lat': driverLocation!.latitude,
        'lng': driverLocation!.longitude,
      }
    });

    // ✅ إرسال إشعار للمستخدم
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .add({
      'title': 'Driver accepted your order',
      'body': 'Your order is on the way!',
      'orderId': orderId,
      'timestamp': Timestamp.now(),
      'read': false,
    });

    // ✅ الانتقال إلى شاشة التوصيل
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverDeliveryScreen(
          orderId: orderId,
          driverId: user.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Map"),
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
      ),
      body: driverLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🗺️ الخريطة
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: driverLocation!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: driverLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.local_shipping,
                                size: 40, color: Colors.green),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 📦 الطلبات
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final orders = snapshot.data!.docs;

                      if (orders.isEmpty) {
                        return const Center(child: Text("No pending orders."));
                      }

                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final data =
                              orders[index].data() as Map<String, dynamic>;
                          final orderId = orders[index].id;
                          final address = data['address'] ?? 'Unknown';
                          final quantity = data['quantity'] ?? 0;
                          final userId = data['userId'] ?? '';
                          final Timestamp timestamp =
                              data['timestamp'] ?? Timestamp.now();
                          final date = DateFormat('dd MMM yyyy – hh:mm a')
                              .format(timestamp.toDate());

                          return ListTile(
                            title: Text("$quantity Cylinder(s)"),
                            subtitle: Text("To: $address\n$date"),
                            trailing: ElevatedButton(
                              onPressed: () => _acceptOrder(orderId, userId),
                              child: const Text("Accept"),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}*/
/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeDriverPage extends StatefulWidget {
  const HomeDriverPage({super.key});

  @override
  State<HomeDriverPage> createState() => _HomeDriverPageState();
}

class _HomeDriverPageState extends State<HomeDriverPage> {
  LatLng? driverLocation;
  LatLng? destination;
  List<LatLng> _route = [];
  final mapController = MapController();
  String? orderId;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _getDriverLocation();
    _listenToAcceptedOrder();
  }

  Future<void> _getDriverLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      driverLocation = LatLng(pos.latitude, pos.longitude);
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((position) {
      setState(() {
        driverLocation = LatLng(position.latitude, position.longitude);
      });

      if (orderId != null) {
        FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'driverLocation': {
            'lat': position.latitude,
            'lng': position.longitude,
          }
        });
        if (destination != null) _fetchRoute();
      }
    });
  }

  void _listenToAcceptedOrder() {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'accepted')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          orderId = doc.id;
          destination =
              LatLng(data['destination']['lat'], data['destination']['lng']);
        });
        _fetchRoute();
      } else {
        setState(() {
          orderId = null;
          destination = null;
          _route = [];
        });
      }
    });
  }

  Future<void> _fetchRoute() async {
    if (driverLocation == null || destination == null) return;

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
        '${driverLocation!.longitude},${driverLocation!.latitude};'
        '${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decoded = polylinePoints.decodePolyline(geometry);
      setState(() {
        _route = decoded.map((e) => LatLng(e.latitude, e.longitude)).toList();
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      mapController.move(driverLocation!, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      mapController.move(driverLocation!, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            "Driver Home",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
      ),
      body: driverLocation == null
          ? const Center(child: Text("🚚 Waiting for driver location..."))
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: driverLocation!,
                    initialZoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (_route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
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
                          point: driverLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.local_shipping,
                              color: Colors.green, size: 40),
                        ),
                        if (destination != null)
                          Marker(
                            point: destination!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.flag,
                                color: Colors.red, size: 40),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 80,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomIn",
                        onPressed: _zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomOut",
                        onPressed: _zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_ratings_page.dart';

class HomeDriverPage extends StatefulWidget {
  const HomeDriverPage({super.key});

  @override
  State<HomeDriverPage> createState() => _HomeDriverPageState();
}

class _HomeDriverPageState extends State<HomeDriverPage> {
  LatLng? driverLocation;
  LatLng? destination;
  List<LatLng> _route = [];
  final mapController = MapController();
  String? orderId;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _getDriverLocation();
    _listenToAcceptedOrder();
  }

  Future<void> _getDriverLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      driverLocation = LatLng(pos.latitude, pos.longitude);
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((position) {
      setState(() {
        driverLocation = LatLng(position.latitude, position.longitude);
      });

      if (orderId != null) {
        FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'driverLocation': {
            'lat': position.latitude,
            'lng': position.longitude,
          }
        });
        if (destination != null) _fetchRoute();
      }
    });
  }

  void _listenToAcceptedOrder() {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'accepted')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          orderId = doc.id;
          destination =
              LatLng(data['destination']['lat'], data['destination']['lng']);
        });

        _fetchRoute();
        _listenToOrderCancellation(); // ✅ Now it will track cancellation for this order
      } else {
        setState(() {
          orderId = null;
          destination = null;
          _route = [];
        });
      }
    });
  }

  void _listenToOrderCancellation() {
    if (orderId == null) return;
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data()?['status'] == 'cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ The user has cancelled the order.")),
        );
        setState(() {
          orderId = null;
          destination = null;
          _route = [];
        });
      }
    });
  }

  Future<void> _fetchRoute() async {
    if (driverLocation == null || destination == null) return;

    print(
        "Fetching route from: ${driverLocation!.latitude},${driverLocation!.longitude} to ${destination!.latitude},${destination!.longitude}");

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
        '${driverLocation!.longitude},${driverLocation!.latitude};'
        '${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      print("Geometry: $geometry");

      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decoded = polylinePoints.decodePolyline(geometry);

      print("Decoded points: ${decoded.length}");

      setState(() {
        _route = decoded.map((e) => LatLng(e.latitude, e.longitude)).toList();
      });
    } else {
      print("Failed to fetch route: ${response.statusCode}");
    }
  }

  Future<void> sendCancellationNotificationToUser(
      String userId, String orderId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .add({
      'title': 'Order Cancelled ❌',
      'body': 'The driver cancelled your order #$orderId.',
      'orderId': orderId,
      'timestamp': Timestamp.now(),
      'read': false,
    });
  }

  Future<void> _cancelOrderByDriver() async {
    if (orderId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );

    if (confirm != true) return;

    final orderDoc =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final orderSnapshot = await orderDoc.get();

    if (orderSnapshot.exists) {
      final data = orderSnapshot.data()!;
      final userId = data['userId'];

      await orderDoc.update({
        'status': 'cancelled_by_driver',
        'cancelledAt': Timestamp.now(),
      });

      await sendCancellationNotificationToUser(userId, orderId!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order has been cancelled.")),
      );

      setState(() {
        orderId = null;
        destination = null;
        _route = [];
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      mapController.move(driverLocation!, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      mapController.move(driverLocation!, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Seller Map",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverRatingsPage(),
                ),
              );
            },
          ),
          if (orderId != null)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: _cancelOrderByDriver,
            ),
        ],
      ),
      body: driverLocation == null
          ? const Center(child: Text("🚚 Waiting for Seller location..."))
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: driverLocation!,
                    initialZoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (_route.isNotEmpty &&
                        driverLocation != null &&
                        destination != null)
                      PolylineLayer(
                        polylines: [
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
                          point: driverLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.local_shipping,
                              color: Colors.green, size: 40),
                        ),
                        if (destination != null)
                          Marker(
                            point: destination!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.flag,
                                color: Colors.red, size: 40),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 80,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomIn",
                        onPressed: _zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomOut",
                        onPressed: _zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
