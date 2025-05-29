// 🔥 Polished OrderTrackingScreen – Deeper Blue + Bolder Text

/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas_on_go/user_pages/Dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  void openMapWithAddress(String address) async {
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      // More blue-ish background
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Dashboard())); // Go back to the previous screen
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
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
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
          colors: [Color(0xFF0F0F29), Color(0xFFC2E1FD)],
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
              "${estimatedDate.month}/${estimatedDate.day}/${estimatedDate.year}",
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status ?? "In Transit",
                style: const TextStyle(
                    color: Color.fromARGB(255, 15, 15, 41),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(List<Map<String, dynamic>> tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 15, 15, 41),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Color(0xFFC2E1FD), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Progress",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
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
                        Container(
                            width: 2, height: 20, color: Color(0xFFC2E1FD)),
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Color(0xFFC2E1FD) : Colors.white,
                          border: Border.all(
                            color: isCompleted ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                      if (index != tracking.length - 1)
                        Container(width: 2, height: 50, color: Colors.white),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step['status'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Color(0xFF72C5FB))),
                        const SizedBox(height: 4),
                        Text(step['date'],
                            style: const TextStyle(
                                color: Color(0xFFC2E1FD), fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(step['description'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15)),
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
        color: Color.fromARGB(255, 15, 15, 41),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0xFFC2E1FD), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Delivery Details",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          _infoTile(Icons.numbers, "Tracking Number",
              data['trackingNumber'] ?? "N/A"),
          const Divider(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Address",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(data['address'] ?? "No address",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                onPressed: () => openMapWithAddress(data['address'] ?? ""),
              )
            ],
          ),
          const Divider(height: 32),
          _infoTile(
              Icons.payment, "Payment Method", data['paymentMethod'] ?? "-"),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
            ],
          ),
        )
      ],
    );
  }
}*/
// OrderTrackingScreen with OpenStreetMap, live tracking, polyline, auto-complete and one-time rating

/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas_on_go/user_pages/Dashboard.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void showRatingDialog() {
    final TextEditingController feedbackController = TextEditingController();

    int selectedRating = 0; // ✅ Declare outside builder so it persists

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Rate Your Delivery"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: feedbackController,
                    decoration:
                        const InputDecoration(hintText: 'Optional feedback'),
                  )
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Submit"),
                  onPressed: () async {
                    if (selectedRating > 0) {
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(widget.orderId)
                          .update({
                        "rating": selectedRating,
                        "feedback": feedbackController.text.trim(),
                        "rated": true,
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Thank you for your feedback!"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please select a rating before submitting."),
                        ),
                      );
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
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

          if (orderStatus == "completed" && !hasRated) {
            Future.delayed(Duration.zero, () => showRatingDialog());
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
                                color: Colors.green, size: 40),
                          ),
                          Marker(
                            point: destination!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.flag,
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
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas_on_go/user_pages/Dashboard.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gas_on_go/user_pages/rating.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
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
                                color: Colors.green, size: 40),
                          ),
                          Marker(
                            point: destination!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.flag,
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
