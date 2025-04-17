import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_pages/dashboard.dart';
import 'package:gas_on_go/pages/add_skills_screen.dart';
import 'package:gas_on_go/pages/edit_profile_page.dart';
import 'package:gas_on_go/pages/home_page.dart';
import 'package:gas_on_go/pages/notification_page.dart';
import 'package:gas_on_go/splash_screen.dart';
import 'package:gas_on_go/welcome/welcome_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/pages/order_placement.dart';
import 'package:gas_on_go/pages/order_tracking_screen.dart';
import 'package:gas_on_go/pages/profile_screen.dart';
import 'package:gas_on_go/pages/Order_history.dart';
import 'package:gas_on_go/widgets/placeholder_screen.dart';
import 'package:gas_on_go/pages/Payment Page.dart';

import 'authentication/login_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.collection('test').add({
    'status': 'connected',
    'timestamp': Timestamp.now(),
  });
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

      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) =>
        const PlaceholderScreen(title: "Edit Profile"),
        //const PlaceholderScreen(title: "Settings"),
       // '/order_details': (context) => const OrderDetailsPage(),
        //'/route_optimization': (context) => const RouteOptimizationPage(),
        '/order_placement': (context) => const OrderPlacementPage(),
        '/order_tracking': (context) => OrderTrackingScreen(orderId: ''),
        '/payment': (context) => const PaymentPage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/notification': (context) => const NotificationPage(),

      },

      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          :  const Dashboard()


    );
  }
}