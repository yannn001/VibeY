import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vibey/Repo/JioMusic/saavn_api.dart';
import 'package:vibey/Repo/Youtube/yt_music_api.dart';
import 'package:vibey/models/JioMusic.dart';
import 'package:vibey/models/Yt_Music.dart';
import 'package:vibey/models/album.dart';
import 'package:vibey/models/artist.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/db_service.dart';

part 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> {
  final ArtistModel artist;
  final SourceEngine sourceEngine;
  ArtistCubit({required this.artist, required this.sourceEngine})
    : super(ArtistInitial()) {
    emit(ArtistLoading(artist: artist));
    checkIsSaved();
    switch (sourceEngine) {
      case SourceEngine.eng_JIS:
        SaavnAPI()
            .fetchArtistDetails(Uri.parse(artist.sourceURL).pathSegments.last)
            .then((value) {
              final songs = fromSaavnSongMapList2MediaItemList(value['songs']);
              final albums = saavnMap2Albums({'Albums': value['albums']});
              emit(
                ArtistLoaded(
                  artist: artist.copyWith(
                    songs: List<MediaItemModel>.from(songs),
                    description: value['subtitle'] ?? artist.description,
                    albums: List<AlbumModel>.from(albums),
                  ),
                  isSavedCollection: state.isSavedCollection,
                ),
              );
            });
        break;
      case SourceEngine.eng_YTM:
        YtMusicService().getArtistDetails(artist.sourceId).then((value) {
          log(value['songBrowseId'].toString());
          List<AlbumModel> albums = [];
          if (value['albums'] != null) {
            albums = ytmMap2Albums({'albums': value['albums']});
          }
          if (value['songBrowseId'] != null) {
            log('inside more');
            YtMusicService()
                .getPlaylist(
                  value['songBrowseId'].toString().replaceAll('VL', ''),
                )
                .then((v2) {
                  final songsFull = fromYtSongMapList2MediaItemList(
                    v2['songs'],
                  );
                  emit(
                    ArtistLoaded(
                      artist: artist.copyWith(
                        songs: List<MediaItemModel>.from(songsFull),
                        albums: List<AlbumModel>.from(albums),
                      ),
                      isSavedCollection: state.isSavedCollection,
                    ),
                  );
                });
          } else {
            final songs = fromYtSongMapList2MediaItemList(value['songs']);
            emit(
              ArtistLoaded(
                artist: artist.copyWith(
                  songs: List<MediaItemModel>.from(songs),
                  albums: List<AlbumModel>.from(albums),
                ),
                isSavedCollection: state.isSavedCollection,
              ),
            );
          }
        });
        break;
      case SourceEngine.eng_YTV:
    }
  }
  Future<void> checkIsSaved() async {
    bool isSaved = await DBService.isInSavedCollections(artist.sourceId);
    if (state.isSavedCollection != isSaved) {
      emit(state.copyWith(isSavedCollection: isSaved));
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedCollection) {
      await DBService.putOnlArtistModel(artist);
      SnackbarService.showMessage("Artist added to Library!");
    } else {
      await DBService.removeFromSavedCollecs(artist.sourceId);
      SnackbarService.showMessage("Artist removed from Library!");
    }
    checkIsSaved();
  }
}
