/*import 'package:flutter/material.dart';
import 'package:gas_on_go/theme/sizes.dart';


class TRoundedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final bool showBorder;
  final EdgeInsets padding;

  const TRoundedContainer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.showBorder = false,
    this.padding = const EdgeInsets.all(TSizes.md),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        border: showBorder ? Border.all(color: Colors.blue) : null, // Optional border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}*/
