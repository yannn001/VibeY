import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/modules/mini_player/mini_player_bloc.dart';
import 'package:vibey/screens/pages/player_views/lyrics_widget.dart';
import 'package:vibey/screens/widgets/playPause_widget.dart';
import 'package:vibey/services/vibeyPlayer.dart';
import 'package:vibey/theme/default.dart';

class LyricsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Vibeyplayer musicPlayer = context.read<VibeyPlayerCubit>().vibeyplayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lyrics',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Default_Theme.accentColor1,
        surfaceTintColor: Default_Theme.accentColor1,
        elevation: 0,
      ),
      backgroundColor: Default_Theme.accentColor1,
      body: Column(
        children: [
          // Lyrics Widget
          Expanded(child: LyricsWidget()),

          // Play/Pause Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
              builder: (context, state) {
                return PlayPauseButton(
                  size: 75,
                  onPause: () => musicPlayer.pause(),
                  onPlay: () => musicPlayer.play(),
                  isPlaying: state.isPlaying,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
