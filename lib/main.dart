import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_authentication/signup_screen_driver.dart';
import 'package:gas_on_go/driver_pages/driverdashboard.dart';
import 'package:gas_on_go/driver_pages/inventory_page.dart';
import 'package:gas_on_go/driver_pages/homedriver_page.dart';
import 'package:gas_on_go/driver_pages/profiledriver_page.dart';
import 'package:gas_on_go/driver_pages/earning_page.dart';
import 'package:gas_on_go/firebase_options.dart';
import 'package:gas_on_go/pages/Ratings_Reviews_Page.dart';
import 'package:gas_on_go/driver_pages/driver_map_screen.dart';
import 'package:gas_on_go/pages/earnings_transactions_page.dart';
import 'package:gas_on_go/pages/map.dart';
import 'package:gas_on_go/pages/map_page.dart';
import 'package:gas_on_go/pages/openstreetmap.dart';
import 'package:gas_on_go/user_pages/orders_detail_page.dart';
import 'package:gas_on_go/user_pages/Dashboard.dart';
import 'package:gas_on_go/user_pages/Payment%20Page.dart';
import 'package:gas_on_go/user_pages/edit_profile_page.dart';
import 'package:gas_on_go/user_pages/home_page.dart';
import 'package:gas_on_go/user_pages/notification_page.dart';
import 'package:gas_on_go/splash_screen.dart';
import 'package:gas_on_go/welcome/welcome_page.dart';
import 'package:gas_on_go/user_pages/Orders_list.dart';
import 'package:gas_on_go/widgets/placeholder_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:gas_on_go/user_pages/order_placement.dart';
import 'package:gas_on_go/user_pages/order_tracking_screen.dart';
import 'package:gas_on_go/user_pages/profile_screen.dart';
import 'package:gas_on_go/user_pages/Order_history.dart';

import 'authentication/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
        '/payment': (context) => const PaymentPage(
              orderId: '',
            ),
        '/edit_profile': (context) => const EditProfilePage(),
        '/notification': (context) => const NotificationsPage(),
      },
      home: AnimatedSplashScreenWidget(),
    );
  }
}
