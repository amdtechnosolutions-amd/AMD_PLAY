import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/student_evaluation_model.dart';

/// Progress tracking line chart displaying historical performance trends
class EvaluationTrendChart extends StatelessWidget {
  final List<EvaluationTrendItem> trend;
  final double height;

  const EvaluationTrendChart({
    super.key,
    required this.trend,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0x60D4AF37), width: 1.3),
        ),
        child: const Center(
          child: Text(
            'No historical evaluation data yet.',
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
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 22.sp, color: const Color(0xFFD4AF37)),
                  SizedBox(width: 8.w),
                  Text(
                    'Progress Trend',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (trend.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFF10B981), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 12.sp, color: const Color(0xFF047857)),
                      SizedBox(width: 2.w),
                      Text(
                        '${trend.last.overallPercentage.toStringAsFixed(1)}% LATEST',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Custom Paint Canvas for Line Chart
          SizedBox(
            width: double.infinity,
            height: height.h,
            child: CustomPaint(
              painter: _TrendLineChartPainter(trend: trend),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLineChartPainter extends CustomPainter {
  final List<EvaluationTrendItem> trend;

  _TrendLineChartPainter({required this.trend});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;

    final bottomPadding = 28.0;
    final topPadding = 16.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    // Draw horizontal grid lines (0%, 25%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = const Color(0x18000000)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const gridLines = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (final ratio in gridLines) {
      final y = topPadding + chartHeight * (1.0 - ratio);
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final int count = trend.length;
    final double stepX = count > 1 ? chartWidth / (count - 1) : chartWidth / 2;

    final List<Offset> points = [];
    for (int i = 0; i < count; i++) {
      final pct = trend[i].overallPercentage.clamp(0.0, 100.0);
      final x = count > 1 ? i * stepX : chartWidth / 2;
      final y = topPadding + chartHeight * (1.0 - (pct / 100.0));
      points.add(Offset(x, y));
    }

    // 1. Draw Gradient Fill Area beneath the line
    if (points.isNotEmpty) {
      final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }
      fillPath.lineTo(points.last.dx, size.height - bottomPadding);
      fillPath.lineTo(points.first.dx, size.height - bottomPadding);
      fillPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0x50D4AF37),
            const Color(0x05D4AF37),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, topPadding, chartWidth, chartHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, areaPaint);
    }

    // 2. Draw Smooth Bézier Line
    if (points.isNotEmpty) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..color = const Color(0xFFD4AF37)
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(linePath, linePaint);
    }

    // 3. Draw Points, Values and Date Labels
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final item = trend[i];

      // Outer glow circle
      canvas.drawCircle(
        pt,
        6.0,
        Paint()..color = const Color(0x40D4AF37),
      );

      // Inner solid circle
      canvas.drawCircle(
        pt,
        4.0,
        Paint()..color = const Color(0xFF0F172A),
      );

      // White dot center
      canvas.drawCircle(
        pt,
        2.0,
        Paint()..color = Colors.white,
      );

      // Value pill above point
      final valPainter = TextPainter(
        text: TextSpan(
          text: '${item.overallPercentage.toInt()}%',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valPainter.paint(canvas, Offset(pt.dx - (valPainter.width / 2), pt.dy - 16));

      // Date label at the bottom axis
      final dateText = item.date.isNotEmpty ? item.date : '#${i + 1}';
      final datePainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      datePainter.paint(
        canvas,
        Offset(pt.dx - (datePainter.width / 2), size.height - bottomPadding + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLineChartPainter oldDelegate) => true;
}
