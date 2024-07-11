import 'package:flutter/material.dart';

class Star extends StatelessWidget {
  final int value;
  const Star({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < value) {
          // Hiển thị sao đầy đủ cho các sao trong phạm vi value
          return Icon(Icons.star, color: Colors.amber);
        } else {
          // Hiển thị sao viền cho các sao còn lại
          return Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }
}