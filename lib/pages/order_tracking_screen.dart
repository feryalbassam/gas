// 🔥 Polished OrderTrackingScreen – Deeper Blue + Bolder Text

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  void openMapWithAddress(String address) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2ECFA), // More blue-ish background
      appBar: AppBar(
        backgroundColor: const Color(0xFF114195),
        elevation: 0,
        centerTitle: true,
        title: const Text("📦 Order Tracking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final tracking = List<Map<String, dynamic>>.from(data['tracking']);

          final estimatedDate = data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _headerCard(estimatedDate, data['status']),
              const SizedBox(height: 20),
              _timelineCard(tracking),
              const SizedBox(height: 20),
              _detailsCard(data, context),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(DateTime estimatedDate, String? status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E3E94), Color(0xFF3069d1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estimated Delivery",
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text("${estimatedDate.month}/${estimatedDate.day}/${estimatedDate.year}",
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status ?? "In Transit",
                style: const TextStyle(
                    color: Color(0xFF114195), fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(List<Map<String, dynamic>> tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFDDE8F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3E94))),
          const SizedBox(height: 16),
          Column(
            children: List.generate(tracking.length, (index) {
              final step = tracking[index];
              final isCompleted = step['isCompleted'];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      if (index != 0)
                        Container(width: 2, height: 20, color: Colors.grey.shade300),
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Color(0xFF114195) : Colors.white,
                          border: Border.all(
                            color: isCompleted ? Color(0xFF114195) : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      if (index != tracking.length - 1)
                        Container(width: 2, height: 50, color: Colors.grey.shade300),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step['status'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xFF0E3E94))),
                        const SizedBox(height: 4),
                        Text(step['date'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(step['description'], style: const TextStyle(color: Colors.black87, fontSize: 15)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _detailsCard(Map<String, dynamic> data, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFDDE8F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Delivery Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3E94))),
          const SizedBox(height: 16),
          _infoTile(Icons.numbers, "Tracking Number", data['trackingNumber'] ?? "N/A"),
          const Divider(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF114195)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Address", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(data['address'] ?? "No address", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Color(0xFF114195)),
                onPressed: () => openMapWithAddress(data['address'] ?? ""),
              )
            ],
          ),
          const Divider(height: 32),
          _infoTile(Icons.payment, "Payment Method", data['paymentMethod'] ?? "-"),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF114195)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 15)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
        )
      ],
    );
  }
}
