import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ocop/src/widgets/indicator.dart';
import 'package:ocop/src/data/app/appColors.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class PieChartSample extends StatefulWidget {
  final ChartData chartData;
  const PieChartSample({
    super.key,
    required this.chartData,
  });

  @override
  State<StatefulWidget> createState() => PieChartSampleState();
}

class PieChartSampleState extends State<PieChartSample> {
  int touchedIndex = -1;
  // Đặt giới hạn độ dài cho văn bản
  static const int maxLength = 20; // Thay đổi giá trị này tùy thuộc vào không gian bạn có

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AspectRatio(
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
                              // if (!event.isInterestedForInteractions ||
                              //     pieTouchResponse == null ||
                              //     pieTouchResponse.touchedSection == null) {
                              //   touchedIndex = -1;
                              //   return;
                              // }
                              // touchedIndex = pieTouchResponse
                              //     .touchedSection!.touchedSectionIndex;
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildIndicators(),
                ),
                const SizedBox(
                  width: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDataTable(),
        ],
      ),
    );
  }

  List<Widget> _buildIndicators() {
  return widget.chartData.data.entries.map((entry) {
    final index = widget.chartData.data.keys.toList().indexOf(entry.key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Indicator(
        color: _getSectionColor(index),
        text: _buildTruncatedText('${entry.key} ${widget.chartData.title}'),
        isSquare: true,
      ),
    );
  }).toList();
}

String _buildTruncatedText(String text) {

  if (text.length > maxLength) {
    return '${text.substring(0, maxLength)}...';
  } else {
    return text;
  }
}


  List<PieChartSectionData> showingSections() {
    final int total = widget.chartData.data.values.fold(0, (sum, value) => sum + value);

    return List.generate(widget.chartData.data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final entry = widget.chartData.data.entries.elementAt(i);
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

  Widget _buildDataTable() {
    final int total = widget.chartData.data.values.fold(0, (sum, value) => sum + value);

    return DataTable(
      columns: const [
        DataColumn(label: Text('Đầu mục')),
        DataColumn(label: Text('Số lượng')),
        DataColumn(label: Text('Tỉ lệ %')),
      ],
      rows: widget.chartData.data.entries.map((entry) {
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        return DataRow(cells: [
          DataCell(Text(_buildTruncatedText('${entry.key} ${widget.chartData.title}'))),
          DataCell(Text(entry.value.toString())),
          DataCell(Text('$percentage%')),
        ]);
      }).toList(),
    );
  }
}
