import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_tracking_screen.dart';
import 'Payment Page.dart';

class OrderPlacementPage extends StatefulWidget {
  const OrderPlacementPage({Key? key}) : super(key: key);

  @override
  State<OrderPlacementPage> createState() => _OrderPlacementPageState();
}

class _OrderPlacementPageState extends State<OrderPlacementPage> {
  int quantity = 1;
  double pricePerCylinder = 10.0;
  TextEditingController addressController = TextEditingController();
  String selectedPaymentMethod = 'cash';

  // ✅ Function to send a notification to Firestore
  Future<void> sendNotificationToUser(String userId, String orderId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .add({
      'title': 'Order #$orderId is confirmed and being prepared 🚚',
      'body': 'Tap to track your order.',
      'orderId': orderId,
      'timestamp': Timestamp.now(),
      'read': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = quantity * pricePerCylinder;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114195),
        title: const Text("Gas Cylinder Order", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Quantity:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: const Color(0xFF114195), blurRadius: 5, spreadRadius: 2)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text(quantity.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text("Delivery Address:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: "Enter delivery address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF114195)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const Text("Payment Method:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentPage()),
                );
                if (result != null) {
                  setState(() {
                    selectedPaymentMethod = result.toString();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114195),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("Choose Payment Method",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            Text("Selected: $selectedPaymentMethod", style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 20),
            Text("Total Price: \$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (addressController.text.isNotEmpty) {
                  final trackingNumber = "TRK${DateTime.now().millisecondsSinceEpoch}";
                  final user = FirebaseAuth.instance.currentUser;
                  final userId = user?.uid;

                  final orderData = {
                    'userId': userId,
                    'quantity': quantity,
                    'address': addressController.text,
                    'totalPrice': totalPrice,
                    'status': 'Order Placed',
                    'paymentMethod': selectedPaymentMethod,
                    'trackingNumber': trackingNumber,
                    'timestamp': FieldValue.serverTimestamp(),
                    'tracking': [
                      {
                        'status': 'Order Placed',
                        'date': DateTime.now().toString(),
                        'description': 'Your order has been confirmed and is being processed.',
                        'isCompleted': true,
                      },
                      {
                        'status': 'Shipping',
                        'date': '',
                        'description': 'Your order is being prepared for shipping.',
                        'isCompleted': false,
                      },
                      {
                        'status': 'In Transit',
                        'date': '',
                        'description': 'Your order is on the way.',
                        'isCompleted': false,
                      },
                      {
                        'status': 'Out for Delivery',
                        'date': '',
                        'description': 'Your order will be delivered today.',
                        'isCompleted': false,
                      },
                      {
                        'status': 'Delivered',
                        'date': '',
                        'description': 'Your order has been delivered.',
                        'isCompleted': false,
                      },
                    ],
                  };

                  final docRef = await FirebaseFirestore.instance.collection('orders').add(orderData);

                  if (userId != null) {
                    await sendNotificationToUser(userId, docRef.id);
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderTrackingScreen(orderId: docRef.id)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a delivery address!", style: TextStyle(color: Colors.black))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF114195),
                elevation: 5,
              ),
              child: const Text("Confirm Order", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
