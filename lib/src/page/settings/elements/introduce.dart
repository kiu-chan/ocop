import 'package:flutter/material.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

class Introduce extends StatefulWidget {
  const Introduce({Key? key}) : super(key: key);

  @override
  _IntroduceState createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  bool isLoading = true;
  String? content;
  String? updatedAt;

  @override
  void initState() {
    super.initState();
    _loadAbout();
  }

  Future<void> _loadAbout() async {
    await db.connect();
    final aboutsData = await db.getAboutsContent(1);
    setState(() {
      if (aboutsData != null) {
        content = aboutsData['content'];
        updatedAt = aboutsData['updated_at'];
      }
      isLoading = false;
    });
    await db.close();
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduce'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giới thiệu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (updatedAt != null)
                          Text(
                            'Cập nhật lần cuối: ${_formatDate(updatedAt!)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (content != null)
                          Html(
                            data: content,
                            style: {
                              "body": Style(
                                fontSize: FontSize(16),
                                lineHeight: const LineHeight(1.5),
                              ),
                            },
                          )
                        else
                          const Text("Không có nội dung giới thiệu."),
                      ],
                    ),
                  ),
                  const Center(child: Logo()),
                ],
              ),
            ),
    );
  }
}