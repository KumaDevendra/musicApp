// lib/widgets/waveform_visualizer.dart
// Animated, non-scrolling waveform visualizer (bars pulse in place).
// Supports:
//  - samples: precomputed List<double> (0..1) mapped to current position
//  - amplitudeStream: Stream<double> of live amplitude values (0..1)
//  - positionStream: Stream<Duration> for mapping samples to current playback pos
// If none are provided it falls back to a procedural gentle animation.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WaveformVisualizer extends StatefulWidget {
  /// Optional precomputed samples (values 0..1). If provided the visualizer will
  /// pick a set of amplitudes from this pool based on the current playback position
  /// (from [positionStream]) and display them as in-place bars (no scrolling).
  final List<double>? samples;

  /// Optional live amplitude stream (values 0..1). If provided it will drive the
  /// bar heights in real-time.
  final Stream<double>? amplitudeStream;

  /// Optional stream of playback position (Duration). Used only when [samples]
  /// is provided to map the current playback moment to a window inside samples.
  final Stream<Duration>? positionStream;

  /// Number of vertical bars to draw.
  final int barCount;

  /// Height of the visualizer widget.
  final double height;

  /// Width of each bar.
  final double barWidth;

  /// Gap between bars.
  final double gap;

  /// Foreground bar color.
  final Color barColor;

  /// Background paint color (used for horizontal strips layer).
  final Color backgroundColor;

  /// Number of translucent horizontal strips drawn behind bars.
  final int strips;

  const WaveformVisualizer({
    super.key,
    this.samples,
    this.amplitudeStream,
    this.positionStream,
    this.barCount = 40,
    this.height = 120,
    this.barWidth = 6,
    this.gap = 4,
    this.barColor = Colors.white,
    this.backgroundColor = const Color(0xFF0B0B0B),
    this.strips = 3,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late List<double> _barHeights; // values 0..1
  late AnimationController _anim;
  StreamSubscription<double?>? _ampSub;
  StreamSubscription<Duration?>? _posSub;
  Timer? _procTimer;

  // Smooth target values we interpolate to, to avoid sudden jumps
  late List<double> _targets;

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _barHeights = List<double>.filled(widget.barCount, 0.05);
    _targets = List<double>.filled(widget.barCount, 0.05);

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..addListener(() {
        // interpolate towards target values on each tick
        // Use setState sparingly — animation controller ticks are frequent,
        // but we need to repaint as values change.
        setState(() {
          for (int i = 0; i < _barHeights.length; i++) {
            final a = _barHeights[i];
            final b = _targets[i];
            _barHeights[i] =
                a + (b - a) * Curves.easeOut.transform(_anim.value);
          }
        });
      });

    // amplitude stream subscription
    if (widget.amplitudeStream != null) {
      _ampSub = widget.amplitudeStream!.listen((value) {
        final amp = (value ?? 0.0).clamp(0.0, 1.0);
        _setTargetsFromAmplitude(amp);
      });
    }

    // position stream subscription (used when samples are present)
    if (widget.samples != null && widget.positionStream != null) {
      _posSub = widget.positionStream!.listen((pos) {
        _setTargetsFromSamples(pos ?? Duration.zero);
      });
    }

    // fallback: no inputs -> run procedural gentle animation
    if (widget.samples == null && widget.amplitudeStream == null) {
      _procTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
        _setTargetsProcedural();
      });
    }

    // kick the animation loop
    _anim.repeat(reverse: false);
  }

  void _setTargetsFromAmplitude(double amp) {
    // Map single amplitude to all bars with small random variance so bars
    // look organic but remain in place (not scrolling).
    for (int i = 0; i < _targets.length; i++) {
      final variance = (_rnd.nextDouble() * 0.18) - 0.09; // -0.09 .. 0.09
      final v = (amp + variance).clamp(0.02, 1.0);
      _targets[i] = v;
    }

    // smoothly interpolate
    _anim.forward(from: 0);
  }

  void _setTargetsFromSamples(Duration pos) {
    final samples = widget.samples!;
    if (samples.isEmpty) return;

    // If caller didn't supply a real duration mapping, assume pos relative to samples length.
    // We expect the app to control the mapping of playback -> positionStream so we only
    // need a Duration input here.
    // Map current position to an index in the samples list. We'll pick a window
    // of samples to spread across bars so the bars represent the current moment
    // rather than a scrolling strip.

    // Heuristic: if the provided Duration is zero or tiny, map to start.
    final totalMs = pos.inMilliseconds;
    // Without a known total duration we treat pos as fraction using an assumed length
    // — BUT since we don't have total duration, callers who want precise mapping should
    // pass a positionStream that yields values scaled to their media duration.
    // Here we map pos.inMilliseconds modulo samples length to create movement.
    final frac = (totalMs % 10000) / 10000.0; // loops every 10s if no duration given
    final centerIndex =
        (frac * (samples.length - 1)).round().clamp(0, samples.length - 1);

    final half = (widget.barCount / 2).round();
    var start = (centerIndex - half);
    if (start < 0) start = 0;
    if (start > samples.length - widget.barCount) {
      start = max(0, samples.length - widget.barCount);
    }

    for (int i = 0; i < widget.barCount; i++) {
      final sampleIndex = (start + i).clamp(0, samples.length - 1);
      final s = samples[sampleIndex].clamp(0.0, 1.0);
      // apply mild shaping so small values are visible
      _targets[i] = (0.06 + s * 0.94).clamp(0.02, 1.0);
    }

    _anim.forward(from: 0);
  }

  void _setTargetsProcedural() {
    for (int i = 0; i < _targets.length; i++) {
      // smooth noise: combine sin and random for organic motion
      final base = 0.08 +
          0.4 *
              (0.5 +
                  0.5 *
                      sin((DateTime.now().millisecondsSinceEpoch / 800) + i));
      final jitter = (_rnd.nextDouble() * 0.18) - 0.09;
      _targets[i] = (base + jitter).clamp(0.02, 1.0);
    }
    _anim.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If amplitudeStream changed, resubscribe.
    if (oldWidget.amplitudeStream != widget.amplitudeStream) {
      _ampSub?.cancel();
      if (widget.amplitudeStream != null) {
        _ampSub = widget.amplitudeStream!.listen((value) {
          final amp = (value ?? 0.0).clamp(0.0, 1.0);
          _setTargetsFromAmplitude(amp);
        });
      } else {
        _ampSub = null;
      }
    }

    // If samples/positionStream changed, resubscribe position
    if (oldWidget.positionStream != widget.positionStream ||
        oldWidget.samples != widget.samples) {
      _posSub?.cancel();
      if (widget.samples != null && widget.positionStream != null) {
        _posSub = widget.positionStream!.listen((pos) {
          _setTargetsFromSamples(pos ?? Duration.zero);
        });
      } else {
        _posSub = null;
      }

      // Manage procedural timer if inputs were removed/added
      final needsProcedural =
          widget.samples == null && widget.amplitudeStream == null;
      if (needsProcedural && _procTimer == null) {
        _procTimer =
            Timer.periodic(const Duration(milliseconds: 300), (_) => _setTargetsProcedural());
      } else if (!needsProcedural) {
        _procTimer?.cancel();
        _procTimer = null;
      }
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _ampSub?.cancel();
    _posSub?.cancel();
    _procTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: CustomPaint(
        painter: _WaveformPainter(
          barHeights: _barHeights,
          barWidth: widget.barWidth,
          gap: widget.gap,
          barColor: widget.barColor,
          backgroundColor: widget.backgroundColor,
          strips: widget.strips,
        ),
        size: Size(double.infinity, widget.height),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final double barWidth;
  final double gap;
  final Color barColor;
  final Color backgroundColor;
  final int strips;

  _WaveformPainter({
    required this.barHeights,
    required this.barWidth,
    required this.gap,
    required this.barColor,
    required this.backgroundColor,
    required this.strips,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // draw background
    paint.color = backgroundColor;
    canvas.drawRect(Offset.zero & size, paint);

    // draw horizontal translucent strips
    final stripPaint = Paint()..isAntiAlias = true;
    for (int i = 0; i < strips; i++) {
      final y = size.height * ((i + 1) / (strips + 1));
      stripPaint.color = Colors.white.withOpacity(0.03 + (i * 0.02));
      final rect = Rect.fromLTWH(0, y - 6, size.width, 12);
      canvas.drawRect(rect, stripPaint);
    }

    // draw bars (center-anchored)
    final totalWidth =
        barHeights.length * barWidth + (barHeights.length - 1) * gap;
    double startX = (size.width - totalWidth) / 2.0;

    final barPaint = Paint()
      ..color = barColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (int i = 0; i < barHeights.length; i++) {
      final hFactor = barHeights[i].clamp(0.01, 1.0);
      final barFullHeight = size.height * hFactor;
      final cx = startX + i * (barWidth + gap);

      final rect =
          Rect.fromLTWH(cx, (size.height - barFullHeight) / 2, barWidth, barFullHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rrect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) {
    if (old.barHeights.length != barHeights.length) return true;
    for (int i = 0; i < barHeights.length; i++) {
      if ((old.barHeights[i] - barHeights[i]).abs() > 0.001) return true;
    }
    return false;
  }
}
