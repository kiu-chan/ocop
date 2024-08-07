import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/home/videosData.dart';


class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  List<VideoData> videos = [];
  int _currentVideoIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });
    await db.connect();
    videos = await db.getAllVideo();
    await db.close();

    if (videos.isNotEmpty) {
      await videos[0].initialize();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var video in videos) {
      video.dispose();
    }
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return videos.isNotEmpty && videos[_currentVideoIndex].isInitialized
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(controller: videos[_currentVideoIndex].chewieController!),
          )
        : const Center(child: Text('Đang tải video...'));
  }

  Future<void> _changeVideo(int index) async {
    if (index != _currentVideoIndex) {
      setState(() {
        _isLoading = true;
      });

      if (videos[_currentVideoIndex].controller != null) {
        videos[_currentVideoIndex].controller!.pause();
      }

      if (!videos[index].isInitialized) {
        await videos[index].initialize();
      }

      setState(() {
        _currentVideoIndex = index;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Video",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Player
                SizedBox(
                  width: constraints.maxWidth * 0.7, // 70% of the width
                  child: _buildVideoPlayer(),
                ),
                // Video List
                SizedBox(
                  width: constraints.maxWidth * 0.3, // 30% of the width
                  height: constraints.maxWidth * 0.7 * 9 / 16, // Match the height of the video player
                  child: ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          videos[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _changeVideo(index),
                        selected: index == _currentVideoIndex,
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}