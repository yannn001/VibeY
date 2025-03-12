import 'package:flutter/material.dart';

import 'package:vibey/modules/AddToPlaylist/cubit/add_to_playlist_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void showMoreBottomSheet(
  BuildContext context,
  MediaItemModel song, {
  bool showDelete = false,
  bool showSinglePlay = false,
  VoidCallback? onDelete,
}) {
  DBService.getDownloadDB(song).then((value) {
    if (value != null) {
    } else {}
  });
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song Information Card with rounded corners
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SongCardWidget(
                song: song,
                showOptions: false,
                showCopyBtn: false,
                showInfoBtn: true,
              ),
            ),
            // Divider for clean separation
            const Divider(
              thickness: 1,
              color: Default_Theme.accentColor1,
              indent: 30,
              endIndent: 30,
            ),
            // Play Now Button
            if (showSinglePlay)
              _buildBottomSheetItem(
                context,
                icon: Icons.play_circle_fill_rounded,
                label: 'Play Now',
                onTap: () {
                  Navigator.pop(context);
                  context.read<VibeyPlayerCubit>().vibeyplayer.updateQueue([
                    song,
                  ], doPlay: true);
                  SnackbarService.showMessage(
                    "Playing ${song.title}",
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            // Play Next Button
            _buildBottomSheetItem(
              context,
              icon: Icons.queue_play_next_rounded,
              label: 'Play Next',
              onTap: () {
                Navigator.pop(context);
                context.read<VibeyPlayerCubit>().vibeyplayer.addQueueItem(song);
                SnackbarService.showMessage(
                  "Added to Next in Queue",
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            // Add to Queue Button
            _buildBottomSheetItem(
              context,
              icon: Icons.queue_music_rounded,
              label: 'Add to Queue',
              onTap: () {
                Navigator.pop(context);
                context.read<VibeyPlayerCubit>().vibeyplayer.addQueueItem(song);
                SnackbarService.showMessage(
                  "Added to Queue",
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            // Add to Playlist Button
            _buildBottomSheetItem(
              context,
              customIcon: Image.asset(
                "assets/icons/add_play_icn.png",
                color: Theme.of(context).textTheme.bodyMedium!.color,
                height: 24.0,
                width: 24.0,
              ),
              label: 'Add to Playlist',
              onTap: () {
                Navigator.pop(context);
                context.read<AddToPlaylistCubit>().setMediaItemModel(song);
                context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
              },
            ),
            // Add to Favorites Button
            _buildBottomSheetItem(
              context,
              customIcon: Image.asset(
                "assets/icons/add_fav_icn.png",
                color: Theme.of(context).textTheme.bodyMedium!.color,
                height: 24.0,
                width: 24.0,
              ),
              label: 'Add to Favorites',
              onTap: () {
                Navigator.pop(context);
                context.read<DBCubit>().addMediaItemToPlaylist(
                  song,
                  MediaPlaylistDB(playlistName: "Your Likes"),
                );
              },
            ),

            // Delete Button (if visible)
            if (showDelete)
              _buildBottomSheetItem(
                context,
                icon: Icons.delete_rounded,
                label: 'Delete',
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete();
                },
              ),
          ],
        ),
      );
    },
  );
}

Widget _buildBottomSheetItem(
  BuildContext context, {
  IconData? icon,
  Image? customIcon,
  required String label,
  required VoidCallback onTap,
  Color? iconColor, // Add an optional iconColor parameter
}) {
  return ListTile(
    leading:
        customIcon ??
        Icon(
          icon,
          color:
              iconColor ??
              Theme.of(
                context,
              ).textTheme.bodyMedium!.color, // Apply iconColor if provided
          size: 24,
        ),
    title: Text(
      label,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium!.color,
        fontFamily: "Unageo",
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: Colors.grey[900],
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    hoverColor: Colors.grey[800],
    selectedTileColor: Colors.grey[850],
  );
}
