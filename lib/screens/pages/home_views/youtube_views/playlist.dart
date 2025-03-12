// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:core';
import 'dart:developer';
import 'package:vibey/modules/connectivity/cubit/connectivity_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/Yt_Music.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/models/Yt_Video.dart';
import 'package:vibey/Repo/Youtube/youtube_api.dart';
import 'package:vibey/Repo/Youtube/yt_music_api.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:responsive_framework/responsive_framework.dart';

class YoutubePlaylist extends StatefulWidget {
  final String imgPath;
  final String title;
  final String subtitle;
  final String type;
  final String id;
  const YoutubePlaylist({
    Key? key,
    required this.imgPath,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.id,
  }) : super(key: key);

  @override
  State<YoutubePlaylist> createState() => _YoutubePlaylistState();
}

class _YoutubePlaylistState extends State<YoutubePlaylist> {
  late Future<Map<dynamic, dynamic>> data;
  late List<Map<dynamic, dynamic>> items;
  late List<MediaItemModel> mediaitems;

  Future<void> _loadData() async {
    final res = await data;
    // log(res.toString(), name: "YoutubePlaylist");
    items = res["songs"] as List<Map<dynamic, dynamic>>;
    mediaitems = fromYtSongMapList2MediaItemList(items);
    // for (var i = 0; i < items.length; i++) {
    //   mediaitems[i].artUri = Uri.parse((items[i]["image"] as String));
    // }
  }

  Future<MediaItemModel?> fetchSong(String id, String imgUrl) async {
    log("Fetching: $id", name: "YoutubePlaylist");
    final song = await YouTubeServices().formatVideoFromId(
      id: id.replaceAll("youtube", ""),
    );
    if (song != null) {
      return fromYtVidSongMap2MediaItem(song)..artUri = Uri.parse(imgUrl);
    }
    return null;
  }

