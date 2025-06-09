import 'package:flutter/material.dart';
import 'package:gas_on_go/user_pages/user_homepage.dart';
import 'package:gas_on_go/user_pages/user_profile.dart';

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
    controller = TabController(length: 2, vsync: this);
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
