import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ocop/src/widgets/indicator.dart';
import 'package:ocop/src/data/app/appColors.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class PieChartSample1 extends StatefulWidget {
  final ChartData chartData;
  const PieChartSample1({
    super.key,
    required this.chartData,
  });

  @override
  State<StatefulWidget> createState() => PieChartSample1State();
}

class PieChartSample1State extends State<PieChartSample1> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildIndicators(),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIndicators() {
    final List<MapEntry<String, int>> sortedData = widget.chartData.data.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value)); // Sắp xếp tăng dần

    return sortedData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return Column(
        children: [
          Indicator(
            color: _getSectionColor(index),
            text: data.key,
            isSquare: true,
          ),
          const SizedBox(height: 4),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> showingSections() {
    final List<MapEntry<String, int>> sortedData = widget.chartData.data.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value)); // Sắp xếp tăng dần
    
    final int total = sortedData.fold(0, (sum, entry) => sum + entry.value);

    return List.generate(sortedData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      
      final entry = sortedData[i];
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: _getSectionColor(i),
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
    });
  }

  Color _getSectionColor(int index) {
    switch (index) {
      case 0:
        return AppColors.contentColorOrange;
      case 1:
        return AppColors.contentColorGreen;
      case 2:
        return AppColors.contentColorPurple;
      case 3:
        return AppColors.contentColorYellow;
      case 4:
        return AppColors.contentColorBlue;
      default:
        return Colors.grey; // Thêm màu nếu cần
    }
  }
}