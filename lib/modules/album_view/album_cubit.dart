import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vibey/Repo/JioMusic/saavn_api.dart';
import 'package:vibey/Repo/Youtube/yt_music_api.dart';
import 'package:vibey/models/JioMusic.dart';
import 'package:vibey/models/Yt_Music.dart';
import 'package:vibey/models/album.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/db_service.dart';

part 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  final AlbumModel album;
  final SourceEngine sourceEngine;
  AlbumCubit({required this.album, required this.sourceEngine})
    : super(AlbumInitial()) {
    emit(AlbumLoading(album: album));
    checkIsSaved();
    switch (sourceEngine) {
      case SourceEngine.eng_JIS:
        SaavnAPI().fetchAlbumDetails(album.extra['token']).then((value) {
          emit(
            AlbumLoaded(
              album: album.copyWith(
                songs: List<MediaItemModel>.from(
                  fromSaavnSongMapList2MediaItemList(value['songs']),
                ),
              ),
              isSavedToCollections: state.isSavedToCollections,
            ),
          );
        });
        break;
      case SourceEngine.eng_YTM:
        YtMusicService()
            .getAlbumDetails(album.sourceId.replaceAll("youtube", ''))
            .then((value) {
              final List<MediaItemModel> songs =
                  fromYtSongMapList2MediaItemList(value['songs']);
              emit(
                AlbumLoaded(
                  album: album.copyWith(
                    songs: List<MediaItemModel>.from(songs),
                    artists: value['artist'] ?? album.artists,
                    description: value['subtitle'] ?? album.description,
                  ),
                  isSavedToCollections: state.isSavedToCollections,
                ),
              );
            });
      case SourceEngine.eng_YTV:
      // TODO: Handle this case.
    }
  }

  Future<void> checkIsSaved() async {
    bool isSaved = await DBService.isInSavedCollections(album.sourceId);
    if (state.isSavedToCollections != isSaved) {
      emit(state.copyWith(isSavedToCollections: isSaved));
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedToCollections) {
      await DBService.putOnlAlbumModel(album);
      SnackbarService.showMessage("Album added to Library!");
    } else {
      await DBService.removeFromSavedCollecs(album.sourceId);
      SnackbarService.showMessage("Album removed from Library!");
    }
    checkIsSaved();
  }
}
