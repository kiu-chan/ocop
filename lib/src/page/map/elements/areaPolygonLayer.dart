import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ocop/src/data/map/areaData.dart';

class AreaPolygonLayer extends StatelessWidget {
  final List<AreaData> communes;
  final List<AreaData> districts;
  final List<Color> orderedColors;

  const AreaPolygonLayer({
    Key? key,
    required this.communes,
    required this.districts,
    required this.orderedColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Polygon> polygons = [];

    // Thêm polygon cho huyện
    for (int i = 0; i < districts.length; i++) {
      AreaData district = districts[i];
      if (district.isVisible) {
        Color color = Color(int.parse(district.color.substring(1, 7), radix: 16) + 0xFF000000);
        for (List<LatLng> points in district.polygons) {
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

    // Thêm polygon cho xã
    for (int i = 0; i < communes.length; i++) {
      AreaData commune = communes[i];
      if (commune.isVisible) {
        Color color = orderedColors[i % orderedColors.length];
        for (List<LatLng> points in commune.polygons) {
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

    return PolygonLayer(
      polygonCulling: false,
      polygons: polygons,
    );
  }
}