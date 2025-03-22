import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});
  Widget _buildTimelineItem({
    required String status,
    required String date,
    required String description,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight( // to Widget _buildTimelineItem
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [    //the vertical line above the circle
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 30,
                    color:
                    isCompleted
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withOpacity(0.2),
                  ),
                Container(    // the circle
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppTheme.primaryColor : Colors.white,
                    border: Border.all(
                      width: 2,
                      color:
                      isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),

                  child:
                  isCompleted
                      ? Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                if (isFirst)
                  Container(
                    width: 2,
                    height: 50,
                    color:
                    isCompleted
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withOpacity(0.2),
                  ),
                if (!isFirst)  // another virtical line at the end
                  Container(
                    width: 2,
                    height: 30,
                    color:
                    isCompleted
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withOpacity(0.2),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                      isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  "Track Order",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Estimated Delivery",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "feb 14 2025",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "In Transit",
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      _buildTimelineItem(
                        status: "Order Placed",
                        date: "Feb 10, 2025 -10:30 Am",
                        description:
                        "your order has been confirmed and is being processed",
                        isCompleted: true,
                        isFirst: true,
                      ),
                      _buildTimelineItem(
                        status: "Shipping",
                        date: "Feb 10, 2025 -10:30 Am",
                        description:
                        "your order has been prepared for shipping ",
                        isCompleted: true,
                      ),
                      _buildTimelineItem(
                        status: "In Transit",
                        date: "Feb 10, 2025 - 11 Am",
                        description: "your order is on its way to you",
                        isCompleted: true,
                      ),
                      _buildTimelineItem(
                        status: "Out for Delivery",
                        date: "Expected Feb 10, 2025 ",
                        description: "your order will be delivered today",
                        isCompleted: false,
                      ),

                      _buildTimelineItem(
                        status: " Delivered",
                        date: "Expected Feb 10, 2025 ",
                        description: "your order will has been delivered",
                        isCompleted: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tracking Number",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "TRK123456789",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.copy,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Delivery Address",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "123 Main Street, Apt 48\nNew York,Ny 10001\nUnited States",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.copy,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      bottomSheet: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Back"),
        ),
      ),
    );
  }
}
