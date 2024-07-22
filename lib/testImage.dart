import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Base64 Image Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String jsonData = '{"media_library_original":{"urls":["oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_600_450.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_501_376.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_419_314.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_351_263.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_293_220.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_245_184.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_205_154.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_172_129.jpg","oSoaKnPiEKMak7AknN0vYmLj3UBjYd-metaT0NPUC0xMDA0LmpwZw==-___media_library_original_144_108.jpg"],"base64svg":"data:image/svg+xml;base64,PCFET0NUWVBFIHN2ZyBQVUJMSUMgIi0vL1czQy8vRFREIFNWRyAxLjEvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkIj4KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIHg9IjAiCiB5PSIwIiB2aWV3Qm94PSIwIDAgNjAwIDQ1MCI+Cgk8aW1hZ2Ugd2lkdGg9IjYwMCIgaGVpZ2h0PSI0NTAiIHhsaW5rOmhyZWY9ImRhdGE6aW1hZ2UvanBlZztiYXNlNjQsLzlqLzRBQVFTa1pKUmdBQkFRRUFZQUJnQUFELy9nQTdRMUpGUVZSUFVqb2daMlF0YW5CbFp5QjJNUzR3SUNoMWMybHVaeUJKU2tjZ1NsQkZSeUIyTmpJcExDQnhkV0ZzYVhSNUlEMGdPVEFLLzlzQVF3QURBZ0lEQWdJREF3TURCQU1EQkFVSUJRVUVCQVVLQndjR0NBd0tEQXdMQ2dzTERRNFNFQTBPRVE0TEN4QVdFQkVURkJVVkZRd1BGeGdXRkJnU0ZCVVUvOXNBUXdFREJBUUZCQVVKQlFVSkZBMExEUlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVS84QUFFUWdBR0FBZ0F3RWlBQUlSQVFNUkFmL0VBQjhBQUFFRkFRRUJBUUVCQUFBQUFBQUFBQUFCQWdNRUJRWUhDQWtLQy8vRUFMVVFBQUlCQXdNQ0JBTUZCUVFFQUFBQmZRRUNBd0FFRVFVU0lURkJCaE5SWVFjaWNSUXlnWkdoQ0NOQ3NjRVZVdEh3SkROaWNvSUpDaFlYR0JrYUpTWW5LQ2txTkRVMk56ZzVPa05FUlVaSFNFbEtVMVJWVmxkWVdWcGpaR1ZtWjJocGFuTjBkWFozZUhsNmc0U0Zob2VJaVlxU2s1U1ZscGVZbVpxaW82U2xwcWVvcWFxeXM3UzF0cmU0dWJyQ3c4VEZ4c2ZJeWNyUzA5VFYxdGZZMmRyaDR1UGs1ZWJuNk9ucThmTHo5UFgyOS9qNSt2L0VBQjhCQUFNQkFRRUJBUUVCQVFFQUFBQUFBQUFCQWdNRUJRWUhDQWtLQy8vRUFMVVJBQUlCQWdRRUF3UUhCUVFFQUFFQ2R3QUJBZ01SQkFVaE1RWVNRVkVIWVhFVElqS0JDQlJDa2FHeHdRa2pNMUx3RldKeTBRb1dKRFRoSmZFWEdCa2FKaWNvS1NvMU5qYzRPVHBEUkVWR1IwaEpTbE5VVlZaWFdGbGFZMlJsWm1kb2FXcHpkSFYyZDNoNWVvS0RoSVdHaDRpSmlwS1RsSldXbDVpWm1xS2pwS1dtcDZpcHFyS3p0TFcydDdpNXVzTER4TVhHeDhqSnl0TFQxTlhXMTlqWjJ1TGo1T1htNStqcDZ2THo5UFgyOS9qNSt2L2FBQXdEQVFBQ0VRTVJBRDhBK2h2R0h4dTFmVHRWdVJETDhpZEZGY2xkL0cveGpyNkE2Y0dVTDk0a1Y1ajR4MWpWZkRmeE91WUxxQXkyam5vdzRyMXJTdFZMNklvc3JCVmFSZVNCWGgxOFJKU2FnOWo2K0ZDTUtNWjhxdXo2RS9aNzhWNmw0azhQczJwdnZ1RU9EWHJMMTh2ZkN6NHBhVDhOckNhUFdKUkJKSzJRRFhxV20vSHZ3M3JES3R2ZEt4YnB6WHFVS3FsQk45VDV6RVU1S3BKcGFIenY4VnZEVW5qSHhOY0xhMllTUmVqZ1ZGNGYwL1ZmQ21qdEZOQ1pXSEFKb29yNTZWSktzNUp1NTlaQ3B6VW8wbWxiUTh4K0kzaG5YUEdNMGNzY0xSaFQyTmIvQU1OL2h6ckZuY1czbXF3QVByUlJYclVhYXNqeU1YVWFjb3BhSC8vWiI+Cgk8L2ltYWdlPgo8L3N2Zz4="}}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Base64 Image Demo'),
      ),
      body: Center(
        child: Base64ImageWidget(jsonData: jsonData),
      ),
    );
  }
}

class Base64ImageWidget extends StatelessWidget {
  final String jsonData;

  Base64ImageWidget({required this.jsonData});

  @override
  Widget build(BuildContext context) {
    try {
      // Parse JSON data
      Map<String, dynamic> data = json.decode(jsonData);
      String base64Svg = data['media_library_original']['base64svg'];

      print('Base64 SVG length: ${base64Svg.length}');

      // Remove the data:image/svg+xml;base64, prefix
      String cleanBase64 = base64Svg.split(',').last;

      print('Cleaned Base64 length: ${cleanBase64.length}');

      // Decode the base64 string
      Uint8List bytes = Uint8List.fromList(base64Decode(cleanBase64));

      print('Decoded bytes length: ${bytes.length}');

      // Check if it's a valid SVG
      String svgString = utf8.decode(bytes);
      if (svgString.toLowerCase().contains('<svg')) {
        print('Data appears to be SVG');
        // If it's SVG, we need to extract the embedded image
        RegExp regExp = RegExp(r'xlink:href="data:image/jpeg;base64,(.*?)"');
        Match? match = regExp.firstMatch(svgString);
        if (match != null && match.groupCount >= 1) {
          String jpegBase64 = match.group(1)!;
          print('Extracted JPEG Base64 length: ${jpegBase64.length}');
          bytes = Uint8List.fromList(base64Decode(jpegBase64));
          print('Decoded JPEG bytes length: ${bytes.length}');
        } else {
          print('No embedded JPEG found in SVG');
          return Text('Không tìm thấy dữ liệu JPEG trong SVG');
        }
      } else {
        print('Data does not appear to be SVG');
      }

      // Try to create the image
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return Text('Lỗi khi tải hình ảnh: $error');
        },
      );
    } catch (e) {
      print('Exception caught: $e');
      return Text('Lỗi: $e');
    }
  }
}