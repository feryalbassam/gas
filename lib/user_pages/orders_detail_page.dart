import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({Key? key, required this.orderId, required this.orderData})
      : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String _status = "";

  @override
  void initState() {
    super.initState();
    _status = widget.orderData['status'];
  }

  Future<void> _updateStatus(String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'status': newStatus,
    });

    setState(() => _status = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order status updated")));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.orderData;
    final accentColor = const Color(0xFF002B49);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text("Order Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 Address", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                Text(data['address'] ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),

                Text("📦 Quantity", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                Text("${data['quantity'] ?? 0} Cylinder(s)", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),

                Text("💰 Payment", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                Text(data['paymentMethod'] ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),

                Text("📅 Date", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                Text(
                  (data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),

                Text("🚚 Status", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(_status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: accentColor,
                ),

                const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        label: Text("Accept",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                        onPressed: () => _updateStatus("accepted"),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.delivery_dining, color: Colors.white),
                        label: Text("On The Way",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => _updateStatus("on_the_way"),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.done, color: Colors.white),
                        label: Text("Delivered",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _updateStatus("delivered"),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}