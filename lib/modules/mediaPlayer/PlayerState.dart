// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'PlayerCubit.dart';

class VibeyPlayerState {
  bool isReady;
  bool showLyrics;
  VibeyPlayerState({required this.isReady, this.showLyrics = false});
}

final class VibeyPlayerInitial extends VibeyPlayerState {
  VibeyPlayerInitial() : super(isReady: false);
}

class ProgressBarStreams {
  late Duration currentPos;
  late PlaybackEvent currentPlaybackState;
  late PlayerState currentPlayerState;
  ProgressBarStreams({
    required this.currentPos,
    required this.currentPlaybackState,
    required this.currentPlayerState,
  });
}
