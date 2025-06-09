import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _currentStock = 0;
  Timestamp? _lastUpdated;
  final TextEditingController _stockController = TextEditingController();
  final Color accentColor = const Color(0xFF002B49);
  late String _sellerId;

  @override
  void initState() {
    super.initState();
    _sellerId = FirebaseAuth.instance.currentUser!.uid;
    _fetchCurrentStock();
    _stockController.addListener(() => setState(() {})); // for button state
  }

  Future<void> _fetchCurrentStock() async {
    final doc = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(_sellerId)
        .get();

    if (doc.exists && doc.data() != null && doc.data()!.containsKey('stock')) {
      setState(() {
        _currentStock = doc['stock'];
        _lastUpdated = doc['updatedAt'];
      });

      if (_currentStock <= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Low stock! Consider adding more cylinders."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      setState(() {
        _currentStock = 0;
      });
      debugPrint("⚠️ Seller document not found or missing 'stock' field.");
    }
  }

  Future<void> _updateStock(bool isAdd) async {
    final qty = int.tryParse(_stockController.text.trim());
    if (qty == null || qty <= 0) return;

    int newStock = isAdd ? _currentStock + qty : _currentStock - qty;
    if (newStock < 0) newStock = 0;

    await FirebaseFirestore.instance.collection('sellers').doc(_sellerId).set({
      'stock': newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); //

    _stockController.clear();
    _fetchCurrentStock();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" Stock updated to: $newStock")),
    );
  }

  Widget _buildStockBadge(int stock) {
    Color color;
    String label;

    if (stock <= 5) {
      color = Colors.red;
      label = "Low Stock";
    } else if (stock <= 15) {
      color = Colors.orange;
      label = "Medium Stock";
    } else {
      color = Colors.green;
      label = "Healthy Stock";
    }

    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = _lastUpdated != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(_lastUpdated!.toDate())
        : "N/A";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 15, 15, 41),
        title: const Text("Manage Inventory",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.inventory_2_outlined, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Inventory Overview",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF002B49),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Current Stock:",
                      style: TextStyle(
                          color: Color(0xFF002B49),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    _buildStockBadge(_currentStock),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    "$_currentStock Cylinder(s)",
                    key: ValueKey(_currentStock),
                    style: const TextStyle(
                        color: Color(0xFF002B49),
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text("Last updated: $formattedDate",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                const Divider(),
                const Text("Modify Stock",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF002B49))),
                const SizedBox(height: 10),
                TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter quantity",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                        onPressed: _stockController.text.isEmpty
                            ? null
                            : () => _updateStock(true),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.remove),
                        label: const Text("Remove"),
                        onPressed: _stockController.text.isEmpty
                            ? null
                            : () => _updateStock(false),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
