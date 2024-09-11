import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ocop/src/page/home/content/companies/companyDetails.dart';
import 'package:ocop/src/page/home/content/companies/allCompanies.dart';
import 'package:ocop/mainData/offline/company_offline_storage.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  CompanyListState createState() => CompanyListState();
}

class CompanyListState extends State<CompanyList> {
  List<Company> companies = []; // Danh sách các công ty sẽ được hiển thị
  final DefaultDatabaseOptions db = DefaultDatabaseOptions(); // Đối tượng để tương tác với cơ sở dữ liệu
  bool isLoading = true; // Biến để kiểm soát trạng thái đang tải dữ liệu

  @override
  void initState() {
    super.initState();
    _loadCompanies(); // Gọi hàm tải dữ liệu công ty khi widget được khởi tạo
  }

  // Phương thức công khai để tải lại dữ liệu công ty
  void loadCompanies() {
    _loadCompanies();
  }

  // Phương thức để tải dữ liệu công ty
  Future<void> _loadCompanies() async {
    setState(() {
      isLoading = true; // Bắt đầu quá trình tải, hiển thị trạng thái đang tải
    });

    List<Company> onlineCompanies = []; // Danh sách công ty từ server
    List<Company> offlineCompanies = await CompanyOfflineStorage.getOfflineCompanies(); // Lấy danh sách công ty đã lưu offline

    // Kiểm tra kết nối internet
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      try {
        await db.connect(); // Kết nối đến cơ sở dữ liệu
        onlineCompanies = await db.getRandomCompanies(limit: 10); // Lấy 10 công ty ngẫu nhiên từ server
      } catch (e) {
        print('Lỗi khi tải dữ liệu công ty online: $e');
      } finally {
        await db.close(); // Đảm bảo đóng kết nối cơ sở dữ liệu
      }
    }

    // Kết hợp dữ liệu online và offline, ưu tiên dữ liệu online
    Map<int, Company> companyMap = {};
    for (var company in offlineCompanies) {
      companyMap[company.id] = company;
    }
    for (var company in onlineCompanies) {
      companyMap[company.id] = company; // Ghi đè lên dữ liệu offline nếu có
    }

    setState(() {
      companies = companyMap.values.toList(); // Cập nhật danh sách công ty
      isLoading = false; // Kết thúc quá trình tải
    });
  }

  // Phương thức để cắt ngắn tên công ty nếu quá dài
  String truncateName(String name, int wordLimit) {
    List<String> words = name.split(' ');
    if (words.length <= wordLimit) {
      return name;
    }
    return '${words.take(wordLimit).join(' ')}...';
  }

  // Widget để hiển thị một công ty
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
            ? const Center(child: CircularProgressIndicator()) // Hiển thị indicator khi đang tải
            : companies.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Không có thông tin công ty. Hãy kết nối mạng để tải dữ liệu mới.",
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