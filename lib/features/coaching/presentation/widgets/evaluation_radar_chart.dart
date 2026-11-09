import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/student_evaluation_model.dart';

/// Interactive Spider / Radar Chart for Coaching Evaluation categories
/// (Physical, Mental, Skill, Attitude)
class EvaluationRadarChart extends StatelessWidget {
  final List<RadarCategoryData> categories;
  final double size;

  const EvaluationRadarChart({
    super.key,
    required this.categories,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return SizedBox(
        height: size.h,
        child: const Center(
          child: Text(
            'No category breakdown data available',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0x60D4AF37), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18D4AF37),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.radar_rounded, size: 20.sp, color: const Color(0xFFD4AF37)),
                  SizedBox(width: 8.w),
                  Text(
                    'Performance Radar',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0x80D4AF37), width: 1),
                ),
                child: Text(
                  '4-AXIS BENCHMARK',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9E7B1A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Radar Painter Canvas
          SizedBox(
            width: size.w,
            height: size.h,
            child: CustomPaint(
              painter: _RadarChartPainter(categories: categories),
            ),
          ),
          SizedBox(height: 16.h),

          // Bottom Category Breakdown Chips Wrap
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: cat.color.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.h,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: cat.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${cat.category}: ',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${cat.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w900,
                        color: cat.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<RadarCategoryData> categories;

  _RadarChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    final n = categories.length;
    if (n < 3) return;

    final gridPaint = Paint()
      ..color = const Color(0x35D4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final spokePaint = Paint()
      ..color = const Color(0x25D4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final polygonFillPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x55D4AF37),
          Color(0x25D4AF37),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final polygonStrokePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final vertexDotPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final vertexDotBorder = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 1. Draw Concentric Web Rings (25%, 50%, 75%, 100%)
    const ringLevels = [0.25, 0.50, 0.75, 1.0];
    for (final level in ringLevels) {
      final ringPath = Path();
      for (int i = 0; i < n; i++) {
        final angle = (i * 2 * math.pi / n) - (math.pi / 2);
        final x = center.dx + radius * level * math.cos(angle);
        final y = center.dy + radius * level * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // 2. Draw Radial Spokes & Calculate Vertex Points for Value Polygon
    final valuePath = Path();
    final List<Offset> vertexPoints = [];

    for (int i = 0; i < n; i++) {
      final angle = (i * 2 * math.pi / n) - (math.pi / 2);
      // Spoke to outer ring
      final outerX = center.dx + radius * math.cos(angle);
      final outerY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(outerX, outerY), spokePaint);

      // Value point based on category percentage (clamped 0 - 100%)
      final valRatio = (categories[i].percentage / 100.0).clamp(0.05, 1.0);
      final valX = center.dx + radius * valRatio * math.cos(angle);
      final valY = center.dy + radius * valRatio * math.sin(angle);
      final pt = Offset(valX, valY);
      vertexPoints.add(pt);

      if (i == 0) {
        valuePath.moveTo(valX, valY);
      } else {
        valuePath.lineTo(valX, valY);
      }

      // Draw Category Label text near outer vertex
      _drawVertexLabel(canvas, categories[i], outerX, outerY, angle);
    }

    valuePath.close();

    // 3. Draw Polygon Fill & Outline
    canvas.drawPath(valuePath, polygonFillPaint);
    canvas.drawPath(valuePath, polygonStrokePaint);

    // 4. Draw Vertex Dots
    for (final pt in vertexPoints) {
      canvas.drawCircle(pt, 5.0, vertexDotPaint);
      canvas.drawCircle(pt, 5.0, vertexDotBorder);
    }
  }

  void _drawVertexLabel(Canvas canvas, RadarCategoryData cat, double x, double y, double angle) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: cat.category,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double offsetX = x - (textPainter.width / 2);
    double offsetY = y - (textPainter.height / 2);

    // Push label slightly outward along the angle vector
    offsetX += 14 * math.cos(angle);
    offsetY += 14 * math.sin(angle);

    textPainter.paint(canvas, Offset(offsetX, offsetY));
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}
