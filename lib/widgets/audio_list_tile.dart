import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/audio_list_response.dart';

class AudioListTile extends StatelessWidget {
  final AudioFeed feed;
  final VoidCallback? onTap;

  const AudioListTile({super.key, required this.feed, this.onTap});

  @override
  Widget build(BuildContext context) {
    final audio = feed.audio;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[800],
        backgroundImage: audio != null ? CachedNetworkImageProvider(audio.coverImage) : null,
        child: audio == null ? const Icon(Icons.music_note) : null,
      ),
      title: Text(audio?.title ?? 'Unknown Title'),
      subtitle: Text(feed.userName),
      trailing: const Icon(Icons.play_arrow),
      tileColor: Colors.white.withOpacity(0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
