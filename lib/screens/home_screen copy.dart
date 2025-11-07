// // lib/screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:music_showcase/widgets/wave_form_painter.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// import '../core/providers/audio_provider.dart';
// import '../widgets/audio_list_tile.dart';
// import '../core/themes/app_theme.dart';
// import '../core/utils/fomat_utils.dart'; // note: your util filename

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool showList = false;

//   void toggleList() {
//     setState(() {
//       showList = !showList;
//     });
//   }
// List<double> _dummyWaveform() {
//   // Generate a nice pattern of varying bars (looks real)
//   final samples = <double>[];
//   for (int i = 0; i < 60; i++) {
//     final value = 0.2 + (i % 5) * 0.15 + (i.isEven ? 0.1 : 0.0);
//     samples.add(value.clamp(0.0, 1.0));
//   }
//   return samples;
// }

//   @override
//   Widget build(BuildContext context) {
//     final audioProv = Provider.of<AudioProvider>(context);
//     final prov = audioProv; // same alias used in NowPlayingCard
//     final playing = prov.playing;
//     final theme = Theme.of(context);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           // Background SVG (no gradient)
//           Positioned.fill(
//             child: SvgPicture.asset(
//               'assets/images/Background.svg',
//               fit: BoxFit.cover,
//             ),
//           ),

//           // Foreground content
//           SafeArea(
//             child: Column(
//               children: [
//                 // Top bar
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
//                   child: Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.arrow_back_ios,
//                               size: 18, color: Colors.white),
//                           onPressed: () {},
//                         ),
//                       ),
//                       const Expanded(child: SizedBox()),
//                       Text('Now Playing',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const Expanded(child: SizedBox()),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.queue_music,
//                               size: 20, color: Colors.white),
//                           onPressed: () {},
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // INLINE NowPlaying content (was NowPlayingCard)
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const NeverScrollableScrollPhysics(),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(height: 18),

//                         // circular cover
//                         // circular cover with clean outer orange border
//                         Center(
//                           child: Container(
//                             width: 300,
//                             height: 300,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: AppTheme.midOrange, // your orange color
//                                 width: 8, // border thickness
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppTheme.midOrange
//                                       .withOpacity(0.5), // soft orange glow
//                                   blurRadius: 25,
//                                   spreadRadius: 4,
//                                 ),
//                               ],
//                             ),
//                             child: ClipOval(
//                               child: Container(
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: playing != null
//                                     ? CachedNetworkImage(
//                                         imageUrl: playing.coverImage,
//                                         fit: BoxFit.cover,
//                                         placeholder: (context, url) =>
//                                             const Center(
//                                                 child:
//                                                     CircularProgressIndicator()),
//                                         errorWidget: (context, url, error) =>
//                                             Container(color: Colors.grey),
//                                       )
//                                     : Image.asset(
//                                         'assets/images/placeholder_cover.png',
//                                         fit: BoxFit.cover,
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 90),

//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SvgPicture.asset(
//                               'assets/images/left.svg',
//                               width: 50,
//                               height: 50,
//                               // tint to white so it fits the dark header (remove if SVG has color)
//                               //colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//                               semanticsLabel: 'Left action',
//                             ),
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     playing?.title ?? 'Count My Blessings',
//                                     style: theme.textTheme.titleLarge?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     playing != null
//                                         ? 'Song by ${playing.feedPost}'
//                                         : 'Song by Enisa',
//                                     style: theme.textTheme.bodySmall
//                                         ?.copyWith(color: Colors.white70),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ]),

//                                    SvgPicture.asset(
//                               'assets/images/left.svg',
//                               width: 50,
//                               height: 50,
//                               // tint to white so it fits the dark header (remove if SVG has color)
//                               //colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//                               semanticsLabel: 'Left action',
//                             ),

//                           ],
//                         ),

//                         const SizedBox(
//                             width:
//                                 26), // keeps visual balance with the left icon

//                         const SizedBox(height: 25),

