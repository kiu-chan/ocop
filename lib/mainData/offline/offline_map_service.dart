import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:latlong2/latlong.dart';
import 'dart:math' show Point, cos, log, pi, pow, tan;

class OfflineMapService {
  late Directory _cacheDirectory;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory(path.join(appDir.path, 'map_tiles'));
    if (!await _cacheDirectory.exists()) {
      await _cacheDirectory.create(recursive: true);
    }
  }

  Future<void> downloadAndSaveTiles(String urlTemplate, int minZoom, int maxZoom, LatLngBounds bounds) async {
    for (int z = minZoom; z <= maxZoom; z++) {
      final tileRange = _getTileRange(bounds, z);
      for (int x = tileRange.min.x; x <= tileRange.max.x; x++) {
        for (int y = tileRange.min.y; y <= tileRange.max.y; y++) {
          final url = urlTemplate
              .replaceAll('{z}', z.toString())
              .replaceAll('{x}', x.toString())
              .replaceAll('{y}', y.toString());
          final tileId = '$z/$x/$y';
          await _downloadAndSaveTile(url, tileId);
        }
      }
    }
  }

  Future<void> _downloadAndSaveTile(String url, String tileId) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(path.join(_cacheDirectory.path, '$tileId.png'));
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
      }
    } catch (e) {
      print('Error downloading tile $tileId: $e');
    }
  }

  Future<Uint8List?> getTile(String tileId) async {
    final file = File(path.join(_cacheDirectory.path, '$tileId.png'));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  TileRange _getTileRange(LatLngBounds bounds, int zoom) {
    final min = _latLngToTileNum(bounds.southWest!, zoom);
    final max = _latLngToTileNum(bounds.northEast!, zoom);
    return TileRange(min, max);
  }

  Point<int> _latLngToTileNum(LatLng latLng, int zoom) {
    final lat = latLng.latitude;
    final lon = latLng.longitude;
    final x = ((lon + 180) / 360 * pow(2, zoom)).floor();
    final y = ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2 * pow(2, zoom)).floor();
    return Point(x, y);
  }
}

class TileRange {
  final Point<int> min;
  final Point<int> max;

  TileRange(this.min, this.max);
}