import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    uploadAssetImageToFirebase('assets/gas.png');
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      await uploadImageToFirebase(_imageFile!);
    }
  }

  Future<void> uploadImageToFirebase(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('${user.uid}.jpg');

    await ref.putFile(imageFile);
    final downloadURL = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': downloadURL,
    });

    setState(() {
      userData?['photoUrl'] = downloadURL;
    });
  }

  Future<void> uploadAssetImageToFirebase(String assetPath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('${user.uid}.jpg');


    try {
      await ref.getDownloadURL();
      print("✅ ");
      return;
    } catch (_) {
      print("⬆️  assets...");
    }

    final byteData = await rootBundle.load(assetPath);
    final tempFile = File('${(await getTemporaryDirectory()).path}/temp_profile.png');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());

    await ref.putFile(tempFile);
    final downloadURL = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': downloadURL,
    });

    setState(() {
      userData?['photoUrl'] = downloadURL;
    });

    print("✅ Firestore");
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF114195)),
        ),
      );
    }

    final name = userData!['name'] ?? 'Guest';
    final email = userData!['email'] ?? 'No email';
    final accountType = userData!['accountType'] ?? 'User';
    final photoUrl = userData!['photoUrl'] ?? 'https://via.placeholder.com/150';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
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
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : NetworkImage(photoUrl) as ImageProvider,
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
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.edit, color: Color(0xFF114195), size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(accountType,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            _buildOptionTile(context, Icons.person_outline, "Edit Profile", '/edit_profile'),
            _buildOptionTile(context, Icons.notifications_none_outlined, "Notification", '/notification'),
            _buildOptionTile(context, Icons.location_on_outlined, "Shipping Address", '/shipping_address'),
            _buildOptionTile(context, Icons.lock_outline, "Change Password", '/change_password'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Sign Out", style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114195),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF114195)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
