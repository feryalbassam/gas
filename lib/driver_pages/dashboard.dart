import 'package:flutter/material.dart';
import 'package:gas_on_go/driver_pages/earnings_page.dart';
import 'package:gas_on_go/driver_pages/homedriver_page.dart';
import 'package:gas_on_go/driver_pages/profiledriver_page.dart';
import 'package:gas_on_go/driver_pages/trips_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
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
    controller = TabController(length: 4, vsync: this);
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
          children: const [
            HomedriverPage(),
            EarningsPage(),
            TripsPage(),
            ProfiledriverPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.credit_card), label: 'Earnings'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_tree), label: 'Trips'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: indexSelected,
          unselectedItemColor: Color.fromARGB(255, 188, 186, 186),
          selectedItemColor: Color.fromARGB(255, 41, 107, 211),
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 18),
          type: BottomNavigationBarType.fixed,
          onTap: onBarItemClicked,
        ),
      ),
    );
  }
}
