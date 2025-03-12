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
  const MiniPlayerWidget({Key? key}) : super(key: key);

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
    return GestureDetector(
      onTap: () {
        context.pushNamed(GlobalStrConsts.playerScreen);
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(17)),
        child: SizedBox(
          height: 70,
          child: Stack(
            children: [
              Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
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
                  filter: ImageFilter.blur(sigmaY: 18, sigmaX: 18),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Keep the container color transparent
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 8,
                      top: 4,
                      bottom: 4,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 51,
                        height: 51,
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.song.title,
                          style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Default_Theme.primaryColor1,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.song.artist ?? 'Unknown Artist',
                          style: Default_Theme.secondoryTextStyle.merge(
                            TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: Default_Theme.primaryColor1.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AddToPlaylistCubit>().setMediaItemModel(
                        mediaItem2MediaItemModel(state.song),
                      );
                      context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
                    },
                    icon: const Icon(
                      FontAwesome.plus_solid,
                      size: 25,
                      color: Default_Theme.primaryColor01,
                    ),
                  ),
                  ResponsiveBreakpoints.of(context).isDesktop
                      ? IconButton(
                        icon: const Icon(
                          FontAwesome.backward_step_solid,
                          size: 28,
                          color: Default_Theme.primaryColor01,
                        ),
                        onPressed: () {
                          context
                              .read<VibeyPlayerCubit>()
                              .vibeyplayer
                              .skipToPrevious();
                        },
                      )
                      : const SizedBox.shrink(),
                  (state.isBuffering || isProcessing)
                      ? const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
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
                              size: 25,
                            ),
                          )
                          : IconButton(
                            icon: Icon(
                              state.isPlaying
                                  ? FontAwesome.pause_solid
                                  : FontAwesome.play_solid,
                              size: 26,
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
                  ResponsiveBreakpoints.of(context).isDesktop
                      ? IconButton(
                        icon: const Icon(
                          FontAwesome.forward_step_solid,
                          size: 28,
                          color: Default_Theme.primaryColor01,
                        ),
                        onPressed: () {
                          context
                              .read<VibeyPlayerCubit>()
                              .vibeyplayer
                              .skipToNext();
                        },
                      )
                      : const SizedBox.shrink(),
                ],
              ),
              isCompleted
                  ? const SizedBox()
                  : Positioned.fill(
                    bottom: 2,
                    left: 8,
                    right: 8,
                    top: 68,
                    child: StreamBuilder<ProgressBarStreams>(
                      stream: context.watch<VibeyPlayerCubit>().progressStreams,
                      builder: (context, snapshot) {
                        try {
                          if (snapshot.hasData) {
                            return ProgressBar(
                              thumbRadius: 0,
                              barHeight: 4,
                              baseBarColor: Colors.transparent,
                              timeLabelLocation: TimeLabelLocation.none,
                              progress: snapshot.data!.currentPos,
                              total:
                                  snapshot.data!.currentPlaybackState.duration!,
                            );
                          }
                        } catch (e) {}
                        return const SizedBox();
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
