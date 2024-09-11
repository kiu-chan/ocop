import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ocop/mainData/offline/company_offline_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CompanyDetails extends StatefulWidget {
  final int companyId;

  const CompanyDetails({super.key, required this.companyId});

  @override
  _CompanyDetailsState createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  Company? company;
  bool isLoading = true;
  bool isOfflineSaved = false;
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
    _checkOfflineStatus();
  }

  // Kiểm tra xem công ty đã được lưu offline chưa
  Future<void> _checkOfflineStatus() async {
    bool saved = await CompanyOfflineStorage.isCompanySaved(widget.companyId);
    setState(() {
      isOfflineSaved = saved;
    });
  }

  // Tải thông tin chi tiết của công ty
  Future<void> _loadCompanyDetails() async {
    setState(() {
      isLoading = true;
    });

    bool isOnline = await InternetConnectionChecker().hasConnection;

    if (isOnline) {
      await db.connect();
      final companyData = await db.getCompanyDetails(widget.companyId);
      setState(() {
        company = companyData;
        isLoading = false;
      });
      await db.close();
    } else {
      List<Company> offlineCompanies = await CompanyOfflineStorage.getOfflineCompanies();
      Company? offlineCompany = offlineCompanies.firstWhere(
        (c) => c.id == widget.companyId,
        orElse: () => Company(id: -1, name: 'Không tìm thấy công ty'),
      );
      setState(() {
        company = offlineCompany;
        isLoading = false;
      });
    }
  }

  // Mở URL trong trình duyệt
  void _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Không thể mở URL: $url');
      }
    } else {
      print('URL không hợp lệ');
    }
  }

  // Thực hiện cuộc gọi điện thoại
  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Không thể gọi điện thoại đến số: $phoneNumber');
      }
    } else {
      print('Số điện thoại không hợp lệ');
    }
  }

  // Mở bản đồ với tọa độ của công ty
  void _openMap(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Không thể mở bản đồ');
      }
    } else {
      print('Không có thông tin vị trí');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company?.name ?? 'Chi tiết công ty'),
        actions: [
          IconButton(
            icon: Icon(isOfflineSaved ? Icons.offline_pin : Icons.offline_pin_outlined),
            onPressed: () async {
              if (isOfflineSaved) {
                await CompanyOfflineStorage.removeCompany(widget.companyId);
              } else if (company != null) {
                await CompanyOfflineStorage.saveCompany(company!);
              }
              await _checkOfflineStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isOfflineSaved
                      ? 'Đã lưu công ty để xem offline'
                      : 'Đã xóa công ty khỏi bộ nhớ offline'),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : company == null
              ? const Center(child: Text('Không tìm thấy thông tin công ty'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị logo công ty
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: company!.logoUrl != null
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: Image.network(
                                  company!.logoUrl!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.business, size: 150);
                                  },
                                ),
                              )
                            : const FittedBox(
                                fit: BoxFit.cover,
                                child: Icon(Icons.business, size: 150),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên công ty
                            Text(
                              company!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Giới thiệu công ty
                            if (company!.introduction != null)
                              Html(data: company!.introduction!),
                            const SizedBox(height: 20),
                            // Địa chỉ công ty
                            if (company!.address != null || company!.communeName != null || company!.districtName != null)
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(
                                  [company!.address, company!.communeName, company!.districtName]
                                      .where((element) => element != null)
                                      .join(', '),
                                ),
                              ),
                            // Số điện thoại
                            if (company!.phoneNumber != null)
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(company!.phoneNumber!),
                                onTap: () => _makePhoneCall(company!.phoneNumber),
                              ),
                            // Người đại diện
                            if (company!.representative != null)
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(company!.representative!),
                              ),
                            // Website
                            if (company!.website != null)
                              ListTile(
                                leading: const Icon(Icons.web),
                                title: Text(company!.website!),
                                onTap: () => _launchURL(company!.website),
                              ),
                            // Email
                            if (company!.email != null)
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: Text(company!.email!),
                              ),
                            const SizedBox(height: 20),
                            // Nút xem trên bản đồ
                            ElevatedButton(
                              onPressed: () => _openMap(company!.latitude, company!.longitude),
                              child: const Text('Xem trên bản đồ'),
                            ),
                            const SizedBox(height: 20),
                            // Danh sách sản phẩm của công ty
                            const Text(
                              'Sản phẩm của công ty',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            company!.products.isEmpty
                                ? const Text('Công ty chưa có sản phẩm nào.')
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: company!.products.length,
                                    itemBuilder: (context, index) {
                                      return ProductCard(product: company!.products[index]);
                                    },
                                  ),
                            const SizedBox(height: 20),
                            const Center(child: Logo()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}