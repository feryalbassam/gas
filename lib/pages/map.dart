import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_on_go/methods/common_methods.dart';
import 'package:gas_on_go/user_pages/order_placement.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class MergedMapPage extends StatefulWidget {
  const MergedMapPage({super.key});

  @override
  State<MergedMapPage> createState() => _MergedMapPageState();
}

class _MergedMapPageState extends State<MergedMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? controllerGoogleMap;

  static const LatLng _pGooglePlex = LatLng(32.5569, 35.8492); // Source
  static const LatLng _pApplePark = LatLng(32.5500, 35.8600); // Destination

  LatLng? _currentP;
  Map<PolylineId, Polyline> polylines = {};
  Location _locationController = Location();

  CommonMethods cMethods = CommonMethods();

  @override
  void initState() {
    super.initState();
    _initLocationAndRoute();
  }

  Future<void> _initLocationAndRoute() async {
    await getLocationUpdates();
    List<LatLng> coords = await getPolylinePoints();
    generatePolyLineFromPoints(coords);
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
        saveLocationToFirestore(
            currentLocation.latitude!, currentLocation.longitude!);
      }
    });
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 15);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void saveLocationToFirestore(double lat, double lng) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': {'lat': lat, 'lng': lng}
      });
    }
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'YOUR_API_KEY',
      request: PolylineRequest(
        origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
        destination: PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      width: 6,
      points: polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    controllerGoogleMap = controller;
                    _mapController.complete(controller);
                  },
                  mapType: MapType.normal,
                  initialCameraPosition:
                      CameraPosition(target: _pGooglePlex, zoom: 14),
                  myLocationEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId("current"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                      position: _currentP!,
                      infoWindow: const InfoWindow(title: "You"),
                    ),
                    Marker(
                      markerId: const MarkerId("source"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      position: _pGooglePlex,
                      infoWindow: const InfoWindow(title: "Source"),
                    ),
                    Marker(
                      markerId: const MarkerId("destination"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                      position: _pApplePark,
                      infoWindow: const InfoWindow(title: "Destination"),
                    ),
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
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
                )
              ],
            ),
    );
  }
}
