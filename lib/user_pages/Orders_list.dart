import 'package:flutter/material.dart';
import 'package:gas_on_go/widgets/TRoundedConatainer.dart';
import 'package:gas_on_go/theme/app_theme.dart';
import 'package:gas_on_go/theme/sizes.dart';

class ToOrderListItems extends StatelessWidget {
  const ToOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TRoundedContainer(
        showBorder: true,
        padding: const EdgeInsets.all(TSizes.md),
        backgroundColor: Color.fromARGB(255, 15, 15, 41),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping,
                          color: Colors.white, size: 24),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(
                            '07 Nov 2024',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Row 2
              Row(
                children: [
                  const Icon(Icons.tag, color: Colors.white, size: 24),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                      ),
                      Text(
                        '#256f2f',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
