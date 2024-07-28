import 'package:intl/intl.dart';

class News {
  final int id;
  final String title;
  final DateTime publishedAt;
  String? content;

  News({
    required this.id, 
    required this.title, 
    required this.publishedAt,
    this.content
  });

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(publishedAt);
  }
}