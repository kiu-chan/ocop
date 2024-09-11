import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:ocop/src/data/home/videosData.dart';
import 'package:video_player/video_player.dart';

class VideoOfflineStorage {
  static const String _offlineVideosKey = 'offline_videos';

  static Future<void> saveVideo(VideoData video) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Directory? documentsDirectory;
      try {
        documentsDirectory = await getApplicationDocumentsDirectory();
      } catch (e) {
        print('Error getting application documents directory: $e');
        // Fallback to temporary directory if documents directory is not available
        documentsDirectory = await getTemporaryDirectory();
      }
      
      String videoFileName = 'video_${video.id}.mp4';
      String videoFilePath = join(documentsDirectory.path, videoFileName);

      // Download the video
      final response = await http.get(Uri.parse('https://drive.google.com/uc?export=download&id=${video.id}'));
      File videoFile = File(videoFilePath);
      await videoFile.writeAsBytes(response.bodyBytes);

      // Save video info to SharedPreferences
      Map<String, dynamic> videoInfo = {
        'id': video.id,
        'title': video.title,
        'filePath': videoFilePath,
      };

      List<String> savedVideos = prefs.getStringList(_offlineVideosKey) ?? [];
      savedVideos.add(json.encode(videoInfo));
      await prefs.setStringList(_offlineVideosKey, savedVideos);
    } catch (e) {
      print('Error saving video: $e');
      // You might want to rethrow or handle this error depending on your app's needs
    }
  }

  static Future<List<VideoData>> getOfflineVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedVideos = prefs.getStringList(_offlineVideosKey) ?? [];
      
      return savedVideos.map((videoString) {
        Map<String, dynamic> videoInfo = json.decode(videoString);
        return VideoData(
          id: videoInfo['id'],
          title: videoInfo['title'],
        )..controller = VideoPlayerController.file(File(videoInfo['filePath']));
      }).toList();
    } catch (e) {
      print('Error getting offline videos: $e');
      return [];
    }
  }

  static Future<bool> isVideoSaved(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedVideos = prefs.getStringList(_offlineVideosKey) ?? [];
      return savedVideos.any((videoString) {
        Map<String, dynamic> videoInfo = json.decode(videoString);
        return videoInfo['id'] == videoId;
      });
    } catch (e) {
      print('Error checking if video is saved: $e');
      return false;
    }
  }

  static Future<void> removeVideo(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedVideos = prefs.getStringList(_offlineVideosKey) ?? [];
      
      savedVideos.removeWhere((videoString) {
        Map<String, dynamic> videoInfo = json.decode(videoString);
        if (videoInfo['id'] == videoId) {
          // Delete the video file
          File(videoInfo['filePath']).deleteSync();
          return true;
        }
        return false;
      });

      await prefs.setStringList(_offlineVideosKey, savedVideos);
    } catch (e) {
      print('Error removing video: $e');
    }
  }
}