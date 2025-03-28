import 'package:go_router/go_router.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/modules/playlist_view/online_playlist_cubit.dart';
import 'package:vibey/models/playlist.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class OnlPlaylistView extends StatefulWidget {
  final PlaylistModel playlist;
  final SourceEngine sourceEngine;
  const OnlPlaylistView({
    super.key,
    required this.playlist,
    required this.sourceEngine,
  });

  @override
  State<OnlPlaylistView> createState() => _OnlPlaylistViewState();
}

class _OnlPlaylistViewState extends State<OnlPlaylistView> {
  late OnlPlaylistCubit onlPlaylistCubit;
  @override
  void initState() {
    onlPlaylistCubit = OnlPlaylistCubit(
      playlist: widget.playlist,
      sourceEngine: widget.sourceEngine,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<OnlPlaylistCubit, OnlPlaylistState>(
          bloc: onlPlaylistCubit,
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  surfaceTintColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),

                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  floating: false,
                  toolbarHeight: 90,
                  pinned: true,
                  centerTitle: true, // Center the title
                  title: Text(
                    widget.playlist.name ?? "Playlist", // Playlist title
                    style: Default_Theme.primaryTextStyle.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: 34,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                  ),
                ),
                (state is OnlPlaylistLoaded || state.playlist.songs.isNotEmpty)
                    ? SliverList.builder(
                      itemBuilder: (context, index) {
                        return SongCardWidget(
                          song: state.playlist.songs[index],
                          onOptionsTap: () {
                            showMoreBottomSheet(
                              context,
                              state.playlist.songs[index],
                              showDelete: false,
                              showSinglePlay: true,
                            );
                          },
                          onTap: () {
                            if (context
                                        .read<VibeyPlayerCubit>()
                                        .vibeyplayer
                                        .queueTitle
                                        .value !=
                                    widget.playlist.name ||
                                context
                                        .read<VibeyPlayerCubit>()
                                        .vibeyplayer
                                        .currentMedia !=
                                    state.playlist.songs[index]) {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .loadPlaylist(
                                    state.playlist.playlist,
                                    doPlay: true,
                                    idx: index,
                                  );
                            } else if (!context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .audioPlayer
                                .playing) {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .play();
                            }
                          },
                        );
                      },
                      itemCount: state.playlist.songs.length,
                    )
                    : const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
