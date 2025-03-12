import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vibey/Repo/Lyrics/lyrics.dart';
import 'package:vibey/models/lyrics.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/values/Constants.dart';
import 'package:vibey/values/Strings_Const.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  StreamSubscription? _mediaItemSubscription;
  LyricsCubit(VibeyPlayerCubit playerCubit) : super(LyricsInitial()) {
    _mediaItemSubscription = playerCubit.vibeyplayer.mediaItem.stream.listen((
      v,
    ) {
      if (v != null) {
        getLyrics(mediaItem2MediaItemModel(v));
      }
    });
  }

  void getLyrics(MediaItemModel mediaItem) async {
    if (state.mediaItem == mediaItem && state is LyricsLoaded) {
      return;
    } else {
      emit(LyricsLoading(mediaItem));
      Lyrics? lyrics = await DBService.getLyrics(mediaItem.id);
      if (lyrics == null) {
        try {
          lyrics = await LyricsRepository.getLyrics(
            mediaItem.title,
            mediaItem.artist ?? "",
            album: mediaItem.album,
            duration: mediaItem.duration,
          );
          if (lyrics.lyricsSynced == "No Lyrics Found") {
            lyrics = lyrics.copyWith(lyricsSynced: null);
          }
          lyrics = lyrics.copyWith(mediaID: mediaItem.id);
          emit(LyricsLoaded(lyrics, mediaItem));
          DBService.getSettingBool(GlobalStrConsts.autoSaveLyrics).then((
            value,
          ) {
            if ((value ?? false) && lyrics != null) {
              DBService.putLyrics(lyrics);
              log(
                "Lyrics saved for ID: ${mediaItem.id} Duration: ${lyrics.duration}",
                name: "LyricsCubit",
              );
            }
          });
          log(
            "Lyrics loaded for ID: ${mediaItem.id} Duration: ${lyrics.duration} [Online]",
            name: "LyricsCubit",
          );
        } catch (e) {
          emit(LyricsError(mediaItem));
        }
      } else if (lyrics.mediaID == mediaItem.id) {
        emit(LyricsLoaded(lyrics, mediaItem));
        log(
          "Lyrics loaded for ID: ${mediaItem.id} Duration: ${lyrics.duration} [Offline]",
          name: "LyricsCubit",
        );
      }
    }
  }

  void setLyricsToDB(Lyrics lyrics, String mediaID) {
    final l1 = lyrics.copyWith(mediaID: mediaID);
    DBService.putLyrics(l1).then((v) {
      emit(LyricsLoaded(l1, state.mediaItem));
    });
    log(
      "Lyrics updated for ID: ${l1.mediaID} Duration: ${l1.duration}",
      name: "LyricsCubit",
    );
  }

  void deleteLyricsFromDB(MediaItemModel mediaItem) {
    DBService.removeLyricsById(mediaItem.id).then((value) {
      emit(LyricsInitial());
      getLyrics(mediaItem);

      log("Lyrics deleted for ID: ${mediaItem.id}", name: "LyricsCubit");
    });
  }

  @override
  Future<void> close() {
    _mediaItemSubscription?.cancel();
    return super.close();
  }
}
