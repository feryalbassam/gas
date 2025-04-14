import 'package:flutter/material.dart';
import 'package:gas_on_go/theme/app_theme.dart';

class Admin_OrdersPage extends StatefulWidget {
  const Admin_OrdersPage({super.key});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<Admin_OrdersPage> {
  List<Map<String, String>> orders = List.generate(8, (index) {
    return {
      'orderId': (1000 + index).toString(),
      'customerName': 'Customer ${index + 1}',
      'status': index % 3 == 0
          ? 'In Progress'
          : index % 2 == 0
          ? 'Delivered'
          : 'Cancelled',
      'dateTime': '2025-04-14 14:${30 + index}',
      'deliveryAgent': 'Agent ${index + 1}',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 10),
            Text('Orders', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  return Card(
                    color: const Color(0xFFE8DBFD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      leading: const Icon(Icons.receipt_long, color: Colors.deepPurple, size: 30),
                      title: Text(
                        'Order #${order['orderId']}',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            'Customer: ${order['customerName']}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date & Time: ${order['dateTime']}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Delivery Agent: ${order['deliveryAgent']}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 5),
                          _buildStatusBadge(order['status']!),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _showEditDialog(context, index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'In Progress':
        statusColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case 'Delivered':
        statusColor = Colors.green;
        statusText = 'Delivered';
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index) {

    TextEditingController customerController = TextEditingController(text: orders[index]['customerName']);
    TextEditingController dateTimeController = TextEditingController(text: orders[index]['dateTime']);
    TextEditingController deliveryAgentController = TextEditingController(text: orders[index]['deliveryAgent']);
    TextEditingController statusController = TextEditingController(text: orders[index]['status']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order #${orders[index]['orderId']}'),
              const SizedBox(height: 10),
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateTimeController,
                decoration: const InputDecoration(labelText: 'Date & Time'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deliveryAgentController,
                decoration: const InputDecoration(labelText: 'Delivery Agent'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: statusController.text,
                onChanged: (newStatus) {
                  setState(() {
                    statusController.text = newStatus!;
                  });
                },
                items: ['In Progress', 'Delivered', 'Cancelled']
                    .map<DropdownMenuItem<String>>((status) {
                  return DropdownMenuItem<String>(value: status, child: Text(status));
                }).toList(),
                decoration: const InputDecoration(labelText: 'Update Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {

                  orders[index] = {
                    'orderId': orders[index]['orderId']!,
                    'customerName': customerController.text,
                    'status': statusController.text,
                    'dateTime': dateTimeController.text,
                    'deliveryAgent': deliveryAgentController.text,
                  };
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order #${orders[index]['orderId']} updated!')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }
}
