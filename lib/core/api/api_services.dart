import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audio_list_response.dart';

class ApiService {
  static const String base = 'https://gaongram.com';
  static const String endpoint = '/api/v1/test/audio-lists/';

  Future<AudioListResponse> fetchAudioList({String? url}) async {
    final uri = Uri.parse(url ?? '$base$endpoint');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return AudioListResponse.fromJson(json);
    } else {
      throw Exception('Failed to load audios (${res.statusCode})');
    }
  }
}
