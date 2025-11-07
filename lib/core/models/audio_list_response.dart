class AudioListResponse {
  final bool success;
  final String message;
  final AudioListData data;

  AudioListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AudioListResponse.fromJson(Map<String, dynamic> json) {
    return AudioListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AudioListData.fromJson(json['data'] ?? {}),
    );
  }
}

class AudioListData {
  final int count;
  final String? next;
  final String? previous;
  final List<AudioFeed> results;

  AudioListData({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory AudioListData.fromJson(Map<String, dynamic> json) {
    return AudioListData(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((e) => AudioFeed.fromJson(e))
          .toList(),
    );
  }
}

class AudioFeed {
  final int id;
  final String userName;
  final String? profileImage;
  final AudioItem? audio;

  AudioFeed({
    required this.id,
    required this.userName,
    this.profileImage,
    this.audio,
  });

  factory AudioFeed.fromJson(Map<String, dynamic> json) {
    return AudioFeed(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      profileImage: json['profile_image'],
      audio: json['audio'] != null ? AudioItem.fromJson(json['audio']) : null,
    );
  }
}

class AudioItem {
  final int id;
  final int feedPost;
  final String title;
  final String audioUrl;
  final String coverImage;

  AudioItem({
    required this.id,
    required this.feedPost,
    required this.title,
    required this.audioUrl,
    required this.coverImage,
  });

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      id: json['id'] ?? 0,
      feedPost: json['feed_post'] ?? 0,
      title: json['title'] ?? '',
      audioUrl: json['audio'] ?? '',
      coverImage: json['cover_image'] ?? '',
    );
  }
}
