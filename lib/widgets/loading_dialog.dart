import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  String messageText;

  LoadingDialog({
    super.key,
    required this.messageText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color.fromARGB(255, 15, 15, 41),
      child: Container(
        margin: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 15, 15, 41),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 188, 186, 186)),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                messageText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 188, 186, 186),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
