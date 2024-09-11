import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoData {
  final String id;
  final String title;
  VideoPlayerController? controller;
  ChewieController? chewieController;
  bool isInitialized = false;
  String? offlineFilePath;

  VideoData({required this.id, required this.title, this.offlineFilePath});

  Future<void> initialize() async {
    if (!isInitialized) {
      if (offlineFilePath != null) {
        controller = VideoPlayerController.file(File(offlineFilePath!));
      } else {
        controller = VideoPlayerController.network(
          'https://drive.google.com/uc?export=download&id=$id',
        );
      }
      await controller!.initialize();
      chewieController = ChewieController(
        videoPlayerController: controller!,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
      );
      isInitialized = true;
    }
  }

  void dispose() {
    controller?.dispose();
    chewieController?.dispose();
  }
}