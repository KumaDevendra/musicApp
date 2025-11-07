// // lib/widgets/waveform_widget.dart
// import 'package:flutter/material.dart';
// import 'package:music_showcase/widgets/wave_form_painter.dart';

// typedef SeekCallback = void Function(double relative); // relative 0..1

// class WaveformWidget extends StatefulWidget {
//   /// samples normalized 0..1 (if not normalized - widget will clamp)
//   final List<double> samples;

//   /// playback progress 0..1 (how much is played)
//   final double progress;

//   final Color activeColor;
//   final Color inactiveColor;

//   /// optional: how many bars to render (helps performance). If 0 uses samples.length.
//   final int barCount;

//   /// optional: when user taps on waveform, this callback gives relative position 0..1
//   final SeekCallback? onSeek;

//   /// whether to apply a small gradient to the active region
//   final bool useGradient;

//   const WaveformWidget({
//     Key? key,
//     required this.samples,
//     this.progress = 0.0,
//     this.activeColor = Colors.white,
//     this.inactiveColor = const Color(0x66FFFFFF),
//     this.barCount = 80,
//     this.onSeek,
//     this.useGradient = true,
//   }) : super(key: key);

//   @override
//   State<WaveformWidget> createState() => _WaveformWidgetState();
// }

// class _WaveformWidgetState extends State<WaveformWidget> with SingleTickerProviderStateMixin {
//   // Optional subtle animation to smooth updates
//   late AnimationController _animController;
//   List<double> _displaySamples = [];

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
//       ..addListener(() {
//         // small rebuild to animate if we want; currently just used to trigger repaints
//         setState(() {});
//       });

//     _updateDisplaySamples(widget.samples);
//   }

//   @override
//   void didUpdateWidget(covariant WaveformWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.samples != oldWidget.samples) {
//       // animate when samples change
//       _updateDisplaySamples(widget.samples);
//       _animController.forward(from: 0.0);
//     }
//   }

//   void _updateDisplaySamples(List<double> samples) {
//     // clamp / normalize incoming samples slightly
//     _displaySamples = samples.map((e) => e.clamp(0.0, 1.0)).toList();
//     // if user requested barCount larger than samples, painter will resample
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
//     if (widget.onSeek == null) return;
//     final local = details.localPosition;
//     final rel = (local.dx / constraints.maxWidth).clamp(0.0, 1.0);
//     widget.onSeek!(rel);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       return GestureDetector(
//         onTapDown: (d) => _handleTapDown(d, constraints),
//         child: CustomPaint(
//           size: Size(constraints.maxWidth, 72),
//           painter: WaveformPainter(
//             samples: _displaySamples,
//             progress: widget.progress,
//             activeColor: widget.activeColor,
//             inactiveColor: widget.inactiveColor,
//             useGradientForActive: widget.useGradient,
//             barRadius: 6,
//             barCount: widget.barCount,
//             gap: 3.0,
//           ),
//         ),
//       );
//     });
//   }
// }

// lib/widgets/pulse_wave_widget.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PulseWaveWidget extends StatefulWidget {
  /// Provide the existing AudioPlayer (from your provider)
  final AudioPlayer player;

  /// Number of bars in the pulse (visual density)
  final int barCount;

  /// Height of the widget in px
  final double height;

  /// Optional bar width
  final double barWidth;

  /// Accent color for bars
  final Color color;

  /// If true, tapping the widget toggles play/pause on the provided player
  final bool interactive;

  const PulseWaveWidget({
    Key? key,
    required this.player,
    this.barCount = 20,
    this.height = 100,
    this.barWidth = 5,
    this.color = Colors.orangeAccent,
    this.interactive = false,
  }) : super(key: key);

  @override
  State<PulseWaveWidget> createState() => _PulseWaveWidgetState();
}

class _PulseWaveWidgetState extends State<PulseWaveWidget> {
  late List<double> barHeights;
  Timer? _timer;
  final Random _random = Random();
  StreamSubscription<bool>? _playingSub;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    barHeights = List<double>.generate(widget.barCount, (_) => 6.0);

    // initial playing state
    _isPlaying = widget.player.playing;

    // Listen to player playing stream and start/stop pulse accordingly
    _playingSub = widget.player.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
      if (playing) {
        _startPulse();
      } else {
        _stopPulse();
      }
    });

    // If already playing on mount, start pulse
    if (_isPlaying) _startPulse();
  }

  void _startPulse() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        // generate random heights, scaled to available widget.height
        final maxH = widget.height * 0.9;
        barHeights = List<double>.generate(
          widget.barCount,
          (_) => _random.nextDouble() * maxH * 0.75 + (widget.height * 0.05),
        );
      });
    });
  }

  void _stopPulse() {
    _timer?.cancel();
    setState(() {
      // shrink to minimal height smoothly
      barHeights = List<double>.generate(widget.barCount, (_) => widget.height * 0.05);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playingSub?.cancel();
    super.dispose();
  }

  void _handleTap() async {
    if (!widget.interactive) return;
    try {
      if (widget.player.playing) {
        await widget.player.pause();
      } else {
        await widget.player.play();
      }
    } catch (_) {
      // ignore or handle playback errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.interactive ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (i) {
            final h = (i < barHeights.length) ? barHeights[i] : widget.height * 0.05;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: widget.barWidth,
              height: h,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.barWidth),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.25),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

