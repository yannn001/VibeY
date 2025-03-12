import 'package:vibey/models/artist.dart';
import 'package:vibey/screens/pages/views/artist_view.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ArtistCard extends StatelessWidget {
  final ArtistModel artist;
  final String placeholderImageUrl =
      'assets/icons/logo_img.png'; // Path to your placeholder image

  ArtistCard({super.key, required this.artist});

  final ValueNotifier<bool> hovering = ValueNotifier(false);

  void setHovering(bool isHovering) {
    hovering.value = isHovering;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 200,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistView(artist: artist),
              ),
            );
          },
          child: MouseRegion(
            onEnter: (event) => setHovering(true),
            onExit: (event) => setHovering(false),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Check if the artist's image URL is null or empty
                    artist.imageUrl != null && artist.imageUrl!.isNotEmpty
                        ? LoadImageCached(
                          imageUrl: formatImgURL(
                            artist.imageUrl!,
                            ImageQuality.medium,
                          ),
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          placeholderImageUrl, // Use the placeholder image
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                    ValueListenableBuilder(
                      valueListenable: hovering,
                      builder: (context, isHovering, child) {
                        return Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient:
                                  isHovering
                                      ? LinearGradient(
                                        colors: [
                                          Colors.black.withAlpha(179),
                                          Colors.black.withAlpha(77),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                      : null,
                            ),
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isHovering ? 1 : 0,
                                child: const Icon(
                                  MingCute.play_circle_line,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          color: Colors.black.withAlpha(153),
                        ),
                        child: Text(
                          artist.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: Default_Theme.secondoryTextStyleMedium.merge(
                            TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
