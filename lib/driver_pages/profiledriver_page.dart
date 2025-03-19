import 'package:flutter/material.dart';

class ProfiledriverPage extends StatefulWidget {
  const ProfiledriverPage({super.key});

  @override
  State<ProfiledriverPage> createState() => _ProfiledriverPageState();
}

class _ProfiledriverPageState extends State<ProfiledriverPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Text(
          'profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
    ));
  }
}
