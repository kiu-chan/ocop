import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/companyData.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:flutter_html/flutter_html.dart';

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
                        style: Theme.of(context).textTheme.titleLarge, // Đã thay đổi từ headline5 sang titleLarge
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
                        ),
                      if (company!.email != null)
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(company!.email!),
                        ),
                    ],
                  ),
                ),
    );
  }
}