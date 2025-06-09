import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gas_on_go/seller_pages/profileseller_page.dart';
import 'package:gas_on_go/seller_pages/sellerdashboardpage.dart';
import 'homeseller_map_page.dart';
import 'earning_page.dart';
import 'inventory_page.dart';

class Sellerdashboard extends StatefulWidget {
  const Sellerdashboard({super.key});

  @override
  State<Sellerdashboard> createState() => _SellerdashboardState();
}

class _SellerdashboardState extends State<Sellerdashboard>
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
            HomeSellerPage(),
            InventoryPage(),
            Earningpage(),
            SellerDashboardPage(driverId: driverId),
            ProfilesellerPage(),
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