//                         // waveform placeholder
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 28.0),
//                           child: Container(
//                             height: 72,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.04),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Consumer<AudioProvider>(
//                               builder: (context, prov, _) {
//                                 // if (prov.waveformSamples == null) {
//                                 //   return Center(
//                                 //     child: Text(
//                                 //       "Loading waveform...",
//                                 //       style: TextStyle(
//                                 //           color: Colors.white.withOpacity(0.7)),
//                                 //     ),
//                                 //   );
//                                 // }

//                                 // final samples = prov.waveformSamples!;

//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0, vertical: 6),
//                                   child: CustomPaint(
//                                     size: Size(double.infinity, 72),
//                                     painter: WaveformPainter(
//                                       samples: _dummyWaveform(),
//                                       color: Colors.white,
//                                       isCenter: true,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 50),

//                         // controls row
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 34.0),
//                           child: Row(
//                             children: [
//                               IconButton(
//                                 onPressed: () {},
//                                 icon: const Icon(Icons.shuffle,
//                                     color: Colors.white70),
//                               ),
//                               const Spacer(),
//                               Container(
//                                 width: 68,
//                                 height: 68,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.white,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: IconButton(
//                                   iconSize: 28,
//                                   icon: Icon(prov.player.playing
//                                       ? Icons.pause
//                                       : Icons.play_arrow),
//                                   color: AppTheme.midOrange,
//                                   onPressed: () {
//                                     if (playing != null) prov.play(playing);
//                                   },
//                                 ),
//                               ),
//                               const Spacer(),
//                               IconButton(
//                                 onPressed: () {},
//                                 icon: const Icon(Icons.repeat,
//                                     color: Colors.white70),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 40),

//                         // bottom mini-info with toggle
//                         GestureDetector(
//                           onTap: toggleList,
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 25),
//                             margin: const EdgeInsets.only(bottom: 8, top: 4,left: 30,right: 30),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.06),
//                               borderRadius: const BorderRadius.vertical(
//                                   bottom: Radius.circular(28),
//                                   top: Radius.circular(28)),
//                             ),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 30,
//                                   backgroundImage: playing != null
//                                       ? NetworkImage(playing.coverImage)
//                                       : null,
//                                   backgroundColor: Colors.grey[700],
//                                   child: playing == null
//                                       ? const Icon(Icons.music_note)
//                                       : null,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         playing?.title ?? 'Count My Blessings',
//                                         style: theme.textTheme.bodyLarge
//                                             ?.copyWith(color: Colors.white),
//                                       ),
//                                       const SizedBox(height: 2),
//                                       Text(
//                                         playing != null
//                                             ? 'Song by ${playing.feedPost}'
//                                             : 'Song by Enisa',
//                                         style: theme.textTheme.bodySmall
//                                             ?.copyWith(color: Colors.white70),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Icon(
//                                   showList
//                                       ? Icons.keyboard_arrow_down
//                                       : Icons.keyboard_arrow_right,
//                                   color: Colors.white.withOpacity(0.9),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // spacing when list hidden
//                 if (!showList) const SizedBox(height: 20),
//               ],
//             ),
//           ),

//           // SCRIM + dark song list (same behavior)
//           if (showList) ...[
//             Positioned.fill(
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: toggleList,
//                 child: Container(
//                   color: Colors.black.withOpacity(0.45),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               height: MediaQuery.of(context).size.height * 0.45,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white, // solid dark background for list
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                 ),
//                 child: audioProv.loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : audioProv.error != null
//                         ? Center(
//                             child: Text('Error: ${audioProv.error}',
//                                 style: const TextStyle(color: Colors.white70)),
//                           )
//                         : ListView.separated(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 12),
//                             itemCount: audioProv.feeds.length,
//                             separatorBuilder: (_, __) =>
//                                 const SizedBox(height: 8),
//                             itemBuilder: (ctx, i) {
//                               final f = audioProv.feeds[i];
//                               return AudioListTile(
//                                 feed: f,
//                                 onTap: () {
//                                   if (f.audio != null) audioProv.play(f.audio!);
//                                 },
//                               );
//                             },
//                           ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
