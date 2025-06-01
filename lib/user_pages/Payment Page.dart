import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;

  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'cash';
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;

  String? cardNumberError;
  String? expiryError;
  String? cvvError;

  @override
  void initState() {
    super.initState();

    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();

    _expiryController.addListener(() {
      final text = _expiryController.text.replaceAll('/', '');
      if (text.length == 2 && !_expiryController.text.contains('/')) {
        _expiryController.value = TextEditingValue(
          text: '${text.substring(0, 2)}/${text.substring(2)}',
          selection: TextSelection.collapsed(offset: 3),
        );
      }
    });

    _cardNumberController.addListener(() {
      final digits = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
      final formatted = digits
          .replaceAllMapped(RegExp(r'.{1,4}'), (match) => '${match.group(0)} ')
          .trimRight();

      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });

    _cvvController.addListener(() {
      final digits = _cvvController.text.replaceAll(RegExp(r'\D'), '');
      final limited = digits.length > 3 ? digits.substring(0, 3) : digits;

      _cvvController.value = TextEditingValue(
        text: limited,
        selection: TextSelection.collapsed(offset: limited.length),
      );
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_selectedMethod == 'card') {
      setState(() {
        cardNumberError = null;
        expiryError = null;
        cvvError = null;
      });

      final cardNumber = _cardNumberController.text.replaceAll(' ', '').trim();
      final expiry = _expiryController.text.trim();
      final cvv = _cvvController.text.trim();

      bool hasError = false;

      if (cardNumber.length != 16 || int.tryParse(cardNumber) == null) {
        setState(() {
          cardNumberError = "Card number must be 16 digits";
        });
        hasError = true;
      }

      final expiryRegExp = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$');
      if (!expiryRegExp.hasMatch(expiry)) {
        setState(() {
          expiryError = "Expiry must be in MM/YY format";
        });
        hasError = true;
      }

      if (cvv.length != 3 || int.tryParse(cvv) == null) {
        setState(() {
          cvvError = "CVV must be 3 digits";
        });
        hasError = true;
      }

      if (hasError) return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'paymentMethod': _selectedMethod,
        'paymentTimestamp': FieldValue.serverTimestamp(),
        if (_selectedMethod == 'card')
          'cardInfo': {
            'number': _cardNumberController.text,
            'expiry': _expiryController.text,
            'cvv': _cvvController.text,
          },
      });

      Navigator.pop(context, {'method': _selectedMethod});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save payment method: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Payment Preference"),
        backgroundColor: const Color(0xFF0F0F29),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your preferred payment method",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPaymentCard(
              value: 'cash',
              icon: Icons.money_outlined,
              title: 'Cash on Delivery',
              subtitle: 'Pay in cash when the order arrives.',
            ),
            const SizedBox(height: 16),
            _buildPaymentCard(
              value: 'card',
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              subtitle: 'Pay using your credit or debit card.',
            ),
            const SizedBox(height: 20),
            if (_selectedMethod == 'card') ...[
              const Text(
                "Card Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Card Number",
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: cardNumberError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: "Expiry Date (MM/YY)",
                        prefixIcon: const Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: expiryError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "CVV",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: cvvError,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0F29),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text(
                  "Continue",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;

          if (value == 'cash') {
            _cardNumberController.clear();
            _expiryController.clear();
            _cvvController.clear();
            cardNumberError = null;
            expiryError = null;
            cvvError = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF0F0F29).withOpacity(0.08)
              : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF0F0F29) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF0F0F29)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFF0F0F29),
            ),
          ],
        ),
      ),
    );
  }
}
