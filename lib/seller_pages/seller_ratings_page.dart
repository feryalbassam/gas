import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SellerRatingsPage extends StatelessWidget {
  const SellerRatingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "⭐ Driver Ratings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
      ),
      backgroundColor: Colors.grey[100],
      body: driverId == null
          ? const Center(child: Text("Driver not logged in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('driverId', isEqualTo: driverId)
                  .where('status', isEqualTo: 'completed')
                  .where('rated', isEqualTo: true)
                  //.orderBy('rating', descending: true) // Uncomment after index creation
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No ratings found."));
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final rating = data['rating'] ?? 0;
                    final feedback = data['feedback'] ?? '';
                    final orderId = docs[index].id;
                    final customerName =
                        data['customerName'] ?? 'Unknown Customer';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                        : 'Unknown Time';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: $orderId",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 15, 15, 41),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "👤 Customer: $customerName",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          Text(
                            "🕒 $formattedDate",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              rating,
                              (index) => const Icon(Icons.star,
                                  color: Colors.amber, size: 22),
                            ),
                          ),
                          if (feedback.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              "\u{1F4AC} $feedback",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
