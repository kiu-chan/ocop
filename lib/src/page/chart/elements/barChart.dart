import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class BarChartSample extends StatefulWidget {
  final ChartData chartData;
  
  BarChartSample({
    required this.chartData,
  });

  @override
  _BarChartSampleState createState() => _BarChartSampleState();
}

class _BarChartSampleState extends State<BarChartSample> {
  @override
  Widget build(BuildContext context) {
    final titles = widget.chartData.data.keys.toList();
    final values = widget.chartData.data.values.toList();
    final barGroups = titles.asMap().entries.map((entry) {
      final index = entry.key;
      final title = entry.value;
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
        title: Text(widget.chartData.title),
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
                axisNameWidget: Text('Quantity'), // Y-axis name
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
                        child: Text(titles[index]),
                      );
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(''),
                    );
                  },
                ),
                axisNameWidget: Text('Star'), // X-axis name
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
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