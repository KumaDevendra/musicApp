// // lib/core/providers/audio_provider.dart
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:http/http.dart' as http;
// import 'package:music_showcase/core/api/api_services.dart';
// import 'package:music_showcase/core/models/audio_list_response.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:just_waveform/just_waveform.dart';

// class AudioProvider extends ChangeNotifier {
//   final ApiService _api = ApiService();

//   // API data
//   List<AudioFeed> feeds = [];
//   bool loading = false;
//   String? error;

//   // Currently playing item and player
//   AudioItem? playing;
//   final AudioPlayer player = AudioPlayer();

//   // convenience getters for UI
//   Duration get position => player.position;
//   Duration? get duration => player.duration;
//   bool get isPlaying => player.playing;

//   // waveform related
//   Waveform? waveform; // raw waveform object
//   List<double>? waveformSamples; // reduced samples for display

//   AudioProvider() {
//     // fetch initial list
//     fetch();

//     // listen to player streams and notify UI
//     player.playerStateStream.listen((_) => notifyListeners());
//     player.positionStream.listen((_) => notifyListeners());
//     player.durationStream.listen((_) => notifyListeners());
//     // optional: listen for processing state changes for extra UI handling
//     player.processingStateStream.listen((_) => notifyListeners());
//   }

//   // Fetch audio list from API
//   Future<void> fetch() async {
//     loading = true;
//     error = null;
//     notifyListeners();
//     try {
//       final resp = await _api.fetchAudioList();
//       feeds = resp.data.results;
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       loading = false;
//       notifyListeners();
//     }
//   }

//   // Play / toggle play for an AudioItem
//   Future<void> play(AudioItem item) async {
//     try {
//       if (playing?.audioUrl == item.audioUrl) {
//         // toggle
//         if (player.playing) {
//           await player.pause();
//         } else {
//           await player.play();
//         }
//       } else {
//         // switch to new item
//         playing = item;

//         // reset waveform while we prepare
//         waveform = null;
//         waveformSamples = null;
//         notifyListeners();

//         // start generating waveform (async, don't await entire time before setUrl)
//         _generateWaveformFor(item.audioUrl);

//         // set url and play
//         await player.setUrl(item.audioUrl);
//         await player.play();
//       }
//     } catch (e) {
//       error = e.toString();
//       debugPrint('AudioProvider.play error: $e');
//     } finally {
//       notifyListeners();
//     }
//   }

//   // Seek to relative position (0..1) or absolute Duration
//   Future<void> seekRelative(double relative) async {
//     if (player.duration == null) return;
//     final ms = (player.duration!.inMilliseconds * relative).round();
//     await player.seek(Duration(milliseconds: ms));
//     notifyListeners();
//   }

//   Future<void> seek(Duration position) async {
//     await player.seek(position);
//     notifyListeners();
//   }

//   Future<void> pause() async {
//     await player.pause();
//     notifyListeners();
//   }

//   Future<void> stop() async {
//     await player.stop();
//     playing = null;
//     waveform = null;
//     waveformSamples = null;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }

//   Future<void> _generateWaveformFor(String audioUrl) async {
//     try {
//       waveform = null;
//       waveformSamples = null;
//       notifyListeners();

//       final tempDir = await getTemporaryDirectory();
//       final audioFile = File(
//           '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');

//       // download audio
//       final res = await http.get(Uri.parse(audioUrl));
//       if (res.statusCode != 200) {
//         debugPrint('Waveform download failed: ${res.statusCode}');
//         return;
//       }
//       await audioFile.writeAsBytes(res.bodyBytes);

//       // waveform output file
//       final waveOut = File(
//           '${tempDir.path}/temp_wave_${DateTime.now().millisecondsSinceEpoch}.waveform');

//       // Start extraction -> returns Stream<WaveformProgress>
//       final progressStream = JustWaveform.extract(
//         audioInFile: audioFile,
//         waveOutFile: waveOut,
//         // you can tune zoom if you want: zoom: const WaveformZoom.pixelsPerSecond(100),
//       );

//       Waveform? finalWaveform;
//       // listen for progress. Some progress events include a non-null `waveform` when finished.
//       await for (final prog in progressStream) {
//         // optional: you can read prog.progress to update a UI progress indicator (0..1)
//         // debugPrint('Waveform progress: ${(prog.progress * 100).toStringAsFixed(0)}%');
//         if (prog.waveform != null) {
//           finalWaveform = prog.waveform;
//           break; // we have the waveform already
//         }
//       }

//       // If progress events didn't include waveform (depends on version), parse from file
//       if (finalWaveform == null) {
//         try {
//           finalWaveform = await JustWaveform.parse(waveOut);
//         } catch (e) {
//           debugPrint('Failed to parse waveform file: $e');
//         }
//       }

//       if (finalWaveform == null) {
//         // fallback: small placeholder
//         waveform = null;
//         waveformSamples = List<double>.filled(120, 0.02);
//         notifyListeners();
//         return;
//       }

//       waveform = finalWaveform;
//       // `finalWaveform.data` is List<int> of min/max pairs (min,max,min,max,...)
//       final raw = finalWaveform.data;
//       if (raw == null || raw.isEmpty) {
//         waveformSamples = List<double>.filled(120, 0.02);
//         notifyListeners();
//         return;
//       }

//       // Convert min/max pairs to a single amplitude per pixel:
//       // data is pairs: [min0, max0, min1, max1, ...]
//       final List<double> amplitudes = [];
//       for (int i = 0; i < raw.length; i += 2) {
//         final int minv = raw[i];
//         final int maxv = (i + 1 < raw.length) ? raw[i + 1] : raw[i];
//         // take absolute max amplitude in this pixel
//         final double amp =
//             (minv.abs() > maxv.abs() ? minv.abs() : maxv.abs()).toDouble();
//         amplitudes.add(amp);
//       }

//       if (amplitudes.isEmpty) {
//         waveformSamples = List<double>.filled(120, 0.02);
//         notifyListeners();
//         return;
//       }

//       // Normalize amplitudes to 0..1
//       final double maxAmp =
//           amplitudes.fold<double>(0.0, (p, e) => e > p ? e : p);
//       final List<double> normalized = (maxAmp > 0)
//           ? amplitudes.map((e) => (e / maxAmp).clamp(0.0, 1.0)).toList()
//           : amplitudes.map((_) => 0.02).toList();

//       // Reduce or expand to target points
//       const int targetPoints = 120;
//       if (normalized.length == targetPoints) {
//         waveformSamples = normalized;
//       } else if (normalized.length > targetPoints) {
//         final step = (normalized.length / targetPoints)
//             .ceil()
//             .clamp(1, normalized.length);
//         final List<double> reduced = [];
//         for (int i = 0; i < normalized.length; i += step)
//           reduced.add(normalized[i]);
//         // pad if slightly shorter
//         if (reduced.length < targetPoints) {
//           reduced.addAll(
//               List<double>.filled(targetPoints - reduced.length, reduced.last));
//         }
//         waveformSamples = reduced;
//       } else {
//         // fewer samples than target, interpolate / pad
//         final List<double> padded = List<double>.from(normalized);
//         if (padded.isEmpty)
//           padded.addAll(List<double>.filled(targetPoints, 0.02));
//         while (padded.length < targetPoints) {
//           padded.add(padded.last);
//         }
//         waveformSamples = padded;
//       }

//       notifyListeners();
//     } catch (e, st) {
//       debugPrint('Waveform error: $e\n$st');
//       // safe fallback so UI still works
//       waveform = null;
//       waveformSamples ??= List<double>.filled(120, 0.02);
//       notifyListeners();
//     }
//   }
// }
