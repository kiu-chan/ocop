import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class BarChartSample extends StatefulWidget {
  final ChartData chartData;
  const BarChartSample({
    super.key,
    required this.chartData,
  });

  @override
  _BarChartSampleState createState() => _BarChartSampleState();
}

class _BarChartSampleState extends State<BarChartSample> {
  String _truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final sortedData = widget.chartData.data.entries.toList()
      ..sort((a, b) {
        final aNum = num.tryParse(a.key);
        final bNum = num.tryParse(b.key);
        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }
        return a.key.compareTo(b.key);
      });

    final titles = sortedData.map((e) => e.key).toList();
    final values = sortedData.map((e) => e.value).toList();

    final maxY = values.reduce((a, b) => a > b ? a : b).toDouble();
    final adjustedMaxY = maxY * 1.1; // Increase maxY by 10%
    final yInterval = (adjustedMaxY / 5).ceilToDouble();
    final roundedMaxY = (yInterval * 5).ceilToDouble();

    final barGroups = titles.asMap().entries.map((entry) {
      final index = entry.key;
      final value = values[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: Colors.blue,
            width: 22,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chartData.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: roundedMaxY,
            minY: 0,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${titles[groupIndex]}: ${rod.toY.round()}',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(value.toInt().toString()),
                    );
                  },
                ),
                axisNameWidget: Text(widget.chartData.y_title),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < titles.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          _truncateString(titles[index], 10),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                axisNameWidget: Text(widget.chartData.x_title),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey[300],
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(color: Colors.grey),
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}
