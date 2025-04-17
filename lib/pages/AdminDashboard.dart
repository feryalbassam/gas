import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gas_on_go/theme/app_theme.dart';
import 'package:gas_on_go/pages/Admin_orders_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
        ),
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings, color: Colors.white),
            SizedBox(width: 10),
            Text('Admin ', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Row(
        children: [
          if (_isMenuOpen)
            Container(
              width: 200,
              color: Colors.black12,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ListTile(
                    leading: Icon(Icons.dashboard, color: Colors.white),
                    title: Text('Dashboard', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.white),
                    title: Text('User Management', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.approval, color: Colors.white),
                    title: Text('Seller Approval', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_cart, color: Colors.white),
                    title: Text('Orders', style: TextStyle(color: Colors.white)),
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Admin_OrdersPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.report, color: Colors.white),
                    title: Text('Report', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.white),
                    title: Text('Notification', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.white),
                    title: Text('Settings', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8DBFD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Orders",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: 50,
                                    title: 'Processing',
                                    radius: 60,
                                    titleStyle: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: 30,
                                    title: 'Done',
                                    radius: 60,
                                    titleStyle: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: 20,
                                    title: 'Cancelled',
                                    radius: 60,
                                    titleStyle: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.black),
                          const SizedBox(height: 6),
                          // Legend
                          const LegendItem(color: Colors.green, label: 'Processing'),
                          const LegendItem(color: Colors.orange, label: 'Done'),
                          const LegendItem(color: Colors.red, label: 'Cancelled'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFFE8DBFD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Total Orders\n22.2',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFFE8DBFD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Total Revenue\n\$12,478',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Top 10 Sellers',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: const [
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 1', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$2,300', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 2', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$1,900', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 3', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$1,500', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 4', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$1,200', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 5', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$1,100', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 6', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$900', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 7', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$850', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 8', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$750', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 9', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$600', style: TextStyle(color: Colors.white70)),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Seller 10', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Sales: \$500', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.black)), // Label in black
      ],
    );
  }
}
