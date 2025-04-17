import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSkillsScreen extends StatefulWidget {
  const AddSkillsScreen({super.key});

  @override
  State<AddSkillsScreen> createState() => _AddSkillsScreenState();
}

class _AddSkillsScreenState extends State<AddSkillsScreen> {
  final TextEditingController _skillController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void _addSkill() async {
    final skill = _skillController.text.trim();
    if (skill.isEmpty || user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        //.add({'name': skill});
        .collection('skills')
        .add({'name': skill});
    _skillController.clear();
  }

  Stream<QuerySnapshot> _getSkills() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('skills')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Skills')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _skillController,
              decoration: InputDecoration(
                labelText: 'Enter a skill',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSkill,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Your Skills:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getSkills(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No skills added yet.');
                  }

                  final skills = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: skills.length,
                    itemBuilder: (context, index) {
                      final skill = skills[index]['name'];
                      return ListTile(
                        title: Text(skill),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
