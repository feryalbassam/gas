import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../changepassword.dart';
import '../user_authentication/login_screen.dart';
import 'edit_profile_page.dart';
import 'notification_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _imageFile = File(picked.path);
      final ref =
          FirebaseStorage.instance.ref('profile_pictures/${user.uid}.jpg');
      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': url});

      setState(() {
        userData?['photoUrl'] = url;
      });
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child:
              CircularProgressIndicator(color: Color.fromARGB(255, 15, 15, 41)),
        ),
      );
    }

    final name = userData?['name'] ?? 'User';
    final email = userData?['email'] ?? 'No email';
    final phone = userData?['phone'] ?? 'No phone';
    final photoUrl = userData?['photoUrl'];

    final imageProvider = _imageFile != null
        ? FileImage(_imageFile!)
        : (photoUrl != null
            ? NetworkImage(photoUrl)
            : const AssetImage('assets/gas.png')) as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
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
            const Text("User",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            _buildInfoTile(Icons.email, email),
            _buildInfoTile(Icons.phone, phone),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()));
              },
              child: _buildActionTile(Icons.person_outline, "Edit Profile"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()));
              },
              child: _buildActionTile(Icons.lock_outline, "Change Password"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
              child: _buildActionTile(
                  Icons.notifications_none, "My Notifications"),
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
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 15, 15, 41)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 15, 15, 41)),
          const SizedBox(width: 20),
          Text(title,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
          const Spacer(),
          const Icon(Icons.chevron_right,
              color: Color.fromARGB(255, 15, 15, 41)),
        ],
      ),
    );
  }
}
