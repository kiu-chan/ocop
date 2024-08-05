import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';

class CouncilListPage extends StatefulWidget {
  const CouncilListPage({Key? key}) : super(key: key);

  @override
  _CouncilListPageState createState() => _CouncilListPageState();
}

class _CouncilListPageState extends State<CouncilListPage> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();
  List<Map<String, dynamic>> _councils = [];
  List<int> _availableYears = [];
  List<String> _availableDistricts = [];
  int? _selectedYear;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadCouncils();
  }

  Future<void> _loadCouncils() async {
    await _databaseOptions.connect();
    final councils = await _databaseOptions.connection!.query('''
      SELECT cg.id, cg.title, cg.level, cg.created_at, cg.is_archived, md.name as district_name
      FROM _ocop_evaluation_council_groups cg
      LEFT JOIN map_districts md ON cg.district_id = md.id
      WHERE cg.deleted_at IS NULL
      ${_selectedYear != null ? "AND EXTRACT(YEAR FROM cg.created_at) = @year" : ""}
      ${_selectedDistrict != null ? "AND md.name = @district" : ""}
      ORDER BY cg.created_at DESC
    ''', substitutionValues: {
      if (_selectedYear != null) 'year': _selectedYear,
      if (_selectedDistrict != null) 'district': _selectedDistrict,
    });
    
    setState(() {
      _councils = councils.map((row) => {
        'id': row[0],
        'title': row[1],
        'level': row[2],
        'created_at': row[3],
        'is_archived': row[4],
        'district_name': row[5] ?? 'Không xác định',
      }).toList();

      // Lấy danh sách các năm có sẵn
      _availableYears = _councils
          .map((council) => DateTime.parse(council['created_at'].toString()).year)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      // Lấy danh sách các huyện có sẵn
      _availableDistricts = _councils
          .map((council) => council['district_name'] as String)
          .where((district) => district != 'Không xác định')
          .toSet()
          .toList()
        ..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách hội đồng chấm'),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
                      'Bộ lọc',
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
              leading: const Icon(Icons.calendar_today),
              title: const Text('Năm'),
              children: [
                ListTile(
                  title: const Text('Tất cả các năm'),
                  selected: _selectedYear == null,
                  onTap: () {
                    setState(() {
                      _selectedYear = null;
                    });
                    _loadCouncils();
                    Navigator.pop(context);
                  },
                ),
                ..._availableYears.map((year) => ListTile(
                  title: Text(year.toString()),
                  selected: _selectedYear == year,
                  onTap: () {
                    setState(() {
                      _selectedYear = year;
                    });
                    _loadCouncils();
                    Navigator.pop(context);
                  },
                )).toList(),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Huyện'),
              children: [
                ListTile(
                  title: const Text('Tất cả các huyện'),
                  selected: _selectedDistrict == null,
                  onTap: () {
                    setState(() {
                      _selectedDistrict = null;
                    });
                    _loadCouncils();
                    Navigator.pop(context);
                  },
                ),
                ..._availableDistricts.map((district) => ListTile(
                  title: Text(district),
                  selected: _selectedDistrict == district,
                  onTap: () {
                    setState(() {
                      _selectedDistrict = district;
                    });
                    _loadCouncils();
                    Navigator.pop(context);
                  },
                )).toList(),
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _councils.length,
        itemBuilder: (context, index) {
          final council = _councils[index];
          return ListTile(
            title: Text(council['title']),
            subtitle: Text('Cấp: ${council['level']} - Ngày tạo: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(council['created_at'].toString()))}'),
            trailing: Text(council['is_archived'] ? 'Đã lưu trữ' : 'Đang hoạt động'),
            onTap: () {
              // Xử lý khi người dùng nhấn vào một hội đồng
            },
          );
        },
      ),
    );
  }
}