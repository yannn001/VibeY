import 'dart:ui';

import 'package:vibey/modules/AddToPlaylist/cubit/add_to_playlist_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/modules/mini_player/mini_player_bloc.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            const begin = Offset(0.0, 2.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            final offsetAnimation = curvedAnimation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          child: switch (state) {
            MiniPlayerInitial() => const SizedBox(),
            MiniPlayerCompleted() => MiniPlayerCard(
              state: state,
              isCompleted: true,
            ),
            MiniPlayerWorking() => MiniPlayerCard(
              state: state,
              isProcessing: state.isBuffering,
            ),
            MiniPlayerError() => const SizedBox(),
            MiniPlayerProcessing() => MiniPlayerCard(
              state: state,
              isProcessing: true,
            ),
          },
        );
      },
    );
  }
}

class MiniPlayerCard extends StatelessWidget {
  final MiniPlayerState state;
  final bool isCompleted;
  final bool isProcessing;

  const MiniPlayerCard({
    super.key,
    required this.state,
    this.isCompleted = false,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final textColor = Default_Theme.primaryColor1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(GlobalStrConsts.playerScreen);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 78,
              child: Stack(
                children: [
                  // Background: album art + blur
                  Positioned.fill(
                    child: LoadImageCached(
                      imageUrl: formatImgURL(
                        state.song.artUri.toString(),
                        ImageQuality.low,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 16, sigmaX: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.40),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content row
                  Positioned.fill(
                    child: Row(
                      children: [
                        // Artwork
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LoadImageCached(
                                imageUrl: formatImgURL(
                                  state.song.artUri.toString(),
                                  ImageQuality.low,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Title + artist
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Default_Theme.secondoryTextStyle.merge(
                                  TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.song.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Default_Theme.secondoryTextStyle.merge(
                                  TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withValues(alpha: 0.72),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add to playlist
                        IconButton(
                          onPressed: () {
                            context.read<AddToPlaylistCubit>().setMediaItemModel(
                                  mediaItem2MediaItemModel(state.song),
                                );
                            context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
                          },
                          icon: const Icon(
                            FontAwesome.plus_solid,
                            size: 22,
                            color: Default_Theme.primaryColor01,
                          ),
                        ),

                        // Previous (Desktop only)
                        if (isDesktop)
                          IconButton(
                            icon: const Icon(
                              FontAwesome.backward_step_solid,
                              size: 24,
                              color: Default_Theme.primaryColor01,
                            ),
                            onPressed: () {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .skipToPrevious();
                            },
                          ),

                        // Play/Pause or Loader or Rewind
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: (state.isBuffering || isProcessing)
                              ? const SizedBox.square(
                                  dimension: 26,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Default_Theme.primaryColor1,
                                    ),
                                  ),
                                )
                              : (isCompleted
                                  ? IconButton(
                                      onPressed: () {
                                        context
                                            .read<VibeyPlayerCubit>()
                                            .vibeyplayer
                                            .rewind();
                                      },
                                      icon: const Icon(
                                        FontAwesome.rotate_right_solid,
                                        color: Default_Theme.primaryColor01,
                                        size: 22,
                                      ),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        state.isPlaying
                                            ? FontAwesome.pause_solid
                                            : FontAwesome.play_solid,
                                        size: 24,
                                        color: Default_Theme.primaryColor01,
                                      ),
                                      onPressed: () {
                                        state.isPlaying
                                            ? context
                                                .read<VibeyPlayerCubit>()
                                                .vibeyplayer
                                                .pause()
                                            : context
                                                .read<VibeyPlayerCubit>()
                                                .vibeyplayer
                                                .play();
                                      },
                                    )),
                        ),

                        // Next (Desktop only)
                        if (isDesktop)
                          IconButton(
                            icon: const Icon(
                              FontAwesome.forward_step_solid,
                              size: 24,
                              color: Default_Theme.primaryColor01,
                            ),
                            onPressed: () {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .skipToNext();
                            },
                          ),

                        const SizedBox(width: 6),
                      ],
                    ),
                  ),

                  // Progress bar
                  if (!isCompleted)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 6,
                      child: StreamBuilder<ProgressBarStreams>(
                        stream: context.watch<VibeyPlayerCubit>().progressStreams,
                        builder: (context, snapshot) {
                          try {
                            if (snapshot.hasData) {
                              return ProgressBar(
                                thumbRadius: 0,
                                barHeight: 3,
                                baseBarColor: Colors.white.withValues(alpha: 0.18),
                                bufferedBarColor: Colors.white.withValues(alpha: 0.28),
                                progressBarColor: Default_Theme.accentColor1,
                                timeLabelLocation: TimeLabelLocation.none,
                                progress: snapshot.data!.currentPos,
                                total: snapshot.data!.currentPlaybackState.duration!,
                              );
                            }
                          } catch (_) {}
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
