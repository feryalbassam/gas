import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_on_go/gloabl/global_var.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
          key: sKey,
          drawer: Container(
            width: 225,
            color: Color.fromARGB(255, 15, 15, 41),
            child: Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                children: [
                  Container(
                      color: Color.fromARGB(255, 15, 15, 41),
                      height: 160,
                      child: DrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 60,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 188, 186, 186),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Profile',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 188, 186, 186),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ))),
                  const Divider(
                    height: 1,
                    color: Color.fromARGB(255, 188, 186, 186),
                    thickness: 2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    leading: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.info,
                          color: Color.fromARGB(255, 188, 186, 186),
                        )),
                    title: Text(
                      'About',
                      style:
                          TextStyle(color: Color.fromARGB(255, 188, 186, 186)),
                    ),
                  ),
                  ListTile(
                    leading: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.logout,
                          color: Color.fromARGB(255, 188, 186, 186),
                        )),
                    title: Text(
                      'Logout',
                      style:
                          TextStyle(color: Color.fromARGB(255, 188, 186, 186)),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  top: 10,
                  left: 19,
                  child: GestureDetector(
                    onTap: () {
                      sKey.currentState!.openDrawer();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 15, 15, 41),
                              blurRadius: 5,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ]),
                      child: CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 188, 186, 186),
                        radius: 20,
                        child: Icon(
                          Icons.menu,
                          color: Color.fromARGB(255, 15, 15, 41),
                        ),
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
