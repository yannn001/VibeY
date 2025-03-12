// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vibey/Repo/JioMusic/saavn_api.dart';
import 'package:vibey/Repo/Youtube/youtube_api.dart';
import 'package:vibey/Repo/Youtube/yt_music_api.dart';
import 'package:vibey/models/JioMusic.dart';
import 'package:vibey/models/Yt_Music.dart';
import 'package:vibey/models/Yt_Video.dart';
import 'package:vibey/models/album.dart';
import 'package:vibey/models/artist.dart';
import 'package:vibey/models/playlist.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/models/source_engines.dart';

enum LoadingState { initial, loading, loaded, noInternet }

enum ResultTypes {
  // all(val: 'All'),
  songs(val: 'Songs'),
  playlists(val: 'Playlists'),
  albums(val: 'Albums'),
  artists(val: 'Artists');

  final String val;
  const ResultTypes({required this.val});
}

class LastSearch {
  String query;
  int page = 1;
  final SourceEngine sourceEngine;
  bool hasReachedMax = false;
  List<MediaItemModel> mediaItemList = List.empty(growable: true);
  LastSearch({required this.query, required this.sourceEngine});
}

class FetchSearchResultsState extends Equatable {
  final LoadingState loadingState;
  final List<MediaItemModel> mediaItems;
  final List<AlbumModel> albumItems;
  final List<PlaylistModel> playlistItems;
  final List<ArtistModel> artistItems;
  final SourceEngine? sourceEngine;
  final ResultTypes resultType;
  final bool hasReachedMax;
  const FetchSearchResultsState({
    required this.loadingState,
    required this.mediaItems,
    required this.albumItems,
    required this.artistItems,
    required this.playlistItems,
    required this.hasReachedMax,
    required this.resultType,
    this.sourceEngine,
  });

  @override
  List<Object?> get props => [
    loadingState,
    mediaItems,
    hasReachedMax,
    albumItems,
    artistItems,
    playlistItems,
    sourceEngine,
    resultType,
  ];

