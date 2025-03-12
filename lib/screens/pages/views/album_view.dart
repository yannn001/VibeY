import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibey/modules/album_view/album_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/album.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';

class AlbumView extends StatefulWidget {
  final AlbumModel album;
  const AlbumView({Key? key, required this.album}) : super(key: key);

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  late AlbumCubit albumCubit;

  @override
  void initState() {
    albumCubit = AlbumCubit(
      album: widget.album,
      sourceEngine:
          widget.album.source == 'saavn'
              ? SourceEngine.eng_YTV
              : SourceEngine.eng_YTM,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<AlbumCubit, AlbumState>(
        bloc: albumCubit,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(color: Default_Theme.primaryColor1),
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: widget.album.sourceId,
                        child: LoadImageCached(
                          imageUrl: formatImgURL(
                            widget.album.imageURL,
                            ImageQuality.high,
                          ),
                          fit: BoxFit.cover,
                        ),
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
                              ).scaffoldBackgroundColor.withAlpha(179),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.album.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.album.artists,
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (context
                                        .read<VibeyPlayerCubit>()
                                        .vibeyplayer
                                        .queueTitle
                                        .value !=
                                    widget.album.name) {
                                  context
                                      .read<VibeyPlayerCubit>()
                                      .vibeyplayer
                                      .loadPlaylist(
                                        state.album.playlist,
                                        doPlay: true,
                                        idx: 0,
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
                              label: const Text(
                                "Play",
                                style: TextStyle(
                                  color: Default_Theme.primaryColor01,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[900],
                                iconColor: Default_Theme.accentColor1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (state is AlbumLoaded ||
                        (state.album.songs.isNotEmpty &&
                            state is! AlbumLoading)) {
                      return SongCardWidget(
                        song: state.album.songs[index],
                        onOptionsTap: () {
                          showMoreBottomSheet(
                            context,
                            state.album.songs[index],
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
                                  widget.album.name ||
                              context
                                      .read<VibeyPlayerCubit>()
                                      .vibeyplayer
                                      .currentMedia !=
                                  state.album.songs[index]) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .loadPlaylist(
                                  state.album.playlist,
                                  doPlay: true,
                                  idx: index,
                                );
                          } else if (!context
                              .read<VibeyPlayerCubit>()
                              .vibeyplayer
                              .audioPlayer
                              .playing) {
                            context.read<VibeyPlayerCubit>().vibeyplayer.play();
                          }
                        },
                      );
                    }
                    return null;
                  },
                  childCount:
                      state is AlbumLoaded ? state.album.songs.length : 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
