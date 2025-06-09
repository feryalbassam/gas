import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas_on_go/user_pages/user_dashboard.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gas_on_go/user_pages/user_rating.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  LatLng? driverLocation;
  LatLng? destination;
  String? orderStatus;
  bool hasRated = false;
  List<LatLng> _route = [];
  final MapController _mapController = MapController();
  final Distance _distance = Distance();

  Future<void> fetchRoute() async {
    if (driverLocation == null || destination == null) return;
    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/'
        '${driverLocation!.longitude},${driverLocation!.latitude};'
        '${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(geometry);
      setState(() {
        _route = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    }
  }

  Future<void> checkAndCompleteOrder() async {
    if (driverLocation != null &&
        destination != null &&
        orderStatus != "completed") {
      final double meters = _distance(
        driverLocation!,
        destination!,
      );
      if (meters < 50) {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .update({"status": "completed"});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order marked as completed!")),
          );
        }
      }
    }
  }

  Future<void> cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp()
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order has been cancelled.")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 15, 15, 41),
        elevation: 0,
        centerTitle: true,
        title: const Text("📦 Order Tracking",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white),
            onPressed: cancelOrder,
            tooltip: "Cancel Order",
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (data['driverLocation'] != null) {
            driverLocation = LatLng(
              data['driverLocation']['lat'],
              data['driverLocation']['lng'],
            );
          }

          if (data['destination'] != null) {
            destination = LatLng(
              data['destination']['lat'],
              data['destination']['lng'],
            );
          }

          orderStatus = data['status'];
          hasRated = data['rated'] == true;

          if (orderStatus == "cancelled_by_driver") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    "The driver has cancelled your order ",
                    style: TextStyle(
                        color: Color.fromARGB(255, 15, 15, 41),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Back to Home",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 15, 15, 41),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Dashboard()),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (orderStatus == "completed" && !hasRated) {
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => RatingPage(
                    orderId: widget.orderId,
                    driverId: '',
                  ),
                ),
              );
            });
          }

          if (driverLocation != null && destination != null) {
            fetchRoute();
            checkAndCompleteOrder();
          }

          return Column(
            children: [
              if (driverLocation != null && destination != null)
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: driverLocation!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      PolylineLayer(
                        polylines: [
                          if (_route.isNotEmpty)
                            Polyline(
                              points: _route,
                              strokeWidth: 4.0,
                              color: Colors.red,
                            ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: driverLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.local_shipping,
                                color: Color.fromARGB(255, 15, 15, 41),
                                size: 40),
                          ),
                          Marker(
                            point: destination!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Waiting for driver and destination data..."),
                ),
              Container(
                color: const Color.fromARGB(255, 15, 15, 41),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text("Order Status: ${orderStatus ?? "Unknown"}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }
}
