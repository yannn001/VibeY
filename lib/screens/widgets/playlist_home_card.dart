import 'package:flutter/material.dart';
import 'package:vibey/models/playlist.dart';
import 'package:vibey/theme/default.dart';

class PlaylistHomeCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback? onTap;

  const PlaylistHomeCard({Key? key, required this.playlist, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                playlist.imageURL,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                playlist.name,
                style: Default_Theme.primaryTextStyle.merge(
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                playlist.description ?? '',
                style: Default_Theme.secondoryTextStyle.merge(
                  TextStyle(fontSize: 14, color: Colors.grey),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
