import 'package:flutter/material.dart';


class BackGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: CustomPaint(
        size: Size(screenWidth, screenHeight * 1), // Kích thước của hình thang
        painter: TrapezoidPainter(),
      ),
    );
  }
}

class TrapezoidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height * 0.25); // Điểm bắt đầu (trái trên)
    path.lineTo(size.width, 0); // Điểm trên phải
    path.lineTo(size.width, size.height * 0.75); // Điểm dưới phải
    path.lineTo(0, size.height); // Điểm dưới trái
    path.close(); // Kết thúc đường vẽ

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
