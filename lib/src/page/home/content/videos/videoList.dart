import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/home/videosData.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  VideoListState createState() => VideoListState();
}

class VideoListState extends State<VideoList> {
  List<VideoData> videos = [];
  bool isLoading = true;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void loadVideos() {
    // Call your existing method to load products
    _loadVideos();
  }
  Future<void> _loadVideos() async {
    setState(() {
      isLoading = true;
    });

    List<VideoData> onlineVideos = [];
    List<VideoData> offlineVideos = []; // Thường sẽ trống vì video không lưu offline

    // Kiểm tra kết nối và tải dữ liệu online nếu có thể
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      final DefaultDatabaseOptions db = DefaultDatabaseOptions();
      try {
        await db.connect();
        onlineVideos = await db.getAllVideo();
        if (onlineVideos.isNotEmpty) {
          await onlineVideos[0].initialize();
        }
      } catch (e) {
        print('Lỗi khi tải dữ liệu video online: $e');
      } finally {
        await db.close();
      }
    }

    // Kết hợp dữ liệu online và offline, ưu tiên dữ liệu online
    Map<String, VideoData> videoMap = {};
    for (var video in onlineVideos) {
      videoMap[video.id] = video;
    }
    for (var video in offlineVideos) {
      if (!videoMap.containsKey(video.id)) {
        videoMap[video.id] = video;
      }
    }

    setState(() {
      videos = videoMap.values.toList();
      isLoading = false;
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
    if (videos.isEmpty) {
      return Center(
        child: Text(
          "Kết nối mạng để xem video",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return videos[_currentVideoIndex].isInitialized
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(controller: videos[_currentVideoIndex].chewieController!),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Future<void> _changeVideo(int index) async {
    if (index != _currentVideoIndex) {
      setState(() {
        isLoading = true;
      });
      if (videos[_currentVideoIndex].controller != null) {
        videos[_currentVideoIndex].controller!.pause();
      }
      if (!videos[index].isInitialized) {
        await videos[index].initialize();
      }
      setState(() {
        _currentVideoIndex = index;
        isLoading = false;
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
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
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
                      if (videos.isNotEmpty)
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