  FetchSearchResultsState copyWith({
    LoadingState? loadingState,
    List<MediaItemModel>? mediaItems,
    List<AlbumModel>? albumItems,
    List<PlaylistModel>? playlistItems,
    List<ArtistModel>? artistItems,
    ResultTypes? resultType,
    SourceEngine? sourceEngine,
    bool? hasReachedMax,
  }) {
    return FetchSearchResultsState(
      loadingState: loadingState ?? this.loadingState,
      mediaItems: mediaItems ?? this.mediaItems,
      albumItems: albumItems ?? this.albumItems,
      playlistItems: playlistItems ?? this.playlistItems,
      artistItems: artistItems ?? this.artistItems,
      resultType: resultType ?? this.resultType,
      sourceEngine: sourceEngine ?? this.sourceEngine,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

final class FetchSearchResultsInitial extends FetchSearchResultsState {
  FetchSearchResultsInitial()
    : super(
        mediaItems: [],
        loadingState: LoadingState.initial,
        hasReachedMax: false,
        albumItems: [],
        artistItems: [],
        playlistItems: [],
        resultType: ResultTypes.songs,
      );
}

final class FetchSearchResultsLoading extends FetchSearchResultsState {
  final ResultTypes resultType;
  FetchSearchResultsLoading({this.resultType = ResultTypes.songs})
    : super(
        mediaItems: [],
        loadingState: LoadingState.loading,
        hasReachedMax: false,
        albumItems: [],
        artistItems: [],
        playlistItems: [],
        resultType: resultType,
      );
}

final class FetchSearchResultsLoaded extends FetchSearchResultsState {
  final ResultTypes resultType;
  FetchSearchResultsLoaded({this.resultType = ResultTypes.songs})
    : super(
        mediaItems: [],
        loadingState: LoadingState.loaded,
        hasReachedMax: false,
        albumItems: [],
        artistItems: [],
        playlistItems: [],
        resultType: resultType,
      );
}
//------------------------------------------------------------------------

class FetchSearchResultsCubit extends Cubit<FetchSearchResultsState> {
  FetchSearchResultsCubit() : super(FetchSearchResultsInitial());

  String _albumSearchQuery = "";

  LastSearch last_YTM_search = LastSearch(
    query: "",
    sourceEngine: SourceEngine.eng_YTM,
  );
  LastSearch last_YTV_search = LastSearch(
    query: "",
    sourceEngine: SourceEngine.eng_YTV,
  );
  LastSearch last_JIS_search = LastSearch(
    query: "",
    sourceEngine: SourceEngine.eng_JIS,
  );

  List<MediaItemModel> _mediaItemList = List.empty(growable: true);

  // check if the search is already loaded and if not then load it (when resultType or sourceEngine is changed)
  Future<void> checkAndRefreshSearch({
    required String query,
    required SourceEngine sE,
    required ResultTypes rT,
  }) async {
    if ((state.sourceEngine != sE || state.resultType != rT) &&
        state is! FetchSearchResultsLoading &&
        query.isNotEmpty) {
      log("Refreshing Search", name: "FetchSearchRes");
      search(query, sourceEngine: sE, resultType: rT);
    }
  }

  Future<void> searchYTMTracks(
    String query, {
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    log("Youtube Music Search", name: "FetchSearchRes");

    last_YTM_search.query = query;
    emit(FetchSearchResultsLoading(resultType: resultType));
    switch (resultType) {
      case ResultTypes.songs:
        final searchResults = await YtMusicService().search(
          query,
          filter: "songs",
        );
        last_YTM_search.mediaItemList = fromYtSongMapList2MediaItemList(
          searchResults[0]['items'],
        );
        emit(
          state.copyWith(
            mediaItems: List<MediaItemModel>.from(
              last_YTM_search.mediaItemList,
            ),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_YTM,
          ),
        );
        break;
      case ResultTypes.playlists:
        final res = await YtMusicService().search(
          query,
          filter: "featured_playlists",
        );
        final playlist = ytmMap2Playlists({
          'playlists': res.isNotEmpty ? res[0]['items'] : [],
        });
        emit(
          state.copyWith(
            playlistItems: List<PlaylistModel>.from(playlist),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.playlists,
            sourceEngine: SourceEngine.eng_YTM,
          ),
        );
        log("Got results: ${playlist.length}", name: "FetchSearchRes");
        break;
      case ResultTypes.albums:
        final res = await YtMusicService().search(query, filter: "albums");
        final albums = ytmMap2Albums({
          'albums': res.isNotEmpty ? res[0]['items'] : [],
        });
        emit(
          state.copyWith(
            albumItems: List<AlbumModel>.from(albums),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.albums,
            sourceEngine: SourceEngine.eng_YTM,
          ),
        );
        log("Got results: ${albums.length}", name: "FetchSearchRes");
        break;
      case ResultTypes.artists:
        final res = await YtMusicService().search(query, filter: "artists");
        final artists = ytmMap2Artists({
          'artists': res.isNotEmpty ? res[0]['items'] : [],
        });
        emit(
          state.copyWith(
            artistItems: List<ArtistModel>.from(artists),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.artists,
            sourceEngine: SourceEngine.eng_YTM,
          ),
        );
        log("Got results: ${artists.length}", name: "FetchSearchRes");
        break;
    }

    log(
      "got all searches ${last_YTM_search.mediaItemList.length}",
      name: "FetchSearchRes",
    );
  }

  Future<void> searchYTVTracks(
    String query, {
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    log("Youtube Video Search", name: "FetchSearchRes");

    last_YTV_search.query = query;
    emit(FetchSearchResultsLoading(resultType: resultType));

    switch (resultType) {
      case ResultTypes.playlists:
        final res = await YouTubeServices().fetchSearchResults(
          query,
          playlist: true,
        );
        final List<PlaylistModel> playlists = ytvMap2Playlists({
          'playlists': res[0]['items'],
        });
        emit(
          state.copyWith(
            playlistItems: List<PlaylistModel>.from(playlists),
            resultType: ResultTypes.playlists,
            hasReachedMax: true,
            loadingState: LoadingState.loaded,
            sourceEngine: SourceEngine.eng_YTV,
          ),
        );
        break;
      case ResultTypes.albums:
      case ResultTypes.artists:
      case ResultTypes.songs:
        final searchResults = await YouTubeServices().fetchSearchResults(query);
        last_YTV_search.mediaItemList = (fromYtVidSongMapList2MediaItemList(
          searchResults[0]['items'],
        ));
        emit(
          state.copyWith(
            mediaItems: List<MediaItemModel>.from(
              last_YTV_search.mediaItemList,
            ),
            loadingState: LoadingState.loaded,
            resultType: ResultTypes.songs,
            hasReachedMax: true,
            sourceEngine: SourceEngine.eng_YTV,
          ),
        );
        log(
          "got all searches ${last_YTV_search.mediaItemList.length}",
          name: "FetchSearchRes",
        );
        break;
    }
  }

  Future<void> searchJISTracks(
    String query, {
    bool loadMore = false,
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    switch (resultType) {
      case ResultTypes.songs:
        if (!loadMore) {
          emit(FetchSearchResultsLoading(resultType: resultType));
          last_JIS_search.query = query;
          last_JIS_search.mediaItemList.clear();
          last_JIS_search.hasReachedMax = false;
          last_JIS_search.page = 1;
        }
        log("JIOSaavn Search", name: "FetchSearchRes");
        final searchResults = await SaavnAPI().fetchSongSearchResults(
          searchQuery: query,
          page: last_JIS_search.page,
        );
        last_JIS_search.page++;
        _mediaItemList = fromSaavnSongMapList2MediaItemList(
          searchResults['songs'],
        );
        if (_mediaItemList.length < 20) {
          last_JIS_search.hasReachedMax = true;
        }
        last_JIS_search.mediaItemList.addAll(_mediaItemList);

        emit(
          state.copyWith(
            mediaItems: List<MediaItemModel>.from(
              last_JIS_search.mediaItemList,
            ),
            loadingState: LoadingState.loaded,
            hasReachedMax: last_JIS_search.hasReachedMax,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_JIS,
          ),
        );

        log(
          "got all searches ${last_JIS_search.mediaItemList.length}",
          name: "FetchSearchRes",
        );
        break;
      case ResultTypes.albums:
        emit(FetchSearchResultsLoading(resultType: resultType));
        final res = await SaavnAPI().fetchAlbumResults(query);
        final albumList = saavnMap2Albums({'Albums': res});
        log("Got results: ${albumList.length}", name: "FetchSearchRes");
        emit(
          state.copyWith(
            albumItems: List<AlbumModel>.from(albumList),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.albums,
            sourceEngine: SourceEngine.eng_JIS,
          ),
        );
        break;
      case ResultTypes.playlists:
        emit(FetchSearchResultsLoading(resultType: resultType));
        final res = await SaavnAPI().fetchPlaylistResults(query);
        final playlistList = saavnMap2Playlists({'Playlists': res});
        log("Got results: ${playlistList.length}", name: "FetchSearchRes");
        emit(
          state.copyWith(
            playlistItems: List<PlaylistModel>.from(playlistList),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.playlists,
            sourceEngine: SourceEngine.eng_JIS,
          ),
        );
        break;
      case ResultTypes.artists:
        emit(FetchSearchResultsLoading(resultType: resultType));
        final res = await SaavnAPI().fetchArtistResults(query);
        final artistList = saavnMap2Artists({'Artists': res});
        log("Got results: ${artistList.length}", name: "FetchSearchRes");
        emit(
          state.copyWith(
            artistItems: List<ArtistModel>.from(artistList),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.artists,
            sourceEngine: SourceEngine.eng_JIS,
          ),
        );
        break;
    }
  }

  Future<void> fetchAlbums(
    String query, {
    SourceEngine sourceEngine = SourceEngine.eng_YTM,
  }) async {
    log("Fetching Albums", name: "FetchSearchRes");
    // emit(FetchSearchResultsLoading(resultType: ResultTypes.albums));

    _albumSearchQuery = query;

    switch (sourceEngine) {
      case SourceEngine.eng_YTM:
        final res = await YtMusicService().search(query, filter: "albums");
        final albums = ytmMap2Albums({
          'albums': res.isNotEmpty ? res[0]['items'] : [],
        });
        emit(
          state.copyWith(
            albumItems: List<AlbumModel>.from(albums),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.albums,
            sourceEngine: sourceEngine,
          ),
        );
        log("Got results: ${albums.length}", name: "FetchSearchRes");
        break;

      case SourceEngine.eng_YTV:
        final searchResults = await YouTubeServices().fetchSearchResults(query);
        final albums = fromYtVidSongMapList2MediaItemList(
          searchResults[0]['items'],
        );
        emit(
          state.copyWith(
            albumItems: List<AlbumModel>.from(albums),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.albums,
            sourceEngine: sourceEngine,
          ),
        );
        log("Got results: ${albums.length}", name: "FetchSearchRes");
        break;

      default:
        log("Invalid Source Engine", name: "FetchSearchRes");
        break;
    }
  }

  Future<void> search(
    String query, {
    SourceEngine sourceEngine = SourceEngine.eng_YTM,
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    switch (sourceEngine) {
      case SourceEngine.eng_YTM:
        searchYTMTracks(query, resultType: resultType);
        break;
      case SourceEngine.eng_YTV:
        searchYTVTracks(query, resultType: resultType);
        break;
      case SourceEngine.eng_JIS:
        searchJISTracks(query, resultType: resultType);
        break;
      default:
        log("Invalid Source Engine", name: "FetchSearchRes");
        searchYTMTracks(query);
    }
  }

  void clearSearch() {
    emit(FetchSearchResultsInitial());
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    List<String> searchSuggestions;
    try {
      searchSuggestions =
          await YouTubeServices().getSearchSuggestions(query: query)
              as List<String>;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }
}
