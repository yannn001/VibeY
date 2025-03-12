import 'package:vibey/modules/artist_view/artist_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/artist.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/pages/views/album_view.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ArtistView extends StatefulWidget {
  final ArtistModel artist;

  const ArtistView({super.key, required this.artist});

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  late ArtistCubit artistCubit;

  @override
  void initState() {
    artistCubit = ArtistCubit(
      artist: widget.artist,
      sourceEngine:
          widget.artist.source == 'saavn'
              ? SourceEngine.eng_YTV
              : SourceEngine.eng_YTM,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<ArtistCubit, ArtistState>(
          bloc: artistCubit,
          builder: (context, state) {
            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder:
                    (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        expandedHeight:
                            ResponsiveBreakpoints.of(context).isMobile
                                ? 240
                                : 280,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            return FlexibleSpaceBar(
                              background: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withAlpha(179) ??
                                          Colors.black.withAlpha(179),
                                      Colors.black.withAlpha(179),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: widget.artist.sourceId,
                                        child: ClipOval(
                                          child: LoadImageCached(
                                            imageUrl: formatImgURL(
                                              widget.artist.imageUrl,
                                              ImageQuality.medium,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.artist.name,
                                              maxLines: 2,
                                              style: Default_Theme
                                                  .secondoryTextStyleMedium
                                                  .merge(
                                                    TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            ),
                                            if (state.artist.description !=
                                                    null &&
                                                state
                                                    .artist
                                                    .description!
                                                    .isNotEmpty)
                                              Text(
                                                state.artist.description ?? "",
                                                style: Default_Theme
                                                    .secondoryTextStyle
                                                    .merge(
                                                      TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white70,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                              ),
                                            const SizedBox(height: 8),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  OutlinedButton.icon(
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.grey[900],
                                                      foregroundColor:
                                                          Theme.of(
                                                            context,
                                                          ).scaffoldBackgroundColor,
                                                      side: BorderSide.none,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      if (context
                                                              .read<
                                                                VibeyPlayerCubit
                                                              >()
                                                              .vibeyplayer
                                                              .queueTitle
                                                              .value !=
                                                          widget.artist.name) {
                                                        context
                                                            .read<
                                                              VibeyPlayerCubit
                                                            >()
                                                            .vibeyplayer
                                                            .loadPlaylist(
                                                              state
                                                                  .artist
                                                                  .playlist,
                                                              doPlay: true,
                                                              idx: 0,
                                                            );
                                                      } else if (!context
                                                          .read<
                                                            VibeyPlayerCubit
                                                          >()
                                                          .vibeyplayer
                                                          .audioPlayer
                                                          .playing) {
                                                        context
                                                            .read<
                                                              VibeyPlayerCubit
                                                            >()
                                                            .vibeyplayer
                                                            .play();
                                                      }
                                                    },
                                                    label: const Text("Play"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: TabBar(
                          labelColor: Default_Theme.accentColor1,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Default_Theme.accentColor1,
                          tabs: const [
                            Tab(text: "Top Songs"),
                            Tab(text: "Top Albums"),
                          ],
                        ),
                      ),
                    ],
                body:
                    (state is ArtistLoaded || state.artist.songs.isNotEmpty)
                        ? TabBarView(
                          children: [
                            state.artist.songs.isEmpty
                                ? const SignBoardWidget(
                                  message: "Not found",
                                  icon: Icons.hourglass_empty_rounded,
                                )
                                : ListView.builder(
                                  itemCount: state.artist.songs.length,
                                  itemBuilder: (context, index) {
                                    return SongCardWidget(
                                      song: state.artist.songs[index],
                                      onOptionsTap: () {
                                        showMoreBottomSheet(
                                          context,
                                          state.artist.songs[index],
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
                                                widget.artist.name ||
                                            context
                                                    .read<VibeyPlayerCubit>()
                                                    .vibeyplayer
                                                    .currentMedia !=
                                                state.artist.songs[index]) {
                                          context
                                              .read<VibeyPlayerCubit>()
                                              .vibeyplayer
                                              .loadPlaylist(
                                                state.artist.playlist,
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
                                ),
                            state.artist.albums.isEmpty
                                ? const SignBoardWidget(
                                  message: "Not found",
                                  icon: Icons.hourglass_empty_rounded,
                                )
                                : ListView.builder(
                                  itemCount: state.artist.albums.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => AlbumView(
                                                    album:
                                                        state
                                                            .artist
                                                            .albums[index],
                                                  ),
                                            ),
                                          );
                                        },
                                        leading: Hero(
                                          tag:
                                              state
                                                  .artist
                                                  .albums[index]
                                                  .sourceId,
                                          child: LoadImageCached(
                                            imageUrl:
                                                state
                                                    .artist
                                                    .albums[index]
                                                    .imageURL,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Text(
                                          state.artist.albums[index].name,
                                          style: Default_Theme
                                              .secondoryTextStyleMedium
                                              .merge(
                                                TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor
                                                      .withAlpha(204),
                                                ),
                                              ),
                                        ),
                                        subtitle: Text(
                                          state.artist.albums[index].artists,
                                          style: Default_Theme
                                              .secondoryTextStyle
                                              .merge(
                                                TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor
                                                      .withAlpha(128),
                                                ),
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ],
                        )
                        : const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }
}
