import 'package:intl/intl.dart';

class News {
  final int id;
  final String title;
  final DateTime publishedAt;
  String? content;
  String? imageUrl;

  News({
    required this.id, 
    required this.title, 
    required this.publishedAt,
    this.content,
    this.imageUrl,
  });

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(publishedAt);
  }
}