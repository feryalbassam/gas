import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gas_on_go/changepassword.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../seller_authentication/login_screen_seller.dart';
import 'editsellerprofilepage.dart';

class ProfilesellerPage extends StatefulWidget {
  const ProfilesellerPage({Key? key}) : super(key: key);

  @override
  State<ProfilesellerPage> createState() => _ProfilesellerPageState();
}

class _ProfilesellerPageState extends State<ProfilesellerPage> {
  File? _imageFile;
  Map? driverData;

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref =
        FirebaseDatabase.instance.ref().child('drivers').child(user.uid);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        driverData = snapshot.value as Map?;
      });
    }
  }

  Future<void> pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _imageFile = File(picked.path);
      final ref = FirebaseStorage.instance
          .ref('profile_pictures')
          .child('${user.uid}.jpg');
      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();

      await FirebaseDatabase.instance
          .ref('drivers')
          .child(user.uid)
          .update({'photoUrl': url});

      setState(() {
        driverData?['photoUrl'] = url;
      });
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenSeller()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (driverData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child:
              CircularProgressIndicator(color: Color.fromARGB(255, 15, 15, 41)),
        ),
      );
    }

    final name = driverData?['name'] ?? 'Driver';
    final email = driverData?['email'] ?? 'No email';
    final phone = driverData?['phone'] ?? 'No phone';
    final photoUrl = driverData?['photoUrl'];

    final imageProvider = _imageFile != null
        ? FileImage(_imageFile!)
        : (photoUrl != null
            ? NetworkImage(photoUrl)
            : const AssetImage('assets/man.png')) as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 15, 15, 41),
        automaticallyImplyLeading: false,
        title: const Text("Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.edit,
                          color: Color.fromARGB(255, 15, 15, 41), size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Seller",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            _buildInfoTile(Icons.email, email),
            _buildInfoTile(Icons.phone, phone),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditSellerProfileScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // Same as name/email tiles
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.person_outline,
                        color: Color.fromARGB(255, 15, 15, 41)),
                    SizedBox(width: 20),
                    Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.chevron_right,
                        color: Color.fromARGB(255, 15, 15, 41)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline,
                        color: Color.fromARGB(255, 15, 15, 41)),
                    SizedBox(width: 20),
                    Text(
                      "Change Password",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Spacer(),
                    Icon(Icons.chevron_right,
                        color: Color.fromARGB(255, 15, 15, 41)),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: signOut,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Logout",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 15, 41),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Color.fromARGB(255, 15, 15, 41)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
