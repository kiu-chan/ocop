import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetails extends StatefulWidget {
  final int companyId;

  const CompanyDetails({Key? key, required this.companyId}) : super(key: key);

  @override
  _CompanyDetailsState createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  Company? company;
  bool isLoading = true;
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
  }

  Future<void> _loadCompanyDetails() async {
    await db.connect();
    final companyData = await db.getCompanyDetails(widget.companyId);
    setState(() {
      company = companyData;
      isLoading = false;
    });
    await db.close();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company?.name ?? 'Chi tiết công ty'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : company == null
              ? const Center(child: Text('Không tìm thấy thông tin công ty'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: company!.logoUrl != null
                            ? Image.network(
                                company!.logoUrl!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.business, size: 150),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        company!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (company!.introduction != null)
                        Html(data: company!.introduction!),
                      const SizedBox(height: 20),
                      if (company!.address != null)
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(company!.address!),
                        ),
                      if (company!.phoneNumber != null)
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(company!.phoneNumber!),
                          onTap: () => _makePhoneCall(company!.phoneNumber),
                        ),
                      if (company!.representative != null)
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(company!.representative!),
                        ),
                      if (company!.website != null)
                        ListTile(
                          leading: const Icon(Icons.web),
                          title: Text(company!.website!),
                          onTap: () => _launchURL(company!.website),
                        ),
                      if (company!.email != null)
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(company!.email!),
                        ),
                      const SizedBox(height: 20),
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
                    ],
                  ),
                ),
    );
  }
}