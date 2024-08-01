import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CommunePolygonLayer extends StatelessWidget {
  final List<Map<String, dynamic>> communes;
  final List<Color> orderedColors;

  const CommunePolygonLayer({
    Key? key,
    required this.communes,
    required this.orderedColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygonCulling: false,
      polygons: communes.asMap().entries.expand((entry) {
        int index = entry.key;
        var commune = entry.value;
        Color color = orderedColors[index % orderedColors.length];
        return (commune['polygons'] as List<List<LatLng>>).map((points) => Polygon(
          points: points,
          color: color.withOpacity(0.3),
          borderColor: Colors.black,
          borderStrokeWidth: 1,
          isFilled: true,
        )).toList();
      }).toList(),
    );
  }
}