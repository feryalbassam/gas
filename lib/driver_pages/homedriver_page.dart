import 'package:flutter/material.dart';

class HomedriverPage extends StatefulWidget {
  const HomedriverPage({super.key});

  @override
  State<HomedriverPage> createState() => _HomedriverPageState();
}

class _HomedriverPageState extends State<HomedriverPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Text(
          'home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
    ));
  }
}
