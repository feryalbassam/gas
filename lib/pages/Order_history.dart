import 'package:flutter/material.dart';
import 'package:gas_on_go/widgets/Orders_list.dart';
import 'package:gas_on_go/theme/sizes.dart';
import 'package:gas_on_go/theme/app_theme.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: Colors.white, // White text
            fontSize: 24, // Bigger title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor, // Blue app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppTheme.primaryColor, // Blue background
        child: ListView.separated(
          padding: const EdgeInsets.all(TSizes.defaultSpace * 1.5), // Bigger padding
          shrinkWrap: true,
          itemCount: 10, // Example item count
          separatorBuilder: (context, index) => SizedBox(height: TSizes.spaceBtwItems * 1.5), // More spacing
          itemBuilder: (context, index) {
            return const ToOrderListItems();
          },
        ),
      ),
    );
  }
}
