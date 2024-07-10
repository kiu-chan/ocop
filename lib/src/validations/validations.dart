import 'dart:convert';

// import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class Validations {
  static bool isValidUser(String user) {
    return true;
    // code here
    // return user.length > 6 && user.contains('@');
  }

  static bool isValidPassword(String pass) {
    return true;
    // Code here
    return pass.length > 6;
  }

  static bool isValidPassword2(String pass, String pass2) {
    // Code here
    return pass == pass2;
  }

  static bool isValidQuiz(bool key, String? answer) {
    return key && answer != null;
  }
  static Future<bool> checkString(String answer, String correct) async {
    return toUpper(answer.trim()) == toUpper(correct.trim());
  }

  // static Future<bool> isCorrectVideo(XFile file, String name) async {
  //   // String pathVideo = file.path;
  //   // String result = await getWord(pathVideo);
  //   // return (result == name);
  //   // return true;
  //   var apiUrl = Uri.parse('http://10.0.2.2:5000/');
  //   var request = http.MultipartRequest('POST', apiUrl);

  //   var videoStream = http.ByteStream(file.openRead());
  //   var videoLength = await file.length();
  //   request.files.add(http.MultipartFile('video', videoStream, videoLength,
  //       filename: 'video.mp4'));
  //   var response = await http.Response.fromStream(await request.send());
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> result = jsonDecode(response.body);
  //     print(result['message']);
  //     return await checkString(result['message'], name);
  //   }
  //   print('Failed to upload video. Status code: ${response.statusCode}');
  //   return false;
  // }

  static String toUpper(String temp) {
    return temp.toUpperCase();
  }
}
