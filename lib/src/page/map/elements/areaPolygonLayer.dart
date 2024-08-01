import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ocop/src/data/map/areaData.dart';

class AreaPolygonLayer extends StatelessWidget {
  final List<AreaData> area;
  final List<Color> orderedColors;

  const AreaPolygonLayer({
    super.key,
    required this.area,
    required this.orderedColors,
  });

  @override
  Widget build(BuildContext context) {
    List<Polygon> polygons = [];

    for (int i = 0; i < area.length; i++) {
      AreaData commune = area[i];
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