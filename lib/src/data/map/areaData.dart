import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class AreaData {
  final int id;
  final String name;
  final List<List<LatLng>> polygons;
  final String color;
  bool isVisible;

  AreaData({
    required this.id,
    required this.name,
    required this.polygons,
    required this.color,
    this.isVisible = true,
  });

  factory AreaData.fromJson(Map<String, dynamic> json) {
    List<List<LatLng>> geometries = [];
    if (json['geom_text'] != null) {
      String wkt = json['geom_text'];
      if (wkt.startsWith('MULTIPOLYGON')) {
        geometries = _parseMultiPolygon(wkt);
      } else if (wkt.startsWith('MULTILINESTRING')) {
        geometries = _parseMultiLineString(wkt);
      } else {
        print('Unexpected geometry type: $wkt');
      }
    } else {
      print('geom_text is null for id: ${json['id']}');
    }
    
    return AreaData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      polygons: geometries,
      color: json['color'] ?? '#333333',
      isVisible: json['isVisible'] ?? true,
    );
  }

  void toggleVisibility() {
    isVisible = !isVisible;
  }

  static List<List<LatLng>> _parseMultiPolygon(String wkt) {
    List<List<LatLng>> polygons = [];
    try {
      String coordinatesStr = wkt.split('MULTIPOLYGON(((')[1].split(')))')[0];
      List<String> polygonStrs = coordinatesStr.split(')),((');

      for (String polygonStr in polygonStrs) {
        List<LatLng> points = [];
        List<String> coordPairs = polygonStr.split(',');
        for (String coord in coordPairs) {
          coord = coord.trim().replaceAll(RegExp(r'[()]'), '');
          var parts = coord.split(' ');
          if (parts.length == 2) {
            try {
              double lng = double.parse(parts[0]);
              double lat = double.parse(parts[1]);
              points.add(LatLng(lat, lng));
            } catch (e) {
              print('Error parsing coordinate: $coord');
            }
          } else {
            print('Invalid coordinate format: $coord');
          }
        }
        if (points.isNotEmpty) {
          polygons.add(points);
        }
      }
    } catch (e) {
      print('Error parsing MultiPolygon: $e');
    }
    return polygons;
  }

  static List<List<LatLng>> _parseMultiLineString(String wkt) {
    List<List<LatLng>> lines = [];
    try {
      String coordinatesStr = wkt.split('MULTILINESTRING((')[1].split('))')[0];
      List<String> lineStrs = coordinatesStr.split('),(');

      for (String lineStr in lineStrs) {
        List<LatLng> points = [];
        List<String> coordPairs = lineStr.split(',');
        for (String coord in coordPairs) {
          var parts = coord.trim().split(' ');
          if (parts.length == 2) {
            try {
              double lng = double.parse(parts[0]);
              double lat = double.parse(parts[1]);
              points.add(LatLng(lat, lng));
            } catch (e) {
              print('Error parsing coordinate: $coord');
            }
          }
        }
        if (points.isNotEmpty) {
          lines.add(points);
        }
      }
    } catch (e) {
      print('Error parsing MultiLineString: $e');
    }
    return lines;
  }
}