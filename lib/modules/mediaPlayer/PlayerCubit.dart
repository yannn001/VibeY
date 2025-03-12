import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibey/services/audio_service_initializer.dart';
import 'package:vibey/services/vibeyPlayer.dart';
part 'PlayerState.dart';

enum PlayerInitState { initializing, initialized, intial }

class VibeyPlayerCubit extends Cubit<VibeyPlayerState> {
  late Vibeyplayer vibeyplayer;
  PlayerInitState playerInitState = PlayerInitState.intial;
  late Stream<ProgressBarStreams> progressStreams;
  VibeyPlayerCubit() : super(VibeyPlayerInitial()) {
    setupPlayer().then((value) => emit(VibeyPlayerState(isReady: true)));
  }

  void switchShowLyrics({bool? value}) {
    emit(
      VibeyPlayerState(isReady: true, showLyrics: value ?? !state.showLyrics),
    );
  }

  Future<void> setupPlayer() async {
    playerInitState = PlayerInitState.initializing;
    vibeyplayer = await PlayerInitializer().getMusicPlayer();
    playerInitState = PlayerInitState.initialized;
    progressStreams = Rx.defer(
      () => Rx.combineLatest3(
        vibeyplayer.audioPlayer.positionStream,
        vibeyplayer.audioPlayer.playbackEventStream,
        vibeyplayer.audioPlayer.playerStateStream,
        (Duration a, PlaybackEvent b, PlayerState c) => ProgressBarStreams(
          currentPos: a,
          currentPlaybackState: b,
          currentPlayerState: c,
        ),
      ),
      reusable: true,
    );
  }

  @override
  Future<void> close() {
    vibeyplayer.stop();
    vibeyplayer.audioPlayer.dispose();
    return super.close();
  }
}
