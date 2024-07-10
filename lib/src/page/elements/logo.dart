import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "O",
          style: TextStyle(
            color: Color.fromRGBO(153, 87, 47, 1),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "C",
          style: TextStyle(
            color: Color.fromRGBO(17, 127, 67, 1),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "O",
          style: TextStyle(
            color: Color.fromRGBO(237, 51, 55, 1),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "P",
          style: TextStyle(
            color: Color.fromRGBO(249, 87, 47, 1),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Bến Tre",
          style: TextStyle(
            fontFamily: 'DancingScript',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}