import 'dart:ui';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/screens/pages/library_views/cubit/current_playlist_cubit.dart';
import 'package:vibey/screens/pages/library_views/more_bottomsheet.dart';
import 'package:vibey/screens/pages/library_views/playlist_edit_view.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/playPause_widget.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  final double titleScale = 1.5;

  final double titleFontSize = 16;

  Color _adjustColor(Color color, bool darken, {double amount = 0.1}) {
    final hsl = HSLColor.fromColor(color);
    HSLColor adjustedHsl =
        darken
            ? hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
            : hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    if (!darken && adjustedHsl.lightness < 0.75) {
      adjustedHsl = adjustedHsl.withLightness(0.85);
    }
    return adjustedHsl.toColor();
  }

  List<Color> getFBColor(BuildContext context) {
    // get foreground and background color from current playlist pallete
    Color? color =
        context
            .read<CurrentPlaylistCubit>()
            .getCurrentPlaylistPallete()
            ?.lightVibrantColor
            ?.color;
    Color? bgColor =
        context
            .read<CurrentPlaylistCubit>()
            .getCurrentPlaylistPallete()
            ?.darkMutedColor
            ?.color;
    if (bgColor != null && color != null) {
      //calculate contrast between two color and bgcolor
      final double contrast =
          bgColor.computeLuminance() / color.computeLuminance();
      if (contrast > 0.05) {
        color = _adjustColor(color, false);
        bgColor = _adjustColor(bgColor, true);
      }
      return [color, bgColor];
    }
    return [Colors.white, Colors.black];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
          builder: (context, state) {
            const double maxExtent = 300;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child:
                  (state is! CurrentPlaylistInitial &&
                          state.mediaPlaylist.mediaItems.isNotEmpty)
                      ? CustomScrollView(
                        key: const ValueKey('1'),
                        physics: const BouncingScrollPhysics(),
                        primary: true,
                        slivers: [
                          SliverAppBar(
                            surfaceTintColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              hoverColor: getFBColor(
                                context,
                              )[1].withOpacity(0.3),
                              highlightColor: getFBColor(
                                context,
                              )[0].withOpacity(0.6),
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              onPressed: () {
                                context.pop();
                              },
                            ),
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            floating: false,
                            toolbarHeight: 90,
                            pinned: true,
                            centerTitle: true, // Center the title
                            title: Text(
                              state.mediaPlaylist.playlistName ??
                                  "Playlist", // Playlist title
                              style: Default_Theme.primaryTextStyle.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                                fontSize: 34,
                              ),
                            ),
                          ),

                          // SliverToBoxAdapter with the card layout
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                16,
                              ), // Add padding around the card
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Rounded corners for the card
                                ),
                                elevation: 5, // Elevation for the shadow effect
                                color: Theme.of(context).scaffoldBackgroundColor
                                    .withOpacity(0.9), // Card background color
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Playlist/Album image with square shape and rounded corners
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          32,
                                        ), // Rounded corners for the image
                                        child: Image.network(
                                          formatImgURL(
                                            state
                                                .mediaPlaylist
                                                .mediaItems
                                                .first
                                                .artUri
                                                .toString(),
                                            ImageQuality.high,
                                          ),
                                          width:
                                              120, // Increased width for a larger image
                                          height:
                                              120, // Height matches the width for a square shape
                                          fit:
                                              BoxFit
                                                  .cover, // Make sure the image covers the container
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ), // Space between image and text/buttons

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Album/Playlist details (removed title, as it is in the app bar)
                                            Text(
                                              "${state.mediaPlaylist.isAlbum ? "Album" : "Playlist"} • ${state.mediaPlaylist.mediaItems.length} Songs",
                                              style: Default_Theme
                                                  .secondoryTextStyle
                                                  .merge(
                                                    TextStyle(
                                                      color:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .color
                                                              ?.withOpacity(
                                                                0.8,
                                                              ) ??
                                                          Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                            ),
                                            Text(
                                              "by ${state.mediaPlaylist.artists ?? 'You'}",
                                              style: Default_Theme
                                                  .secondoryTextStyle
                                                  .merge(
                                                    TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color
                                                          ?.withOpacity(0.6),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Control buttons (shuffle, play/pause, more)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Shuffle button
                                                IconButton(
                                                  onPressed: () {
                                                    context
                                                        .read<
                                                          VibeyPlayerCubit
                                                        >()
                                                        .vibeyplayer
                                                        .loadPlaylist(
                                                          MediaPlaylist(
                                                            mediaItems:
                                                                state
                                                                    .mediaPlaylist
                                                                    .mediaItems,
                                                            playlistName:
                                                                state
                                                                    .mediaPlaylist
                                                                    .playlistName,
                                                          ),
                                                          doPlay: true,
                                                          shuffling: true,
                                                        );
                                                  },
                                                  icon: Icon(
                                                    MingCute.shuffle_line,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color
                                                        ?.withOpacity(0.8),
                                                  ),
                                                ),

                                                // Play/Pause button with StreamBuilder to update state
                                                BlocBuilder<
                                                  CurrentPlaylistCubit,
                                                  CurrentPlaylistState
                                                >(
                                                  builder: (context, state) {
                                                    return StreamBuilder<
                                                      String
                                                    >(
                                                      stream:
                                                          context
                                                              .watch<
                                                                VibeyPlayerCubit
                                                              >()
                                                              .vibeyplayer
                                                              .queueTitle,
                                                      builder: (
                                                        context,
                                                        snapshot,
                                                      ) {
                                                        if (snapshot.hasData &&
                                                            snapshot.data ==
                                                                state
                                                                    .mediaPlaylist
                                                                    .playlistName) {
                                                          return StreamBuilder<
                                                            PlayerState
                                                          >(
                                                            stream:
                                                                context
                                                                    .read<
                                                                      VibeyPlayerCubit
                                                                    >()
                                                                    .vibeyplayer
                                                                    .audioPlayer
                                                                    .playerStateStream,
                                                            builder: (
                                                              context,
                                                              snapshot2,
                                                            ) {
                                                              if (snapshot2
                                                                      .hasData &&
                                                                  (snapshot2
                                                                          .data
                                                                          ?.playing ??
                                                                      false)) {
                                                                return PlayPauseButton(
                                                                  onPause:
                                                                      () =>
                                                                          context
                                                                              .read<
                                                                                VibeyPlayerCubit
                                                                              >()
                                                                              .vibeyplayer
                                                                              .pause(),
                                                                  onPlay:
                                                                      () =>
                                                                          context
                                                                              .read<
                                                                                VibeyPlayerCubit
                                                                              >()
                                                                              .vibeyplayer
                                                                              .audioPlayer
                                                                              .play(),
                                                                  isPlaying:
                                                                      true,
                                                                  size: 40,
                                                                );
                                                              } else {
                                                                return PlayPauseButton(
                                                                  onPause:
                                                                      () =>
                                                                          context
                                                                              .read<
                                                                                VibeyPlayerCubit
                                                                              >()
                                                                              .vibeyplayer
                                                                              .pause(),
                                                                  onPlay:
                                                                      () =>
                                                                          context
                                                                              .read<
                                                                                VibeyPlayerCubit
                                                                              >()
                                                                              .vibeyplayer
                                                                              .audioPlayer
                                                                              .play(),
                                                                  isPlaying:
                                                                      false,
                                                                  size: 40,
                                                                );
                                                              }
                                                            },
                                                          );
                                                        } else {
                                                          return PlayPauseButton(
                                                            onPause:
                                                                () =>
                                                                    context
                                                                        .read<
                                                                          VibeyPlayerCubit
                                                                        >()
                                                                        .vibeyplayer
                                                                        .pause(),
                                                            onPlay: () {
                                                              context
                                                                  .read<
                                                                    VibeyPlayerCubit
                                                                  >()
                                                                  .vibeyplayer
                                                                  .loadPlaylist(
                                                                    MediaPlaylist(
                                                                      mediaItems:
                                                                          state
                                                                              .mediaPlaylist
                                                                              .mediaItems,
                                                                      playlistName:
                                                                          state
                                                                              .mediaPlaylist
                                                                              .playlistName,
                                                                    ),
                                                                    doPlay:
                                                                        true,
                                                                  );
                                                            },
                                                            size: 40,
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),

                                                // More options button
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                const PlaylistEditView(),
                                                      ),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.edit_rounded,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color
                                                        ?.withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverPrototypeExtentList.builder(
                            itemBuilder: (context, index) {
                              return SongCardWidget(
                                key: ValueKey(
                                  state.mediaPlaylist.mediaItems[index],
                                ),
                                song: state.mediaPlaylist.mediaItems[index],
                                onTap: () {
                                  if (!listEquals(
                                    context
                                        .read<VibeyPlayerCubit>()
                                        .vibeyplayer
                                        .queue
                                        .value,
                                    state.mediaPlaylist.mediaItems,
                                  )) {
                                    context
                                        .read<VibeyPlayerCubit>()
                                        .vibeyplayer
                                        .loadPlaylist(
                                          MediaPlaylist(
                                            mediaItems:
                                                state.mediaPlaylist.mediaItems,
                                            playlistName:
                                                state
                                                    .mediaPlaylist
                                                    .playlistName,
                                          ),
                                          idx: index,
                                          doPlay: true,
                                        );
                                  } else if (context
                                          .read<VibeyPlayerCubit>()
                                          .vibeyplayer
                                          .currentMedia !=
                                      state.mediaPlaylist.mediaItems[index]) {
                                    context
                                        .read<VibeyPlayerCubit>()
                                        .vibeyplayer
                                        .prepare4play(idx: index, doPlay: true);
                                  }
                                },
                                onOptionsTap: () {
                                  showMoreBottomSheet(
                                    context,
                                    state.mediaPlaylist.mediaItems[index],
                                    onDelete: () {
                                      context
                                          .read<DBCubit>()
                                          .removeMediaFromPlaylist(
                                            state
                                                .mediaPlaylist
                                                .mediaItems[index],
                                            MediaPlaylistDB(
                                              playlistName:
                                                  state
                                                      .mediaPlaylist
                                                      .playlistName,
                                            ),
                                          );
                                    },
                                    showDelete: true,
                                    showSinglePlay: true,
                                  );
                                },
                              );
                            },
                            itemCount: state.mediaPlaylist.mediaItems.length,
                            prototypeItem: SongCardWidget(
                              song: MediaItemModel(
                                id: "prototype",
                                artist: "prototype",
                                title: "prototype",
                              ),
                            ),
                          ),
                        ],
                      )
                      : ((state is CurrentPlaylistInitial ||
                              state is CurrentPlaylistLoading)
                          ? const CustomScrollView(
                            key: ValueKey('2'),
                            slivers: [
                              SliverAppBar(),
                              SliverFillRemaining(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ],
                          )
                          : const CustomScrollView(
                            key: ValueKey('3'),
                            slivers: [
                              SliverAppBar(),
                              SliverFillRemaining(
                                child: Center(
                                  child: SignBoardWidget(
                                    message: "No Songs",
                                    icon: MingCute.playlist_line,
                                  ),
                                ),
                              ),
                            ],
                          )),
            );
          },
        ),
      ),
    );
  }
}
