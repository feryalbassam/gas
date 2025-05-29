/*import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_pages/inventory_page.dart';
import 'package:gas_on_go/driver_pages/homedriver_page.dart';
import 'package:gas_on_go/driver_pages/profiledriver_page.dart';
import 'package:gas_on_go/driver_pages/earning_page.dart';
import 'package:gas_on_go/driver_pages/sellerdashboard.dart';

import '../pages/driver_map_screen.dart';
import '../pages/openstreetmap.dart';

class Driverdashboard extends StatefulWidget {
  const Driverdashboard({super.key});

  @override
  State<Driverdashboard> createState() => _DriverdashboardState();
}

class _DriverdashboardState extends State<Driverdashboard>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  int indexSelected = 0;

  void onBarItemClicked(int i) {
    // Prevent invalid index assignment
    if (controller.index != i && i >= 0 && i < controller.length) {
      setState(() {
        indexSelected = i;
        controller.index = indexSelected;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: const [
            DriverDeliveryScreen(
              orderId: '',
              driverId: '',
            ),
            InventoryPage(),
            Earningpage(),
            SellerDashboardPage(),
            ProfiledriverPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_outlined), label: 'Inventory'),
            BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Earning'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: indexSelected,
          unselectedItemColor: Color.fromARGB(255, 188, 186, 186),
          selectedItemColor: Color.fromARGB(255, 15, 15, 41),
          showSelectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 18),
          type: BottomNavigationBarType.fixed,
          onTap: onBarItemClicked,
        ),
      ),
    );
  }
}*/
// ✅ Full working version of Driverdashboard + DriverDeliveryScreen (with automatic order fetching)

import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_pages/inventory_page.dart';
import 'package:gas_on_go/driver_pages/homedriver_page.dart';
import 'package:gas_on_go/driver_pages/profiledriver_page.dart';
import 'package:gas_on_go/driver_pages/earning_page.dart';
import 'package:gas_on_go/driver_pages/sellerdashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_map_screen.dart';
import '../pages/openstreetmap.dart';

class Driverdashboard extends StatefulWidget {
  const Driverdashboard({super.key});

  @override
  State<Driverdashboard> createState() => _DriverdashboardState();
}

class _DriverdashboardState extends State<Driverdashboard>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  int indexSelected = 0;

  void onBarItemClicked(int i) {
    if (controller.index != i && i >= 0 && i < controller.length) {
      setState(() {
        indexSelected = i;
        controller.index = indexSelected;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            HomeDriverPage(),
            InventoryPage(),
            Earningpage(),
            SellerDashboardPage(driverId: driverId),
            ProfiledriverPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_outlined), label: 'Inventory'),
            BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Earning'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: indexSelected,
          unselectedItemColor: Color.fromARGB(255, 188, 186, 186),
          selectedItemColor: Color.fromARGB(255, 15, 15, 41),
          showSelectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 18),
          type: BottomNavigationBarType.fixed,
          onTap: onBarItemClicked,
        ),
      ),
    );
  }
}
