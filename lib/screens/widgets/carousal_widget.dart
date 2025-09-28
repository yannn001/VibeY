import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vibey/Repo/JioMusic/saavn_api.dart';
import 'package:vibey/services/vibeyPlayer.dart';
import 'package:vibey/services/audio_service_initializer.dart';
import 'package:vibey/models/JioMusic.dart';
import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/songModel.dart';

// Do NOT create a new Vibeyplayer here; use the global instance via PlayerInitializer

// Keep fetched discovery items to display & play
List<MediaItemModel> _discoveryItems = [];

// imports kept minimal for this widget
class CarouselWidget extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> titles;

  const CarouselWidget({
    Key? key,
    required this.imageUrls,
    required this.titles,
  }) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _current = 0;
  List<String> randomImageUrls = [];
  List<String> randomTitles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiscoverySongs();
  }

  Future<void> _fetchDiscoverySongs() async {
    try {
      // Fetch top searches from SaavnAPI
      final saavnTopSearches = await SaavnAPI().getTopSearches();

      if (saavnTopSearches.isEmpty) {
        throw Exception('No records found from SaavnAPI');
      }

      // Log the raw response for debugging
      debugPrint('SaavnAPI response: $saavnTopSearches');

      // The API returns a list of top query strings. Resolve each to a song.
      final List<String> terms = saavnTopSearches
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.toLowerCase() != 'error')
          .toSet() // de-dup
          .take(12) // limit to avoid too many requests
          .toList();
      final api = SaavnAPI();
      final List<MediaItemModel> items = [];

      // Resolve queries in sequence to keep it simple and avoid rate limits
      for (final term in terms) {
        try {
          final result = await api.querySongsSearch(term, maxResults: 1);
          final List<dynamic> songs = (result['songs'] as List?) ?? const [];
          if (songs.isNotEmpty) {
            final Map map = songs.first as Map;
            var media = fromSaavnSongMap2MediaItem(map);
            final url = media.extras?['url'] as String?;
            // Keep only items that have a playable URL
            if (url != null && url.startsWith('http')) {
              // Normalize artist to avoid null/empty
              String artist = (media.artist ?? '').trim();
              if (artist.toLowerCase() == 'null') artist = '';
              if (artist.isEmpty) {
                // Try multiple sources for artist name
                String candidate = '';
                final dynamic mapArtist = map['artist'];
                if (mapArtist != null && mapArtist.toString().trim().isNotEmpty && mapArtist.toString().toLowerCase() != 'null') {
                  candidate = mapArtist.toString().trim();
                } else if ((map['subtitle']?.toString().trim().isNotEmpty ?? false) && map['subtitle'].toString().toLowerCase() != 'null') {
                  candidate = map['subtitle'].toString().trim();
                } else if (map.containsKey('more_info') && map['more_info'] is Map) {
                  final mi = map['more_info'] as Map;
                  if (mi['music'] != null && mi['music'].toString().trim().isNotEmpty && mi['music'].toString().toLowerCase() != 'null') {
                    candidate = mi['music'].toString().trim();
                  }
                }
                media = MediaItemModel(
                  id: media.id,
                  title: media.title,
                  album: media.album,
                  artUri: media.artUri,
                  artist: candidate.isNotEmpty ? candidate : 'Unknown',
                  extras: media.extras,
                  genre: media.genre,
                  duration: media.duration,
                );
              }
              items.add(media);
            }
          }
        } catch (e) {
          debugPrint('Failed resolving "$term": $e');
        }
      }

      if (items.isEmpty) {
        throw Exception('Could not resolve any top search to a playable song');
      }

      _discoveryItems = items;

      setState(() {
        randomTitles = items.map((m) => m.title).toList();
        randomImageUrls = items.map((m) => (m.artUri?.toString() ?? '')).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching discovery songs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final discDiameter = (size.width * 0.48).clamp(140.0, 260.0);

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: CarouselSlider.builder(
          itemCount: _discoveryItems.length,
          itemBuilder: (context, index, realIndex) {
            final bool isActive = index == _current;
            return CarouselItem(
              imageUrl: randomImageUrls[index].isNotEmpty
                  ? randomImageUrls[index]
                  : 'https://via.placeholder.com/500',
              title: randomTitles[index],
              onTap: () async {
                // Build a small playlist and play the tapped item
                final playlist = MediaPlaylist(
                  mediaItems: _discoveryItems,
                  playlistName: 'Discover',
                );
                final Vibeyplayer vibey = await PlayerInitializer().getMusicPlayer();
                vibey.loadPlaylist(
                  playlist,
                  idx: index,
                  doPlay: true,
                );
              },
              diameter: discDiameter,
              isActive: isActive,
            );
          },
          options: CarouselOptions(
            height: discDiameter + 80, // extra headroom to avoid clipping
            viewportFraction: 0.48,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              setState(() => _current = index);
            },
          ),
        ),
      ),
    );
  }
}

class CarouselItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap; // Tap callback
  final double diameter;
  final bool isActive;

  const CarouselItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
    required this.diameter,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rim + disc (static - no rotation)
                  Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(isActive ? 0.05 : 0.25),
                            BlendMode.darken),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black87,
                        width: diameter * 0.06,
                      ),
                    ),
                  ),

                  // glossy overlay
                  Container(
                    width: diameter * 0.9,
                    height: diameter * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  // spindle hole
                  Container(
                    width: diameter * 0.20,
                    height: diameter * 0.20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade700, width: 1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Flexible(
              child: SizedBox(
                width: diameter * 0.9,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
