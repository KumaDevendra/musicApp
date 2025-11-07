// lib/widgets/now_playing_card.dart
import 'package:flutter/material.dart';
import 'package:music_showcase/core/utils/fomat_utils.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/audio_provider.dart';
import '../core/themes/app_theme.dart';


class NowPlayingCard extends StatelessWidget {
  final VoidCallback? onToggleList;
  const NowPlayingCard({super.key, this.onToggleList});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AudioProvider>(context);
    final playing = prov.playing;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Container(
        // shape and gradient similar to screenshot card
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.topOrange.withOpacity(0.95),
              AppTheme.midOrange.withOpacity(0.95),
              AppTheme.deepPurple.withOpacity(0.95),
            ],
            stops: const [0.0, 0.32, 1.0],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // circular cover and title
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.white.withOpacity(0.08), Colors.transparent]),
                ),
                child: ClipOval(
                  child: playing != null
                      ? CachedNetworkImage(
                          imageUrl: playing.coverImage,
                          fit: BoxFit.cover,
                          placeholder: (c, s) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (c, s, e) => Container(color: Colors.grey),
                        )
                      : Image.asset(
                          'assets/images/placeholder_cover.png',
                          fit: BoxFit.cover,
                        ), // replace with placeholder asset or keep a default
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              playing?.title ?? 'Count My Blessings',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              playing != null ? 'Song by ${playing.feedPost}' : 'Song by Enisa',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),

            const SizedBox(height: 16),

            // waveform placeholder row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  // decorative waveform placeholder - you can replace with real waveform later
                  child: Text(
                    playing != null ? formatDuration(prov.player.duration) : '',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // controls (shuffle, play/pause, repeat)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.shuffle, color: Colors.white70),
                  ),
                  const Spacer(),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 28,
                      icon: Icon(prov.player.playing ? Icons.pause : Icons.play_arrow),
                      color: AppTheme.midOrange,
                      onPressed: () {
                        if (playing != null) prov.play(playing);
                      },
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.repeat, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // bottom mini-info with gesture to toggle list
            GestureDetector(
              onTap: onToggleList,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: playing != null ? NetworkImage(playing.coverImage) : null,
                      backgroundColor: Colors.grey[700],
                      child: playing == null ? const Icon(Icons.music_note) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playing?.title ?? 'Count My Blessings',
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            playing != null ? 'Song by ${playing.feedPost}' : 'Song by Enisa',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
