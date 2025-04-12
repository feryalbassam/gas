import 'dart:async';
import 'dart:convert';
//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../gloabl/global_var.dart';
import '../pages/order_placement.dart';

class HomedriverPage extends StatefulWidget {
  const HomedriverPage({super.key});

  @override
  State<HomedriverPage> createState() => _HomedriverPageState();
}

class _HomedriverPageState extends State<HomedriverPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUsers;

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes('themes/standard_style.json')
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    var byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUsers = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUsers!.latitude, currentPositionOfUsers!.longitude);
    CameraPosition cameraPosition =
    CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
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
                  getCurrentLiveLocationOfDriver();
                },
              ),
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF114195),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrderPlacementPage()),
                    );
                  },
                  child: const Text(
                    "Place New Order",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}