import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibey/modules/lyrics/lyrics_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (state) {
            LyricsInitial() => const Center(child: CircularProgressIndicator()),
            LyricsLoaded() => loadedLyricsWidget(context, state),
            LyricsError() => const SignBoardWidget(
              icon: MingCute.music_2_line,
              message: "No Lyrics Found",
            ),
            LyricsLoading() => const Center(child: CircularProgressIndicator()),
            LyricsState() => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

Widget loadedLyricsWidget(BuildContext context, LyricsState state) {
  if (state.lyrics.parsedLyrics == null &&
      state.lyrics.lyricsPlain.isNotEmpty) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SelectableText(
          "\n${state.lyrics.lyricsPlain}\n",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            textStyle: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ),
      ),
    );
  } else if (state.lyrics.parsedLyrics != null) {
    return SyncedLyricsWidget(state: state);
  }
  return const Center(
    child: SignBoardWidget(
      message: "No Lyrics found",
      icon: MingCute.music_2_line,
    ),
  );
}

class SyncedLyricsWidget extends StatefulWidget {
  final LyricsState state;
  const SyncedLyricsWidget({required this.state, super.key});

  @override
  State<SyncedLyricsWidget> createState() => _SyncedLyricsWidgetState();
}

class _SyncedLyricsWidgetState extends State<SyncedLyricsWidget> {
  StreamSubscription? _streamSubscription;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _streamSubscription = context
        .read<VibeyPlayerCubit>()
        .vibeyplayer
        .audioPlayer
        .positionStream
        .listen((event) {
          setState(() {
            duration = event;
            _scrollToCurrentLyric();
          });
        });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _scrollToCurrentLyric() {
    final currentIndex = _findCurrentLyricIndex();
    if (currentIndex >= 4 || !isIdxVisible(currentIndex)) {
      _itemScrollController.scrollTo(
        index: currentIndex < 4 ? currentIndex : currentIndex - 3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int _findCurrentLyricIndex() {
    for (int i = 0; i < widget.state.lyrics.parsedLyrics!.lyrics.length; i++) {
      if (widget.state.lyrics.parsedLyrics!.lyrics[i].start.inSeconds <=
          duration.inSeconds) {
        if (i >= widget.state.lyrics.parsedLyrics!.lyrics.length - 1) {
          return i;
        } else if (widget
                .state
                .lyrics
                .parsedLyrics!
                .lyrics[i + 1]
                .start
                .inSeconds >
            duration.inSeconds) {
          return i;
        }
      }
    }
    return 0;
  }

  bool isIdxVisible(int index) {
    return _itemPositionsListener.itemPositions.value.any(
      (element) => element.index == index,
    );
  }

  bool isCurrentLyric(int index) {
    if (widget.state.lyrics.parsedLyrics!.lyrics[index].start.inSeconds <=
        duration.inSeconds) {
      if (index >= widget.state.lyrics.parsedLyrics!.lyrics.length - 1) {
        return true;
      } else if (widget
              .state
              .lyrics
              .parsedLyrics!
              .lyrics[index + 1]
              .start
              .inSeconds >
          duration.inSeconds) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: widget.state.lyrics.parsedLyrics!.lyrics.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              widget.state.lyrics.parsedLyrics!.lyrics[index].text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                textStyle: Default_Theme.secondoryTextStyle.merge(
                  TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color:
                        isCurrentLyric(index)
                            ? Default_Theme.accentColor2.withOpacity(0.9)
                            : Default_Theme.primaryColor2.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
