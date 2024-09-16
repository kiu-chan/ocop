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
      try {
        if (offlineFilePath != null && File(offlineFilePath!).existsSync()) {
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
      } catch (e) {
        print('Error initializing video: $e');
        // Xử lý lỗi ở đây, ví dụ: hiển thị thông báo cho người dùng
        rethrow; // Ném lại lỗi để caller có thể xử lý nếu cần
      }
    }
  }

  Future<void> dispose() async {
    await controller?.dispose();
    chewieController?.dispose();
  }
}