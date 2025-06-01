/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../user_pages/orders_detail_page.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final Color accentColor = Color.fromARGB(255, 15, 15, 41);
  late String sellerId;

  @override
  void initState() {
    super.initState();
    sellerId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _updateStatus(
      BuildContext context, String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order marked as $newStatus")),
    );
  }

  Widget _buildSwipeBackground(
      IconData icon, String label, Color color, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        automaticallyImplyLeading: false,
        title: const Text("Seller Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final int quantity = data['quantity'] ?? 0;
              final String status = data['status'] ?? 'pending';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final DateTime date = timestamp.toDate();

              Color statusColor;
              switch (status) {
                case 'delivered':
                  statusColor = Colors.green;
                  break;
                case 'on_the_way':
                  statusColor = Colors.orange;
                  break;
                case 'accepted':
                  statusColor = accentColor;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Dismissible(
                key: Key(order.id),
                background: _buildSwipeBackground(
                    Icons.check, "Accept", accentColor, Alignment.centerLeft),
                secondaryBackground: _buildSwipeBackground(
                    Icons.done, "Deliver", Colors.green, Alignment.centerRight),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _updateStatus(context, order.id, 'accepted');
                  } else {
                    await _updateStatus(context, order.id, 'delivered');
                  }
                  return false;
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(
                            orderId: order.id,
                            orderData: data,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child:
                          Icon(Icons.inventory_2_rounded, color: statusColor),
                    ),
                    title: Text(
                      "Order: $quantity Cylinder(s)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                            "Status: ${status.replaceAll('_', ' ').toUpperCase()}"),
                        Text(
                            "Date: ${DateFormat('dd MMM yyyy – hh:mm a').format(date)}",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas_on_go/driver_pages/driverdashboard.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../pages/openstreetmap.dart';
import '../user_pages/orders_detail_page.dart';
import 'driver_map_screen.dart';

class SellerDashboardPage extends StatefulWidget {
  final String driverId;

  const SellerDashboardPage({super.key, required this.driverId});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final Color accentColor = const Color.fromARGB(255, 15, 15, 41);
  StreamSubscription<Position>? positionStream;

  Future<void> _acceptOrder(
      BuildContext context, String orderId, String userId) async {
    try {
      if (orderId.isEmpty || widget.driverId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Missing order or driver ID")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission is required.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'accepted',
        'driverId': widget.driverId,
        'driverLocation': {
          'lat': position.latitude,
          'lng': position.longitude,
        }
      });

      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .add({
        'title': 'Driver accepted your order 🚚',
        'body': 'Your gas cylinder is on the way!',
        'orderId': orderId,
        'timestamp': Timestamp.now(),
        'read': false,
      });

      _startDriverLocationUpdates(orderId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order accepted successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Driverdashboard(), // or pass driverId if needed
        ),
      );
    } catch (e) {
      print("Error accepting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to accept the order.")),
      );
    }
  }

  void _startDriverLocationUpdates(String orderId) {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'driverLocation': {
          'lat': position.latitude,
          'lng': position.longitude,
        }
      });
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        automaticallyImplyLeading: false,
        title: const Text("Seller Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No pending orders."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final int quantity = data['quantity'] ?? 0;
              final String address = data['address'] ?? 'No address';
              final String userId = data['userId'] ?? '';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final DateTime date = timestamp.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  onTap: () {
                    if (order.id.isNotEmpty && widget.driverId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DriverDeliveryScreen(
                            orderId: order.id,
                            driverId: widget.driverId,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Error: Missing order or driver ID")),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: accentColor.withOpacity(0.1),
                    child: Icon(Icons.local_shipping, color: accentColor),
                  ),
                  title: Text("$quantity Cylinder(s) to $address",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy – hh:mm a').format(date),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _acceptOrder(context, order.id, userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text("Accept",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
