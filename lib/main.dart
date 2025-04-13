import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_pages/dashboard.dart';
import 'package:gas_on_go/driver_pages/homedriver_page.dart';
import 'package:gas_on_go/firebase_options.dart';
import 'package:gas_on_go/pages/home_page.dart';
import 'package:gas_on_go/splash_screen.dart';
import 'package:gas_on_go/welcome/welcome_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/pages/order_placement.dart';
import 'package:gas_on_go/pages/order_tracking_screen.dart';
import 'package:gas_on_go/pages/profile_screen.dart';
import 'package:gas_on_go/pages/Order_history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.locationWhenInUse.isDenied.then((valueofPermission) {
    if (valueofPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AnimatedSplashScreenWidget(),
    );
  }
}
