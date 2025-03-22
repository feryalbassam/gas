import 'package:flutter/material.dart';

import 'order_tracking_screen.dart';

void main() {
  runApp(GasOrderApp());
}

class GasOrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: OrderPlacementPage(),
    );
  }
}

class OrderPlacementPage extends StatefulWidget {
  @override
  _OrderPlacementPageState createState() => _OrderPlacementPageState();
}

class _OrderPlacementPageState extends State<OrderPlacementPage> {
  int quantity = 1;
  double pricePerCylinder = 10.0;
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double totalPrice = quantity * pricePerCylinder;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents keyboard overlapping
      appBar: AppBar(
        backgroundColor: Color(0xFF114195),
        title: Text("Gas Cylinder Order",
          style: TextStyle(color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 5,

      ),
      body: SingleChildScrollView( // Allows scrolling when keyboard is open
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Quantity:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color:Color(0xFF114195), blurRadius: 5, spreadRadius: 2),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Delivery Location:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: addressController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  hintText: "Enter delivery address",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.location_on, color:  Color(0xFF114195)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 20),
              Text(
                "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (addressController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderTrackingScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a delivery address!",
                        style: TextStyle(color: Colors.black,
                        ),)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF114195), // Fixed color issue
                  elevation: 5,
                ),
                child: Text("Confirm Order", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
