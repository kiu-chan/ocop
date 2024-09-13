import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/home/videosData.dart';
import 'package:ocop/mainData/offline/video_offline_storage.dart';

class VideoList extends StatefulWidget {
  const VideoList({Key? key}) : super(key: key);

  @override
  VideoListState createState() => VideoListState();
}

class VideoListState extends State<VideoList> {
  List<VideoData> videos = [];
  bool isLoading = true;
  int _currentVideoIndex = 0;
  Map<String, bool> _downloadingVideos = {};

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void loadVideos() {
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      isLoading = true;
    });

    List<VideoData> onlineVideos = [];
    List<VideoData> offlineVideos = await VideoOfflineStorage.getOfflineVideos();

    bool hasInternetConnection = await InternetConnectionChecker().hasConnection;
    if (hasInternetConnection) {
      final DefaultDatabaseOptions db = DefaultDatabaseOptions();
      try {
        await db.connect();
        onlineVideos = await db.getAllVideo();
      } catch (e) {
        print('Lỗi khi tải dữ liệu video online: $e');
      } finally {
        await db.close();
      }
    }

    Map<String, VideoData> videoMap = {};
    for (var video in offlineVideos) {
      videoMap[video.id] = video;
    }
    for (var video in onlineVideos) {
      if (!videoMap.containsKey(video.id)) {
        videoMap[video.id] = video;
      }
    }

    setState(() {
      videos = videoMap.values.toList();
      isLoading = false;
    });

    if (videos.isNotEmpty) {
      await videos[0].initialize();
      setState(() {});
    }
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
          "Kết nối mạng để xem video hoặc tải video để xem offline",
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

  Widget _buildVideoList() {
    return ListView.builder(
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
          trailing: FutureBuilder<bool>(
            future: VideoOfflineStorage.isVideoSaved(videos[index].id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (_downloadingVideos[videos[index].id] == true) {
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  );
                } else if (snapshot.data!) {
                  return IconButton(
                    icon: const Icon(Icons.offline_pin),
                    onPressed: () async {
                      await VideoOfflineStorage.removeVideo(videos[index].id);
                      _loadVideos(); // Reload videos after removing
                    },
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      setState(() {
                        _downloadingVideos[videos[index].id] = true;
                      });
                      await VideoOfflineStorage.saveVideo(videos[index]);
                      setState(() {
                        _downloadingVideos[videos[index].id] = false;
                      });
                      _loadVideos(); // Reload videos after saving
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
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
                      SizedBox(
                        width: constraints.maxWidth * 0.7,
                        child: _buildVideoPlayer(),
                      ),
                      if (videos.isNotEmpty)
                        SizedBox(
                          width: constraints.maxWidth * 0.3,
                          height: constraints.maxWidth * 0.7 * 9 / 16,
                          child: _buildVideoList(),
                        ),
                    ],
                  );
                },
              ),
      ],
    );
  }
}