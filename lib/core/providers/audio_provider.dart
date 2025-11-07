import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_showcase/core/api/api_services.dart';

import '../models/audio_list_response.dart';

class AudioProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<AudioFeed> feeds = [];
  bool loading = false;
  String? error;
  AudioItem? playing;
  final AudioPlayer player = AudioPlayer();

  AudioProvider() {
    fetch();
    player.playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  get waveformSamples => null;

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final resp = await _api.fetchAudioList();
      feeds = resp.data.results;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> play(AudioItem item) async {
    try {
      if (playing?.audioUrl == item.audioUrl) {
        // toggle
        if (player.playing) {
          await player.pause();
        } else {
          await player.play();
        }
      } else {
        playing = item;
        await player.setUrl(item.audioUrl);
        await player.play();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await player.pause();
    notifyListeners();
  }

  Future<void> stop() async {
    await player.stop();
    playing = null;
    notifyListeners();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> fetchAudios() async {}
}
