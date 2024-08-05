// chart_menu.dart
import 'package:flutter/material.dart';

class ChartMenu extends StatefulWidget {
  final bool isAdmin;
  final int? selectedChart;
  final int? checkSelected;
  final int? selectedLoadData;
  final int? selectedCompanyData;
  final int? selectedOcopData;
  final Function(int?) onChartTypeChanged;
  final Function(int?) onCheckSelectedChanged;
  final Function(int?) onLoadDataChanged;
  final Function(int?) onCompanyDataChanged;
  final Function(int?) onOcopDataChanged;

  const ChartMenu({
    Key? key,
    required this.isAdmin,
    required this.selectedChart,
    required this.checkSelected,
    required this.selectedLoadData,
    required this.selectedCompanyData,
    required this.selectedOcopData,
    required this.onChartTypeChanged,
    required this.onCheckSelectedChanged,
    required this.onLoadDataChanged,
    required this.onCompanyDataChanged,
    required this.onOcopDataChanged,
  }) : super(key: key);

  @override
  _ChartMenuState createState() => _ChartMenuState();
}

class _ChartMenuState extends State<ChartMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 80,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Tùy chỉnh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ExpansionTile(
            leading: const Icon(Icons.auto_graph),
            title: const Text("Biểu đồ"),
            subtitle: const Text("Lựa chọn dạng biểu đồ"),
            children: <Widget>[
              RadioListTile<int>(
                title: const Text('Biểu đồ hình tròn'),
                value: 1,
                groupValue: widget.selectedChart,
                onChanged: widget.onChartTypeChanged,
              ),
              RadioListTile<int>(
                title: const Text('Biểu đồ cột'),
                value: 2,
                groupValue: widget.selectedChart,
                onChanged: widget.onChartTypeChanged,
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.wysiwyg),
            title: const Text("Đối tượng thống kê"),
            subtitle: const Text("Lựa chọn đối tượng thống kê"),
            children: <Widget>[
              RadioListTile<int>(
                title: const Text('Sản phẩm'),
                value: 1,
                groupValue: widget.checkSelected,
                onChanged: widget.onCheckSelectedChanged,
              ),
              RadioListTile<int>(
                title: const Text('Công ty'),
                value: 2,
                groupValue: widget.checkSelected,
                onChanged: widget.onCheckSelectedChanged,
              ),
              if (widget.isAdmin)
                RadioListTile<int>(
                  title: const Text('Hồ sơ OCOP'),
                  value: 3,
                  groupValue: widget.checkSelected,
                  onChanged: widget.onCheckSelectedChanged,
                ),
            ],
          ),
          if (widget.checkSelected == 1)
            ExpansionTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text("Thống kê sản phẩm"),
              subtitle: const Text("Lựa chọn đối tượng thống kê"),
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Theo số sao'),
                  value: 1,
                  groupValue: widget.selectedLoadData,
                  onChanged: widget.onLoadDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo loại sản phẩm'),
                  value: 2,
                  groupValue: widget.selectedLoadData,
                  onChanged: widget.onLoadDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo xã'),
                  value: 3,
                  groupValue: widget.selectedLoadData,
                  onChanged: widget.onLoadDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo huyện'),
                  value: 4,
                  groupValue: widget.selectedLoadData,
                  onChanged: widget.onLoadDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo năm'),
                  value: 5,
                  groupValue: widget.selectedLoadData,
                  onChanged: widget.onLoadDataChanged,
                ),
              ],
            ),
          if (widget.checkSelected == 2)
            ExpansionTile(
              leading: const Icon(Icons.business),
              title: const Text("Thống kê công ty"),
              subtitle: const Text("Lựa chọn đối tượng thống kê"),
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Theo loại hình công ty'),
                  value: 1,
                  groupValue: widget.selectedCompanyData,
                  onChanged: widget.onCompanyDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo huyện'),
                  value: 2,
                  groupValue: widget.selectedCompanyData,
                  onChanged: widget.onCompanyDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo trạng thái hoạt động'),
                  value: 3,
                  groupValue: widget.selectedCompanyData,
                  onChanged: widget.onCompanyDataChanged,
                ),
              ],
            ),
          if (widget.checkSelected == 3 && widget.isAdmin)
            ExpansionTile(
              leading: const Icon(Icons.folder_open),
              title: const Text("Thống kê hồ sơ OCOP"),
              subtitle: const Text("Lựa chọn đối tượng thống kê"),
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Tổng số lượng hồ sơ'),
                  value: 1,
                  groupValue: widget.selectedOcopData,
                  onChanged: widget.onOcopDataChanged,
                ),
                RadioListTile<int>(
                  title: const Text('Theo trạng thái'),
                  value: 2,
                  groupValue: widget.selectedOcopData,
                  onChanged: widget.onOcopDataChanged,
                ),
              ],
            ),
        ],
      ),
    );
  }
}