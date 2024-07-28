import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class BarChartSample extends StatefulWidget {
  final ChartData chartData;
  
  const BarChartSample({super.key, 
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
    final titles = widget.chartData.data.keys.toList();
    final values = widget.chartData.data.values.toList();
    
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
            maxY: values.reduce((a, b) => a > b ? a : b).toDouble() * 1.1,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text('${value.toInt()}'),
                    );
                  },
                ),
                axisNameWidget: Text(widget.chartData.y_title), // Y-axis name
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
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: const Text(''),
                    );
                  },
                ),
                axisNameWidget: Text(widget.chartData.x_title), // X-axis name
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: const Color(0xff37434d),
                width: 1,
              ),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}