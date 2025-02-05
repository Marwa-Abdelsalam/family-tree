import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

import '../controllers/family_member_controller.dart';
import 'package:get/get.dart' as getx;

class CurvedEdgeRenderer extends EdgeRenderer {
  final BuchheimWalkerConfiguration configuration;
  final List<Edge> highlightedEdges;
  final FamilyMemberController controller = getx.Get.isRegistered<FamilyMemberController>()
      ? getx.Get.find<FamilyMemberController>()
      : getx.Get.put(FamilyMemberController());

  CurvedEdgeRenderer(this.configuration, {required this.highlightedEdges});

  @override
  void render(Canvas canvas, Graph graph, Paint paint) {
    final edges = graph.edges;
    for (final edge in edges) {
      final isHighlighted = highlightedEdges.any((highlightedEdge) =>
      (highlightedEdge.source == edge.source &&
          highlightedEdge.destination == edge.destination) ||
          (highlightedEdge.source == edge.destination &&
              highlightedEdge.destination == edge.source));
      renderEdge(canvas, edge, paint, isHighlighted);
    }
  }

  // Method to render an edge with highlighting if specified
  void renderEdge(Canvas canvas, Edge edge, Paint paint, bool highlight) {
    final source = edge.source.position;
    final target = edge.destination.position;

    final startX = source.dx + (edge.source.size.width / 2);
    final startY = source.dy + (edge.source.size.height / 2);
    final endX = target.dx + (edge.destination.size.width / 2);
    final endY = target.dy + (edge.destination.size.height / 2);
    final controlPointX1 = startX + (endX - startX) / 2;
    final controlPointY1 = startY;
    final controlPointX2 = startX + (endX - startX) / 2;
    final controlPointY2 = endY;

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(controlPointX1, controlPointY1, controlPointX2, controlPointY2, endX, endY);

    if (highlight) {
      final highlightedPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, highlightedPaint);
    } else {
      canvas.drawPath(path, paint);
    }
    print("edge rendered");
  }
}
