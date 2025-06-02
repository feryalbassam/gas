/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Earningpage extends StatefulWidget {
  const Earningpage({super.key});

  @override
  State<Earningpage> createState() => _EarningpageState();
}

class _EarningpageState extends State<Earningpage> {
  double totalEarnings = 0;
  final Color accentColor = Color.fromARGB(255, 15, 15, 41);
  late String sellerId;

  @override
  void initState() {
    super.initState();
    sellerId = FirebaseAuth.instance.currentUser!.uid;
    print("🔥 Seller UID: $sellerId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        automaticallyImplyLeading: false,
        title: const Text("Earnings",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .where('status', isEqualTo: 'delivered')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          totalEarnings = 0;

          final transactions = orders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final quantity = data['quantity'] ?? 0;
            final pricePerCylinder = data['pricePerCylinder'] ?? 7.0;
            final payment = data['paymentMethod'] ?? "Unknown";
            final date = (data['timestamp'] as Timestamp).toDate();

            final total = quantity * pricePerCylinder;
            totalEarnings += total;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.green),
                title: Text(
                  "Order: $quantity Cylinder(s)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Payment: $payment\nDate: ${DateFormat('dd MMM yyyy').format(date)}",
                  style: const TextStyle(height: 1.4),
                ),
                trailing: Text(
                  "JD ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: accentColor.withAlpha(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Earnings",
                        style: TextStyle(
                          fontSize: 18,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 8),
                    Text("JD ${totalEarnings.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 30,
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Expanded(child: ListView(children: transactions)),
            ],
          );
        },
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Earningpage extends StatefulWidget {
  const Earningpage({super.key});

  @override
  State<Earningpage> createState() => _EarningpageState();
}

class _EarningpageState extends State<Earningpage> {
  final Color accentColor = const Color.fromARGB(255, 15, 15, 41);
  late String driverId;
  String selectedFilter = 'Today';
  final List<String> filterOptions = ['Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    driverId = FirebaseAuth.instance.currentUser!.uid;
  }

  bool isWithinSelectedFilter(DateTime date) {
    final now = DateTime.now();
    if (selectedFilter == 'Today') {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } else if (selectedFilter == 'This Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
    } else if (selectedFilter == 'This Month') {
      return date.year == now.year && date.month == now.month;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: accentColor,
        automaticallyImplyLeading: false,
        title: const Text("Earnings",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: accentColor,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
                items:
                    filterOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('driverId', isEqualTo: driverId)
            .where('status', isEqualTo: 'completed')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          double totalEarnings = 0;
          List<Widget> transactions = [];

          for (var doc in orders) {
            final data = doc.data() as Map<String, dynamic>;
            final double total = data['totalPrice']?.toDouble() ?? 0.0;
            final int quantity = data['quantity'] ?? 0;
            final String payment = data['paymentMethod'] ?? "Unknown";
            final Timestamp timestamp = data['timestamp'];
            final DateTime date = timestamp.toDate();

            if (isWithinSelectedFilter(date)) {
              totalEarnings += total;

              transactions.add(Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.monetization_on,
                      color: Color.fromARGB(255, 15, 15, 41)),
                  title: Text("Order: $quantity Cylinder(s)",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Payment: $payment\nDate: ${DateFormat('dd MMM yyyy').format(date)}",
                    style: const TextStyle(height: 1.4),
                  ),
                  trailing: Text("JD ${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ));
            }
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4)),
                  ],
                  border: Border.all(color: accentColor.withAlpha(25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$selectedFilter Earnings",
                        style: TextStyle(
                            fontSize: 18,
                            color: accentColor,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text("JD ${totalEarnings.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 30,
                            color: accentColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(child: ListView(children: transactions)),
            ],
          );
        },
      ),
    );
  }
}
