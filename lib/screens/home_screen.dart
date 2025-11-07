// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_showcase/widgets/pulse_wave_widgets.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/providers/audio_provider.dart';
import '../widgets/audio_list_tile.dart';
import '../core/themes/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showList = false;
  bool isRepeat = false;
  bool isShuffle = false;

  void toggleList() {
    setState(() {
      showList = !showList;
    });
  }

  Future<void> _refreshAudios() async {
    await Provider.of<AudioProvider>(context, listen: false).fetchAudios();
  }

  @override
  Widget build(BuildContext context) {
    final audioProv = Provider.of<AudioProvider>(context);
    final prov = audioProv; // same alias used in NowPlayingCard
    final playing = prov.playing;
    final theme = Theme.of(context);

    // Responsive sizing based on available height
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;
    final safeBottom = media.padding.bottom;
    final height = media.size.height - safeTop - safeBottom;
    final width = media.size.width;

    // Sizes derived from height so it adapts on small / large screens
    final coverSize = (height * 0.33).clamp(180.0, 340.0);
    final topPadding = (height * 0.02).clamp(8.0, 20.0);
    final titleFontSize = (height * 0.025).clamp(18.0, 26.0);
    final subtitleFontSize = (height * 0.015).clamp(12.0, 16.0);
    final waveHeight = (height * 0.12).clamp(60.0, 140.0);
    final miniInfoHeight = (height * 0.12).clamp(64.0, 110.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background SVG (no gradient)
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/Background.svg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: topPadding),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              size: 18, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        'Now Playing',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                      ),
                      const Expanded(child: SizedBox()),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.queue_music,
                              size: 20, color: Colors.white),
                          onPressed:
                              toggleList, // 👈 open/close the bottom list
                        ),
                      ),
                    ],
                  ),
                ),

                // Main static non-scrollable area
                // Use Expanded to fill remaining space and make internal parts size with layout
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 6),
                    child: Column(
                      children: [
                        // cover
                        SizedBox(height: 8),
                        Center(
                          child: Container(
                            width: coverSize,
                            height: coverSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.midOrange,
                                width: 6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.midOrange.withOpacity(0.5),
                                  blurRadius: 25,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: playing != null
                                    ? CachedNetworkImage(
                                        imageUrl: playing.coverImage,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            Container(color: Colors.grey),
                                      )
                                    : Image.asset(
                                        'assets/images/default.avif',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // small spacing between cover and title
                        SizedBox(height: (height * 0.03).clamp(10.0, 32.0)),

                        // Title & subtitle row with side icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/images/left.svg',
                              width: width * 0.12,
                              height: width * 0.12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    playing?.title ?? 'Count My Blessings',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: titleFontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    playing != null
                                        ? 'Song by ${playing.feedPost}'
                                        : 'Song by Enisa',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                        fontSize: subtitleFontSize),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/images/right2.svg',
                              width: width * 0.12,
                              height: width * 0.12,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Pulse Wave (non-interactive)
                        SizedBox(
                          height: waveHeight,
                          child: PulseWaveWidget(
                            player: prov.player,
                            barCount: 20,
                            height: waveHeight,
                            barWidth: 5,
                            color: AppTheme.midOrange,
                            interactive: false,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Controls row (shuffle, back10, play, forward10, repeat)
                        // 🎵 Player Controls Row (Updated with working Repeat)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Shuffle button
                              // 🔀 Shuffle Button
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isShuffle = !isShuffle;
                                  });
                                  await prov.player
                                      .setShuffleModeEnabled(isShuffle);
                                },
                                icon: Icon(
                                  Icons.shuffle,
                                  color: isShuffle
                                      ? AppTheme.midOrange
                                      : Colors.white70,
                                ),
                              ),

                              const Spacer(),

                              // 10s Backward
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  onPressed: () {
                                    if (prov.player.position >
                                        const Duration(seconds: 10)) {
                                      prov.player.seek(prov.player.position -
                                          const Duration(seconds: 10));
                                    } else {
                                      prov.player.seek(Duration.zero);
                                    }
                                  },
                                  icon: const Icon(Icons.replay_10,
                                      color: Colors.white),
                                  iconSize: 30,
                                ),
                              ),

                              const SizedBox(width: 6),

                              // Play / Pause
                              Container(
                                width: 68,
                                height: 68,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF2B324),
                                      Color(0xFFF36C24),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  iconSize: 34,
                                  icon: Icon(
                                    prov.player.playing
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                  color: Colors.white,
                                  onPressed: () {
                                    if (playing != null) prov.play(playing);
                                  },
                                ),
                              ),

                              const SizedBox(width: 6),

                              // 10s Forward
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  onPressed: () {
                                    final current = prov.player.position;
                                    final duration =
                                        prov.player.duration ?? Duration.zero;
                                    final newPosition =
                                        current + const Duration(seconds: 10);
                                    if (newPosition < duration) {
                                      prov.player.seek(newPosition);
                                    } else {
                                      prov.player.seek(duration);
                                    }
                                  },
                                  icon: const Icon(Icons.forward_10,
                                      color: Colors.white),
                                  iconSize: 30,
                                ),
                              ),

                              const Spacer(),

                              // 🔁 Repeat Button
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isRepeat = !isRepeat;
                                  });
                                  // Update repeat mode on player
                                  await prov.player.setLoopMode(
                                      isRepeat ? LoopMode.one : LoopMode.off);
                                },
                                icon: Icon(
                                  isRepeat ? Icons.repeat_one : Icons.repeat,
                                  color: isRepeat
                                      ? AppTheme.midOrange
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Bottom mini-info with toggle (fixed height)
                        GestureDetector(
                          //onTap: toggleList,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            margin: const EdgeInsets.only(
                              left: 10, // 👈 add left margin
                              right: 10, // 👈 add right margin
                              top: 4,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(28),
                                top: Radius.circular(28),
                              ),
                            ),
                            child: SizedBox(
                              height: miniInfoHeight,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: (miniInfoHeight * 0.35)
                                        .clamp(20.0, 36.0),
                                    backgroundImage: playing != null
                                        ? NetworkImage(playing.coverImage)
                                        : null,
                                    backgroundColor: Colors.grey[700],
                                    child: playing == null
                                        ? const Icon(Icons.music_note)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          playing?.title ??
                                              'Count My Blessings',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          playing != null
                                              ? 'Song by ${playing.feedPost}'
                                              : 'Song by Enisa',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: Colors.white70),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      final list = audioProv.feeds;
                                      final current = audioProv.playing;

                                      if (list.isEmpty) return;

                                      // find current song index
                                      final currentIndex = current != null
                                          ? list.indexWhere(
                                              (f) => f.audio?.id == current.id)
                                          : -1;

                                      // move to next song (loop to start if at end)
                                      int nextIndex =
                                          (currentIndex + 1) % list.length;

                                      final nextFeed = list[nextIndex];
                                      if (nextFeed.audio != null) {
                                        audioProv.play(nextFeed.audio!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SCRIM + song list overlay (unchanged behavior)
          if (showList) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: toggleList,
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: audioProv.loading
                    ? const Center(child: CircularProgressIndicator())
                    : audioProv.error != null
                        ? Center(
                            child: Text('Error: ${audioProv.error}',
                                style: const TextStyle(color: Colors.white70)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            itemCount: audioProv.feeds.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final f = audioProv.feeds[i];
                              return AudioListTile(
                                feed: f,
                                onTap: () {
                                  if (f.audio != null) audioProv.play(f.audio!);
                                  // close list after selecting
                                  setState(() => showList = false);
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
