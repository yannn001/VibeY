
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vibey/Repo/JioMusic/saavn_api.dart';
import 'package:vibey/Repo/Youtube/youtube_api.dart';
import 'package:vibey/Repo/Youtube/yt_music_api.dart';
import 'package:vibey/models/JioMusic.dart';
import 'package:vibey/models/Yt_Music.dart';
import 'package:vibey/models/Yt_Video.dart';
import 'package:vibey/models/playlist.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/db_service.dart';

part 'online_playlist_state.dart';

class OnlPlaylistCubit extends Cubit<OnlPlaylistState> {
  PlaylistModel playlist;
  SourceEngine sourceEngine;
  OnlPlaylistCubit({required this.playlist, required this.sourceEngine})
    : super(OnlPlaylistInitial()) {
    emit(OnlPlaylistLoading(playlist: playlist));
    checkIsSaved();
    switch (sourceEngine) {
      case SourceEngine.eng_JIS:
        SaavnAPI()
            .fetchPlaylistDetails(
              Uri.parse(playlist.sourceURL).pathSegments.last,
            )
            .then((value) {
              final plst = PlaylistModel(
                name: value['playlistDetails']['album'],
                imageURL: value['playlistDetails']['image'],
                source: 'saavn',
                sourceId: value['playlistDetails']['id'],
                sourceURL: value['playlistDetails']['perma_url'],
                description: value['playlistDetails']['subtitle'],
                artists:
                    value['playlistDetails']['artist'] ?? 'Various Artists',
                language: value['playlistDetails']['language'],
              );
              final songs = fromSaavnSongMapList2MediaItemList(value['songs']);
              emit(
                OnlPlaylistLoaded(
                  playlist: playlist.copyWith(
                    name: plst.name,
                    imageURL: plst.imageURL,
                    source: plst.source,
                    sourceId: plst.sourceId,
                    sourceURL: plst.sourceURL,
                    description: plst.description,
                    artists: plst.artists,
                    songs: List<MediaItemModel>.from(songs),
                  ),
                  isSavedCollection: state.isSavedCollection,
                ),
              );
            });
        break;
      case SourceEngine.eng_YTM:
        YtMusicService()
            .getPlaylist(playlist.sourceId.replaceAll("youtubeVL", ""))
            .then((value) {
              final songs = fromYtSongMapList2MediaItemList(value['songs']);
              emit(
                OnlPlaylistLoaded(
                  playlist: playlist.copyWith(
                    songs: List<MediaItemModel>.from(songs),
                  ),
                  isSavedCollection: state.isSavedCollection,
                ),
              );
            });
        break;
      case SourceEngine.eng_YTV:
        YouTubeServices().fetchPlaylistItems(playlist.sourceId).then((value) {
          final songs = fromYtVidSongMapList2MediaItemList(value[0]['items']);
          emit(
            OnlPlaylistLoaded(
              playlist: playlist.copyWith(
                songs: List<MediaItemModel>.from(songs),
                artists: value[0]['metadata'].author,
              ),
              isSavedCollection: state.isSavedCollection,
            ),
          );
        });
        break;
    }
  }

  Future<void> checkIsSaved() async {
    bool isSaved = await DBService.isInSavedCollections(
      playlist.sourceId,
    );
    if (state.isSavedCollection != isSaved) {
      emit(state.copyWith(isSavedCollection: isSaved));
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedCollection) {
      await DBService.putOnlPlaylistModel(playlist);
      SnackbarService.showMessage("Artist added to Library!");
    } else {
      await DBService.removeFromSavedCollecs(playlist.sourceId);
      SnackbarService.showMessage("Artist removed from Library!");
    }
    checkIsSaved();
  }
}
