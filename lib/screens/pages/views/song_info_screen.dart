import 'package:flutter/material.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:vibey/utils/imgurl_formator.dart';

class SongInfoScreen extends StatelessWidget {
  final MediaItemModel song;
  const SongInfoScreen({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  LoadImageCached(
                    imageUrl: formatImgURL(
                      song.artUri.toString(),
                      ImageQuality.high,
                    ),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: BackButton(
              color: Default_Theme.primaryColor2,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color:
                          Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color?.withOpacity(0.7) ??
                          Colors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.album,
                    "Album",
                    song.album ?? 'Unknown',
                  ),
                  _buildInfoRow(
                    context,
                    Icons.timelapse,
                    "Duration",
                    song.duration != null
                        ? '${song.duration?.inMinutes ?? '00'}:${(song.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                        : "00:00",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                Theme.of(
                  context,
                ).textTheme.bodyMedium!.color?.withOpacity(0.7) ??
                Colors.black.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color?.withOpacity(0.6) ??
                        Colors.black.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
