import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ocop/src/page/home/content/companies/companyDetails.dart';
import 'package:ocop/src/page/home/content/companies/allCompanies.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  CompanyListState createState() => CompanyListState();
}

class CompanyListState extends State<CompanyList> {
  List<Company> companies = [];
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  void loadCompanies() {
    // Call your existing method to load products
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      isLoading = true;
    });

    List<Company> onlineCompanies = [];
    List<Company> offlineCompanies = []; // Thường sẽ trống vì công ty không lưu offline

    // Kiểm tra kết nối và tải dữ liệu online nếu có thể
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await db.connect();
        onlineCompanies = await db.getRandomCompanies(limit: 10);
      } catch (e) {
        print('Lỗi khi tải dữ liệu công ty online: $e');
      } finally {
        await db.close();
      }
    }

    // Kết hợp dữ liệu online và offline, ưu tiên dữ liệu online
    Map<int, Company> companyMap = {};
    for (var company in onlineCompanies) {
      companyMap[company.id] = company;
    }
    for (var company in offlineCompanies) {
      if (!companyMap.containsKey(company.id)) {
        companyMap[company.id] = company;
      }
    }

    setState(() {
      companies = companyMap.values.toList();
      isLoading = false;
    });
  }

  String truncateName(String name, int wordLimit) {
    List<String> words = name.split(' ');
    if (words.length <= wordLimit) {
      return name;
    }
    return '${words.take(wordLimit).join(' ')}...';
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetails(companyId: company.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: company.logoUrl != null
                    ? Image.network(
                        company.logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.business, size: 60, color: Colors.blue);
                        },
                      )
                    : const Icon(Icons.business, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                truncateName(company.name, 5),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Công ty",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllCompanies()),
                  );
                },
                child: const Text(
                  "Xem tất cả",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : companies.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Kết nối mạng để xem thông tin công ty",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : CarouselSlider.builder(
                    itemCount: companies.length,
                    itemBuilder: (BuildContext context, int index, int realIndex) {
                      return _buildCompanyCard(companies[index]);
                    },
                    options: CarouselOptions(
                      height: 180,
                      viewportFraction: 0.5,
                      enableInfiniteScroll: companies.length > 1,
                      enlargeCenterPage: true,
                      autoPlay: companies.length > 1,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                  ),
      ],
    );
  }
}