  @override
  void initState() {
    data = YtMusicService().getPlaylistDetails(
      widget.id.replaceAll("youtube", ""),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Default_Theme.primaryColor2.withOpacity(0.1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child:
                state == ConnectivityState.disconnected
                    ? const Center(
                      child: SignBoardWidget(
                        message:
                            "No internet connection\nPlease connect to the internet.",
                        icon: MingCute.wifi_off_line,
                      ),
                    )
                    : FutureBuilder(
                      future: _loadData(),
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 700),
                          child:
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? const Center(
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : snapshot.hasError
                                  ? CustomScrollView(
                                    slivers: [
                                      SliverAppBar(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                        surfaceTintColor:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                      ),
                                      SliverFillRemaining(
                                        child: Center(
                                          child: SignBoardWidget(
                                            message: "Error while loading",
                                            icon: MingCute.loading_line,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : CustomScrollView(
                                    slivers: [
                                      SliverAppBar(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                        surfaceTintColor:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,

                                        floating: false,
                                        pinned: true,
                                      ),
                                      SliverToBoxAdapter(
                                        child: Card(
                                          color: Colors.grey[900],
                                          margin: const EdgeInsets.all(16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: SizedBox.square(
                                                        dimension:
                                                            ResponsiveBreakpoints.of(
                                                                  context,
                                                                ).isMobile
                                                                ? MediaQuery.of(
                                                                      context,
                                                                    ).size.height *
                                                                    0.18
                                                                : MediaQuery.of(
                                                                      context,
                                                                    ).size.width *
                                                                    0.12,
                                                        child: LoadImageCached(
                                                          imageUrl:
                                                              formatImgURL(
                                                                widget.imgPath,
                                                                ImageQuality
                                                                    .low,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            widget.title,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Theme.of(
                                                                  context,
                                                                )
                                                                .textTheme
                                                                .headlineSmall
                                                                ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Theme.of(
                                                                        context,
                                                                      ).scaffoldBackgroundColor,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            widget.subtitle,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Theme.of(
                                                                  context,
                                                                )
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  color: Default_Theme
                                                                      .primaryColor2
                                                                      .withOpacity(
                                                                        0.8,
                                                                      ),
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            (widget.type ==
                                                                    'playlist')
                                                                ? 'Playlist'
                                                                : 'Album',
                                                            style: Theme.of(
                                                                  context,
                                                                )
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color: Default_Theme
                                                                      .accentColor1light
                                                                      .withOpacity(
                                                                        0.8,
                                                                      ),
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    _buildActionButton(
                                                      icon:
                                                          MingCute.shuffle_fill,
                                                      label: "Shuffle",
                                                      onPressed: () {
                                                        SnackbarService.showMessage(
                                                          "Shuffling & Playing All",
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        );
                                                        context
                                                            .read<
                                                              VibeyPlayerCubit
                                                            >()
                                                            .vibeyplayer
                                                            .loadPlaylist(
                                                              MediaPlaylist(
                                                                mediaItems:
                                                                    mediaitems,
                                                                playlistName:
                                                                    widget
                                                                        .title,
                                                              ),
                                                              doPlay: true,
                                                              shuffling: true,
                                                            );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    StreamBuilder<String>(
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
                                                        final bool
                                                        isCurrentPlaylist =
                                                            snapshot.hasData &&
                                                            snapshot.data ==
                                                                widget.title;
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
                                                            final bool
                                                            isPlaying =
                                                                snapshot2
                                                                    .hasData &&
                                                                (snapshot2
                                                                        .data
                                                                        ?.playing ??
                                                                    false);
                                                            return _buildActionButton(
                                                              icon:
                                                                  isPlaying &&
                                                                          isCurrentPlaylist
                                                                      ? Icons
                                                                          .pause
                                                                      : Icons
                                                                          .play_arrow,
                                                              label:
                                                                  isPlaying &&
                                                                          isCurrentPlaylist
                                                                      ? "Pause"
                                                                      : "Play All",
                                                              onPressed: () {
                                                                if (isCurrentPlaylist) {
                                                                  isPlaying
                                                                      ? context
                                                                          .read<
                                                                            VibeyPlayerCubit
                                                                          >()
                                                                          .vibeyplayer
                                                                          .pause()
                                                                      : context
                                                                          .read<
                                                                            VibeyPlayerCubit
                                                                          >()
                                                                          .vibeyplayer
                                                                          .play();
                                                                } else {
                                                                  context
                                                                      .read<
                                                                        VibeyPlayerCubit
                                                                      >()
                                                                      .vibeyplayer
                                                                      .loadPlaylist(
                                                                        MediaPlaylist(
                                                                          mediaItems:
                                                                              mediaitems,
                                                                          playlistName:
                                                                              widget.title,
                                                                        ),
                                                                      );
                                                                  context
                                                                      .read<
                                                                        VibeyPlayerCubit
                                                                      >()
                                                                      .vibeyplayer
                                                                      .play();
                                                                }
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _buildActionButton(
                                                      icon:
                                                          FontAwesome
                                                              .square_plus,
                                                      label: "",
                                                      onPressed: () async {
                                                        SnackbarService.showMessage(
                                                          "Adding to Library",
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        );
                                                        await Future.forEach(
                                                          mediaitems,
                                                          (element) {
                                                            DBService.addMediaItem(
                                                              MediaItem2MediaItemDB(
                                                                element,
                                                              ),
                                                              widget.title,
                                                            );
                                                          },
                                                        );
                                                        SnackbarService.showMessage(
                                                          "Added to Library",
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 3,
                                        ),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate((
                                            context,
                                            index,
                                          ) {
                                            return SongCardWidget(
                                              song: mediaitems[index],
                                              isWide: true,
                                              onOptionsTap: () {
                                                showMoreBottomSheet(
                                                  context,
                                                  mediaitems[index],
                                                  showSinglePlay: true,
                                                );
                                              },
                                              onTap: () {
                                                if (!listEquals(
                                                  context
                                                      .read<VibeyPlayerCubit>()
                                                      .vibeyplayer
                                                      .queue
                                                      .value,
                                                  mediaitems,
                                                )) {
                                                  context
                                                      .read<VibeyPlayerCubit>()
                                                      .vibeyplayer
                                                      .loadPlaylist(
                                                        MediaPlaylist(
                                                          mediaItems:
                                                              mediaitems,
                                                          playlistName:
                                                              widget.title,
                                                        ),
                                                        idx: index,
                                                        doPlay: true,
                                                      );
                                                } else if (context
                                                        .read<
                                                          VibeyPlayerCubit
                                                        >()
                                                        .vibeyplayer
                                                        .currentMedia !=
                                                    mediaitems[index]) {
                                                  context
                                                      .read<VibeyPlayerCubit>()
                                                      .vibeyplayer
                                                      .prepare4play(
                                                        idx: index,
                                                        doPlay: true,
                                                      );
                                                }
                                              },
                                            );
                                          }, childCount: items.length),
                                        ),
                                      ),
                                    ],
                                  ),
                        );
                        // }
                      },
                    ),
          );
        },
      ),
    );
  }
}
