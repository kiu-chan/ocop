import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/newsData.dart';
import 'package:ocop/src/page/home/content/news/elements/newsContent.dart';

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  Widget _buildImage() {
    if (news.imageUrl != null) {
      if (news.imageUrl!.startsWith('data:image')) {
        // This is a base64 encoded image
        return Image.memory(
          Uri.parse(news.imageUrl!).data!.contentAsBytes(),
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading base64 image: $error');
            return _buildFallbackImage();
          },
        );
      } else {
        // This is a network image
        return Image.network(
          news.imageUrl!,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return _buildFallbackImage();
          },
        );
      }
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      'lib/src/assets/img/img.jpg',
      height: 100,
      width: 100,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewContent(news: news),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: _buildImage(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}