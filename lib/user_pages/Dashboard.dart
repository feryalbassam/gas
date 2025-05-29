import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_pages/inventory_page.dart';
import 'package:gas_on_go/driver_pages/homedriver_page.dart';
import 'package:gas_on_go/driver_pages/profiledriver_page.dart';
import 'package:gas_on_go/driver_pages/earning_page.dart';
import 'package:gas_on_go/user_pages/home_page.dart';
import 'package:gas_on_go/user_pages/order_tracking_screen.dart';
import 'package:gas_on_go/user_pages/profile.dart';
import 'package:gas_on_go/user_pages/profile_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  //bool isDriver = true;
  late TabController controller;
  int indexSelected = 0;

  void onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller.index = indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this); // ✅ Match to 2 pages
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose properly when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            HomePage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: indexSelected,
          unselectedItemColor: Color.fromARGB(255, 188, 186, 186),
          selectedItemColor: Color.fromARGB(255, 15, 15, 41),
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 18),
          type: BottomNavigationBarType.fixed,
          onTap: onBarItemClicked,
        ),
      ),
    );
  }
}
