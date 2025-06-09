import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'order_tracking_screen.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
      if (doc['read'] == false) {
        await doc.reference.update({'read': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
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
            return const Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 15, 15, 41)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final String title = data['title'] ?? '';
              final String body = data['body'] ?? '';
              final bool isRead = data['read'] ?? false;
              final String? orderId = data['orderId'];
              final Timestamp? timestamp = data['timestamp'];
              final formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(timestamp.toDate())
                  : '';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isRead
                      ? Colors.white
                      : const Color.fromARGB(255, 15, 15, 41).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.notifications,
                      color: isRead
                          ? Colors.grey
                          : const Color.fromARGB(255, 15, 15, 41)),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body),
                      if (formattedDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(formattedDate,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ),
                    ],
                  ),
                  trailing: isRead
                      ? null
                      : const Icon(Icons.circle,
                          color: Color.fromARGB(255, 15, 15, 41), size: 10),
                  onTap: () async {
                    if (!isRead) {
                      await doc.reference.update({'read': true});
                    }

                    if (orderId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderTrackingScreen(orderId: orderId),
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
