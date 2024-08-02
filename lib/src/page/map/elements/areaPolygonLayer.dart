import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ocop/src/data/map/areaData.dart';

class AreaPolygonLayer extends StatelessWidget {
  final List<AreaData> communes;
  final List<AreaData> districts;
  final List<AreaData> borders;
  final List<Color> orderedColors;
  final bool showBorders;
  final bool showDistricts;
  final bool showCommunes;

  const AreaPolygonLayer({
    Key? key,
    required this.communes,
    required this.districts,
    required this.borders,
    required this.orderedColors,
    required this.showBorders,
    required this.showDistricts,
    required this.showCommunes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Polygon> polygons = [];
    List<Polyline> polylines = [];

    // Thêm polyline cho biên giới
    if (showBorders && borders.isNotEmpty) {
      for (var border in borders) {
        if (border.polygons.isNotEmpty) {
          for (List<LatLng> points in border.polygons) {
            if (points.length >= 2) { // Đảm bảo có đủ điểm để tạo đường
              polylines.add(
                Polyline(
                  points: points,
                  color: Colors.red,
                  strokeWidth: 3.0,
                ),
              );
            }
          }
        }
      }
    }

    // Thêm polygon cho huyện
    if (showDistricts) {
      for (int i = 0; i < districts.length; i++) {
        AreaData district = districts[i];
        if (district.isVisible && district.polygons.isNotEmpty) {
          Color color = Color(int.parse(district.color.substring(1, 7), radix: 16) + 0xFF000000);
          for (List<LatLng> points in district.polygons) {
            if (points.length >= 3) {
              polygons.add(
                Polygon(
                  points: points,
                  color: color.withOpacity(0.3),
                  borderColor: Colors.black,
                  borderStrokeWidth: 2,
                  isFilled: true,
                ),
              );
            }
          }
        }
      }
    }

    // Thêm polygon cho xã
    if (showCommunes) {
      for (int i = 0; i < communes.length; i++) {
        AreaData commune = communes[i];
        if (commune.isVisible && commune.polygons.isNotEmpty) {
          Color color = orderedColors[i % orderedColors.length];
          for (List<LatLng> points in commune.polygons) {
            if (points.length >= 3) {
              polygons.add(
                Polygon(
                  points: points,
                  color: color.withOpacity(0.3),
                  borderColor: Colors.black,
                  borderStrokeWidth: 1,
                  isFilled: true,
                ),
              );
            }
          }
        }
      }
    }

    return Stack(
      children: [
        PolygonLayer(
          polygonCulling: false,
          polygons: polygons,
        ),
        PolylineLayer(
          polylines: polylines,
        ),
      ],
    );
  }
}