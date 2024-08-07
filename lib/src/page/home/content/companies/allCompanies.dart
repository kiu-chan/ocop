import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/page/home/content/companies/companyDetails.dart';

class AllCompanies extends StatefulWidget {
  const AllCompanies({super.key});

  @override
  _AllCompaniesState createState() => _AllCompaniesState();
}

class _AllCompaniesState extends State<AllCompanies> {
  List<Company> allCompanies = [];
  List<Company> filteredCompanies = [];
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  bool isLoading = true;
  Set<String> selectedTypes = {};
  Set<String> selectedDistricts = {};
  Set<String> selectedCommunes = {};
  List<String> allTypes = [];
  Map<String, List<String>> districtCommunes = {};
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllCompanies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCompanies() async {
    await db.connect();
    final companyData = await db.getAllCompanies();
    setState(() {
      allCompanies = companyData;
      filteredCompanies = companyData;
      allTypes = companyData.map((c) => c.typeName ?? 'Không xác định').toSet().toList();
      
      // Tạo map của huyện và xã
      for (var company in companyData) {
        final district = company.districtName ?? 'Không xác định';
        final commune = company.communeName ?? 'Không xác định';
        if (!districtCommunes.containsKey(district)) {
          districtCommunes[district] = [];
        }
        if (!districtCommunes[district]!.contains(commune)) {
          districtCommunes[district]!.add(commune);
        }
      }
      
      isLoading = false;
    });
    await db.close();
  }

  void _filterCompanies() {
    setState(() {
      filteredCompanies = allCompanies.where((company) {
        final nameMatch = company.name.toLowerCase().contains(searchController.text.toLowerCase());
        final typeMatch = selectedTypes.isEmpty || selectedTypes.contains(company.typeName ?? 'Không xác định');
        final districtMatch = selectedDistricts.isEmpty || selectedDistricts.contains(company.districtName ?? 'Không xác định');
        final communeMatch = selectedCommunes.isEmpty || selectedCommunes.contains(company.communeName ?? 'Không xác định');
        return nameMatch && typeMatch && districtMatch && communeMatch;
      }).toList();
    });
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Bộ lọc',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ExpansionTile(
            title: const Text('Loại hình'),
            children: allTypes.map((type) => CheckboxListTile(
              title: Text(type),
              value: selectedTypes.contains(type),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }
                  _filterCompanies();
                });
              },
            )).toList(),
          ),
          ExpansionTile(
            title: const Text('Huyện'),
            children: districtCommunes.keys.map((district) => CheckboxListTile(
              title: Text(district),
              value: selectedDistricts.contains(district),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedDistricts.add(district);
                  } else {
                    selectedDistricts.remove(district);
                    // Xóa các xã đã chọn của huyện này
                    selectedCommunes.removeWhere((commune) => districtCommunes[district]!.contains(commune));
                  }
                  _filterCompanies();
                });
              },
            )).toList(),
          ),
          if (selectedDistricts.isNotEmpty)
            ExpansionTile(
              title: const Text('Xã'),
              children: selectedDistricts.expand((district) => 
                districtCommunes[district]!.map((commune) => CheckboxListTile(
                  title: Text('$commune ($district)'),
                  value: selectedCommunes.contains(commune),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedCommunes.add(commune);
                      } else {
                        selectedCommunes.remove(commune);
                      }
                      _filterCompanies();
                    });
                  },
                ))
              ).toList(),
            ),
          ListTile(
            title: const Text('Xóa bộ lọc'),
            leading: const Icon(Icons.clear_all),
            onTap: () {
              setState(() {
                selectedTypes.clear();
                selectedDistricts.clear();
                selectedCommunes.clear();
                _filterCompanies();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả công ty'),
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
      endDrawer: _buildFilterDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm công ty',
                hintText: 'Nhập tên công ty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _filterCompanies();
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredCompanies.length,
                    itemBuilder: (context, index) {
                      final company = filteredCompanies[index];
                      return ListTile(
                        leading: company.logoUrl != null
                            ? Image.network(
                                company.logoUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.business, size: 50, color: Colors.blue);
                                },
                              )
                            : const Icon(Icons.business, size: 50, color: Colors.blue),
                        title: Text(company.name),
                        subtitle: Text('${company.typeName ?? 'Không xác định'} - ${company.communeName ?? 'Không xác định'} - ${company.districtName ?? 'Không xác định'}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyDetails(companyId: company.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}