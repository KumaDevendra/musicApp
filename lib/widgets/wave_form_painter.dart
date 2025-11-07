// lib/widgets/waveform_painter.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Draws a mirrored center waveform made of rounded bars.
/// - samples: normalized values in 0..1 (length can vary)
/// - progress: 0..1 indicates how much of the waveform is "played"
/// - activeColor / inactiveColor: colors for played vs unplayed bars
/// - useGradientForActive: apply a horizontal gradient on active portion
class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double progress; // 0..1
  final Color activeColor;
  final Color inactiveColor;
  final bool useGradientForActive;
  final double barRadius;
  final int barCount; // desired number of bars; if <=0 uses samples.length
  final double gap; // gap between bars

  WaveformPainter({
    required this.samples,
    this.progress = 0.0,
    required this.activeColor,
    required this.inactiveColor,
    this.useGradientForActive = false,
    this.barRadius = 4.0,
    this.barCount = 0,
    this.gap = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final normalized = _normalizedSamples(samples, targetCount: barCount > 0 ? barCount : samples.length);

    final count = normalized.length;
    if (count == 0) return;

    // compute bar widths and spacing so bars + gaps fill width comfortably
    final totalGapWidth = gap * (count - 1);
    final availableWidth = size.width - totalGapWidth;
    final barWidth = (availableWidth / count).clamp(1.0, size.width);

    final centerY = size.height / 2;

    // determine which index is last active by progress
    final activeUntil = (progress.clamp(0.0, 1.0) * count).floor();

    // Paints
    final inactivePaint = Paint()..color = inactiveColor..style = PaintingStyle.fill;
    final activePaint = Paint()..color = activeColor..style = PaintingStyle.fill;

    // Optional gradient shader for active region
    ui.Gradient? activeGradient;
    if (useGradientForActive) {
      activeGradient = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, 0),
        [activeColor.withOpacity(0.95), activeColor.withOpacity(0.6)],
      );
    }

    double x = 0.0;
    for (int i = 0; i < count; i++) {
      final s = normalized[i].clamp(0.0, 1.0);
      // scale the bar to a max height (80% of widget height)
      final maxBarHeight = size.height * 0.9;
      final barHeight = s * maxBarHeight;
      final top = centerY - barHeight / 2;
      final rect = Rect.fromLTWH(x, top, barWidth, barHeight);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(barRadius));

      // choose paint based on whether this bar is in active region
      final paint = i < activeUntil ? (activeGradient != null ? (activePaint..shader = activeGradient) : activePaint) : inactivePaint;

      // draw top part
      canvas.drawRRect(rrect, paint);

      // draw mirrored bottom part (for the center mirror effect)
      final bottomRect = Rect.fromLTWH(x, centerY + (barHeight / 2) - barHeight, barWidth, barHeight);
      final bottomRrect = RRect.fromRectAndRadius(bottomRect, Radius.circular(barRadius));
      canvas.drawRRect(bottomRrect, paint);

      x += barWidth + gap;
    }
  }

  /// Normalize or resample the input samples to the desired length using simple averaging.
  List<double> _normalizedSamples(List<double> input, {required int targetCount}) {
    if (input.isEmpty || targetCount <= 0) return [];

    // clamp targetCount to reasonable size
    final n = targetCount;
    if (input.length == n) {
      return input.map((e) => e.clamp(0.0, 1.0)).toList();
    }

    // simple down/up-sampling by grouping
    final out = List<double>.filled(n, 0.0);
    final bucketSize = input.length / n;

    for (int i = 0; i < n; i++) {
      final start = (i * bucketSize).floor();
      final end = ((i + 1) * bucketSize).ceil().clamp(0, input.length);
      if (start >= input.length) {
        out[i] = input.last.clamp(0.0, 1.0);
        continue;
      }
      final segment = input.sublist(start, end == start ? start + 1 : end);
      final avg = segment.fold<double>(0.0, (p, e) => p + e) / segment.length;
      out[i] = avg.clamp(0.0, 1.0);
    }

    // optional smoothing (simple neighbor average) to reduce harsh jumps
    for (int i = 1; i < out.length - 1; i++) {
      out[i] = (out[i - 1] + out[i] + out[i + 1]) / 3.0;
    }

    return out;
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.barCount != barCount ||
        oldDelegate.gap != gap;
  }
}
