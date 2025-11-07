import 'package:just_audio/just_audio.dart';

String formatDuration(Duration? d) {
  if (d == null) return '--:--';
  final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$mm:$ss';
}
