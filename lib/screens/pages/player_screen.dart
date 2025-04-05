import 'dart:async';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vibey/modules/mini_player/mini_player_bloc.dart';
import 'package:vibey/screens/pages/Lyrics_screen.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/services/vibeyPlayer.dart';
import 'package:vibey/services/shortcuts_intents.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibey/screens/widgets/like_widget.dart';
import 'package:vibey/screens/widgets/playPause_widget.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:vibey/utils/pallete_generator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../modules/mediaPlayer/PlayerCubit.dart';
import 'player_views/lyrics_widget.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  late TabController _tabController;
  StreamSubscription? _showLyricsSub;
  bool showLyrics = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    // set value switchLyrics if tab is changed
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context.read<VibeyPlayerCubit>().switchShowLyrics(value: true);
      } else {
        context.read<VibeyPlayerCubit>().switchShowLyrics(value: false);
      }
    });

    _showLyricsSub = BlocProvider.of<VibeyPlayerCubit>(context).stream.listen((
      state,
    ) {
      if (mounted) {
        if (state.showLyrics) {
          _tabController.animateTo(1);
        } else {
          _tabController.animateTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _showLyricsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Vibeyplayer musicPlayer = context.read<VibeyPlayerCubit>().vibeyplayer;
    return Actions(
      actions: {
        ShuffleIntent: CallbackAction<ShuffleIntent>(
          onInvoke: (ShuffleIntent intent) {
            if (context
                .read<VibeyPlayerCubit>()
                .vibeyplayer
                .shuffleMode
                .value) {
              context.read<VibeyPlayerCubit>().vibeyplayer.shuffle(false);
            } else {
              context.read<VibeyPlayerCubit>().vibeyplayer.shuffle(true);
            }
            return null;
          },
        ),
        LoopPlaylistIntent: CallbackAction<LoopPlaylistIntent>(
          onInvoke: (LoopPlaylistIntent intent) {
            context.read<VibeyPlayerCubit>().vibeyplayer.setLoopMode(
              LoopMode.all,
            );
            return null;
          },
        ),
        LoopOffIntent: CallbackAction<LoopOffIntent>(
          onInvoke: (LoopOffIntent intent) {
            context.read<VibeyPlayerCubit>().vibeyplayer.setLoopMode(
              LoopMode.off,
            );
            return null;
          },
        ),
        LoopSingleIntent: CallbackAction<LoopSingleIntent>(
          onInvoke: (LoopSingleIntent intent) {
            context.read<VibeyPlayerCubit>().vibeyplayer.setLoopMode(
              LoopMode.one,
            );
            return null;
          },
        ),
        BackIntent: CallbackAction<BackIntent>(
          onInvoke: (BackIntent intent) {
            Navigator.pop(context);
            return null;
          },
        ),
      },
      child: FocusScope(
        // Added this widget to enable keyboard shortcuts
        autofocus: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              size: 32,
            ),
            toolbarHeight: 80,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Default_Theme.primaryColor01,
            centerTitle: true,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 32,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showMoreBottomSheet(
                    context,
                    context.read<VibeyPlayerCubit>().vibeyplayer.currentMedia,
                  );
                },
                icon: Icon(
                  MingCute.more_1_fill,
                  size: 28,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ],
            title: Column(
              children: [
                Text(
                  'VibeY',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Default_Theme.accentColor1,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
                Text(
                  'Now Playing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontSize: 12,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
              ],
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child:
                ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)
                    ? playerUI(context, musicPlayer)
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 400,
                            maxWidth: MediaQuery.of(context).size.width * 0.60,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: playerUI(context, musicPlayer),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: UpNextPanel(
                                panelController: _panelController,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  LayoutBuilder playerUI(BuildContext context, Vibeyplayer musicPlayer) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.92,
                child: Stack(
                  children: [
                    Positioned(
                      child: Opacity(
                        opacity: 0.15,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight * 0.65,
                          child: StreamBuilder<MediaItem?>(
                            stream: musicPlayer.mediaItem,
                            builder: (context, snapshot) {
                              return AnimatedSwitcher(
                                duration: const Duration(seconds: 3),
                                child: AmbientImgShadowWidget(
                                  snapshot: snapshot,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.90,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.90,
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity != null) {
                                if (details.primaryVelocity! < -100) {
                                  // Swipe left: Skip to next song
                                  musicPlayer.skipToNext();
                                } else if (details.primaryVelocity! > 100) {
                                  // Swipe right: Skip to previous song
                                  musicPlayer.skipToPrevious();
                                }
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Container(height: 5)),
                                Flexible(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16,
                                      left: 16,
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: GestureDetector(
                                          onDoubleTap: () {
                                            // Navigate to the LyricsScreen on double-tap
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => LyricsScreen(),
                                              ),
                                            );
                                          },
                                          child: CoverImage(
                                            constraints: constraints,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                PlayerCtrlWidgets(musicPlayer: musicPlayer),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CoverImage extends StatefulWidget {
  final BoxConstraints constraints;
  const CoverImage({super.key, required this.constraints});

  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Controls the speed of rotation
    );

    _playerStateSubscription = context
        .read<VibeyPlayerCubit>()
        .vibeyplayer
        .audioPlayer
        .playerStateStream
        .listen((playerState) {
          if (mounted) {
            // Ensure widget is still in the tree
            if (playerState.playing) {
              _rotationController.repeat();
            } else {
              _rotationController.stop();
            }
          }
        });
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel(); // Cancel the stream subscription
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationController, // Apply the rotation animation
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: StreamBuilder<MediaItem?>(
              stream: context.watch<VibeyPlayerCubit>().vibeyplayer.mediaItem,
              builder: (context, snapshot) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: widget.constraints.maxWidth * 0.85,
                        maxHeight: widget.constraints.maxHeight * 0.85,
                      ),
                      child: SizedBox(
                        width: constraints.maxWidth * 0.85,
                        height: constraints.maxWidth * 0.85,
                        child: Image.asset(
                          "assets/icons/vinyl.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: widget.constraints.maxWidth * 0.3,
            height: widget.constraints.maxWidth * 0.3,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: StreamBuilder<MediaItem?>(
              stream: context.watch<VibeyPlayerCubit>().vibeyplayer.mediaItem,
              builder: (context, snapshot) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return LoadImageCached(
                      imageUrl: formatImgURL(
                        (snapshot.data?.artUri ?? "").toString(),
                        ImageQuality.high,
                      ),
                      fallbackUrl: formatImgURL(
                        (snapshot.data?.artUri ?? "").toString(),
                        ImageQuality.medium,
                      ),
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UpNextPanel extends StatefulWidget {
  const UpNextPanel({super.key, required PanelController panelController})
    : _panelController = panelController;

  final PanelController _panelController;

  @override
  State<UpNextPanel> createState() => _UpNextPanelState();
}

class _UpNextPanelState extends State<UpNextPanel> {
  final ItemScrollController _scrollController = ItemScrollController();

  StreamSubscription? _mediaItemSub;
  Stream upNext = Rx.defer(
    () => Rx.combineLatest2(
      BehaviorSubject<List<MediaItem>>.seeded([]),
      BehaviorSubject<List<MediaItem>>.seeded([]),
      (a, b) => [...a, ...b],
    ),
    reusable: true,
  );

  @override
  void initState() {
    upNext = Rx.defer(
      () => CombineLatestStream.combine2(
        context.read<VibeyPlayerCubit>().vibeyplayer.queue,
        context.read<VibeyPlayerCubit>().vibeyplayer.relatedSongs,
        (a, b) => [...a, ...b],
      ),
      reusable: true,
    );
    _mediaItemSub = context
        .read<VibeyPlayerCubit>()
        .vibeyplayer
        .mediaItem
        .listen((value) {
          if (value != null && mounted) {
            // at first the scrollablepositionedlist is not ready
            try {
              _scrollController.scrollTo(
                index:
                    context
                        .read<VibeyPlayerCubit>()
                        .vibeyplayer
                        .currentPlayingIdx,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              Future.delayed(const Duration(milliseconds: 500), () {
                _scrollController.scrollTo(
                  index:
                      context
                          .read<VibeyPlayerCubit>()
                          .vibeyplayer
                          .currentPlayingIdx,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              });
            }
          }
        });
    super.initState();
  }

  @override
  void dispose() {
    _mediaItemSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-Screen Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.deepPurpleAccent, Colors.black],
                ),
              ),
            ),
          ),
          // Lyrics Display
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: LyricsWidget(),
            ),
          ),
          // Typography Header
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Lyrics",
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.purpleAccent.withOpacity(0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerCtrlWidgets extends StatelessWidget {
  const PlayerCtrlWidgets({super.key, required this.musicPlayer});

  final Vibeyplayer musicPlayer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.82,
      // height: MediaQuery.of(context).size.width * 0.92,
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: StreamBuilder<MediaItem?>(
                  stream:
                      context.watch<VibeyPlayerCubit>().vibeyplayer.mediaItem,
                  builder: (context, snapshot) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.antiAlias,
                          child: SelectableText(
                            snapshot.data?.title ?? "Unknown",
                            textAlign: TextAlign.start,
                            // overflow: TextOverflow.ellipsis,
                            style: Default_Theme.secondoryTextStyle.merge(
                              TextStyle(
                                fontSize: 22,
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            snapshot.data?.artist ?? "Unknown",
                            textAlign: TextAlign.start,
                            // overflow: TextOverflow.ellipsis,
                            style: Default_Theme.secondoryTextStyle.merge(
                              TextStyle(
                                fontSize: 15,
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color?.withAlpha(100),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(),
              StreamBuilder<dynamic>(
                stream:
                    context
                        .watch<VibeyPlayerCubit>()
                        .vibeyplayer
                        .audioPlayer
                        .playbackEventStream,
                builder: (context, snapshot) {
                  return FutureBuilder(
                    future: context.read<DBCubit>().isLiked(
                      context.read<VibeyPlayerCubit>().vibeyplayer.currentMedia,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: LikeBtnWidget(
                            isPlaying: true,
                            isLiked: snapshot.data ?? false,
                            iconSize: 35,
                            onLiked:
                                () => context.read<DBCubit>().setLike(
                                  context
                                      .read<VibeyPlayerCubit>()
                                      .vibeyplayer
                                      .currentMedia,
                                  isLiked: true,
                                ),
                            onDisliked:
                                () => context.read<DBCubit>().setLike(
                                  context
                                      .read<VibeyPlayerCubit>()
                                      .vibeyplayer
                                      .currentMedia,
                                  isLiked: false,
                                ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: LikeBtnWidget(
                            isLiked: false,
                            isPlaying: true,
                            iconSize: 35,
                            onLiked: () {},
                            onDisliked: () {},
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StreamBuilder<ProgressBarStreams>(
              stream: context.watch<VibeyPlayerCubit>().progressStreams,
              builder: (context, snapshot) {
                return ProgressBar(
                  progress: snapshot.data?.currentPos ?? Duration.zero,
                  total:
                      snapshot.data?.currentPlaybackState.duration ??
                      Duration.zero,
                  buffered:
                      snapshot.data?.currentPlaybackState.bufferedPosition ??
                      Duration.zero,
                  onSeek: (value) {
                    musicPlayer.seek(value);
                  },
                  timeLabelPadding: 5,
                  timeLabelTextStyle: Default_Theme.secondoryTextStyle.merge(
                    TextStyle(
                      fontSize: 15,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color?.withAlpha(200),
                    ),
                  ),
                  timeLabelLocation: TimeLabelLocation.below,
                  baseBarColor: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color?.withAlpha(50),
                  progressBarColor:
                      snapshot.data?.currentPlayerState.playing ?? false
                          ? Default_Theme.accentColor1
                          : Default_Theme.accentColor2,
                  thumbRadius: 5,
                  thumbColor:
                      snapshot.data?.currentPlayerState.playing ?? false
                          ? Default_Theme.accentColor1
                          : Default_Theme.accentColor2,
                  bufferedBarColor:
                      snapshot.data?.currentPlayerState.playing ?? false
                          ? Default_Theme.accentColor1.withOpacity(0.2)
                          : Default_Theme.accentColor2.withOpacity(0.2),
                  barHeight: 4,
                );
              },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => musicPlayer.skipToPrevious(),
                    icon: Image.asset(
                      "assets/icons/pre_song_icn.png",
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
                  //Play Pause btn
                  BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
                    builder: (context, state) {
                      switch (state) {
                        case MiniPlayerInitial():
                          return Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Default_Theme.accentColor2,
                                  spreadRadius: 1,
                                  blurRadius: 20,
                                ),
                              ],
                              shape: BoxShape.circle,
                              color: Default_Theme.accentColor2,
                            ),
                            width: 75,
                            height: 75,
                            child: Center(
                              child: SizedBox(
                                width: 35,
                                height: 35,
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                                ),
                              ),
                            ),
                          );
                        case MiniPlayerCompleted():
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .rewind();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Default_Theme.accentColor2,
                                    spreadRadius: 1,
                                    blurRadius: 20,
                                  ),
                                ],
                                shape: BoxShape.circle,
                                color: Default_Theme.accentColor2,
                              ),
                              width: 75,
                              height: 75,
                              child: const Center(
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Icon(
                                    FontAwesome.rotate_right_solid,
                                    color: Default_Theme.primaryColor1,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ),
                          );
                        case MiniPlayerWorking():
                          return PlayPauseButton(
                            size: 75,
                            onPause: () => musicPlayer.pause(),
                            onPlay: () => musicPlayer.play(),
                            isPlaying: state.isPlaying,
                          );
                        case MiniPlayerError():
                          return Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Default_Theme.accentColor2,
                                  spreadRadius: 1,
                                  blurRadius: 20,
                                ),
                              ],
                              shape: BoxShape.circle,
                              color: Default_Theme.accentColor2,
                            ),
                            width: 75,
                            height: 75,
                            child: Center(
                              child: SizedBox(
                                width: 35,
                                height: 35,
                                child: Icon(
                                  MingCute.warning_line,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                                ),
                              ),
                            ),
                          );
                        case MiniPlayerProcessing():
                          return Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Default_Theme.accentColor2,
                                  spreadRadius: 1,
                                  blurRadius: 20,
                                ),
                              ],
                              shape: BoxShape.circle,
                              color: Default_Theme.accentColor2,
                            ),
                            width: 75,
                            height: 75,
                            child: const Center(
                              child: SizedBox(
                                width: 35,
                                height: 35,
                                child: CircularProgressIndicator(
                                  color: Default_Theme.primaryColor1,
                                ),
                              ),
                            ),
                          );
                      }
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => musicPlayer.skipToNext(),
                    icon: Image.asset(
                      "assets/icons/skip_song_icn.png",
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder<bool>(
                stream:
                    context.watch<VibeyPlayerCubit>().vibeyplayer.shuffleMode,
                builder: (context, snapshot) {
                  return Tooltip(
                    message: "Shuffle",
                    child: IconButton(
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Image.asset(
                        "assets/icons/shuffle_icn.png",
                        color:
                            (snapshot.data ?? false)
                                ? Default_Theme.accentColor1
                                : Theme.of(context).textTheme.bodyMedium!.color,
                        height: 30.0,
                        width: 30.0,
                      ),
                      onPressed: () {
                        context.read<VibeyPlayerCubit>().vibeyplayer.shuffle(
                          (snapshot.data ?? false) ? false : true,
                        );
                      },
                    ),
                  );
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: "Loop",
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: StreamBuilder<LoopMode>(
                        stream:
                            context
                                .watch<VibeyPlayerCubit>()
                                .vibeyplayer
                                .loopMode,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            IconData icon;
                            Color iconColor;

                            switch (snapshot.data) {
                              case LoopMode.off:
                                icon = MingCute.repeat_line;
                                iconColor =
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color!;
                                break;
                              case LoopMode.one:
                                icon = MingCute.repeat_one_line;
                                iconColor = Default_Theme.accentColor1;
                                break;
                              case LoopMode.all:
                                icon = MingCute.repeat_fill;
                                iconColor = Default_Theme.accentColor1;
                                break;
                              default:
                                icon = MingCute.repeat_line;
                                iconColor =
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color!;
                            }

                            return IconButton(
                              icon: Icon(icon, color: iconColor, size: 30),
                              onPressed: () {
                                LoopMode? currentMode = snapshot.data;
                                LoopMode newMode;

                                if (currentMode == LoopMode.off) {
                                  newMode = LoopMode.one;
                                } else if (currentMode == LoopMode.one) {
                                  newMode = LoopMode.all;
                                } else {
                                  newMode = LoopMode.off;
                                }

                                context
                                    .read<VibeyPlayerCubit>()
                                    .vibeyplayer
                                    .setLoopMode(newMode);
                              },
                            );
                          }

                          return IconButton(
                            icon: const Icon(
                              MingCute.repeat_line,
                              color: Default_Theme.primaryColor1,
                              size: 30,
                            ),
                            onPressed: () {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .setLoopMode(LoopMode.one);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AmbientImgShadowWidget extends StatelessWidget {
  final AsyncSnapshot<MediaItem?> snapshot;
  const AmbientImgShadowWidget({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPalleteFromImage(
        context
            .read<VibeyPlayerCubit>()
            .vibeyplayer
            .currentMedia
            .artUri
            .toString(),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      snapshot.data?.dominantColor?.color ??
                      const Color.fromARGB(255, 255, 68, 68),
                  blurRadius: 120,
                  spreadRadius: 20,
                ),
              ],
            ),
          );
        } else {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 120,
                  spreadRadius: 30,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
