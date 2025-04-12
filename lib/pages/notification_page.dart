import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_tracking_screen.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  Stream<QuerySnapshot> getUserNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(user!.uid)
        .collection('user_notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user!.uid)
        .collection('user_notifications')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF114195),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF114195)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final body = data['body'] ?? '';
              final isRead = data['read'] ?? false;
              final orderId = data['orderId']; // 🔗 الربط مع الطلب

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white : const Color(0xFF114195).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.notifications, color: isRead ? Colors.grey : const Color(0xFF114195)),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(body),
                  trailing: isRead ? null : const Icon(Icons.circle, color: Color(0xFF114195), size: 10),
                  onTap: () {
                    if (orderId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingScreen(orderId: orderId),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
