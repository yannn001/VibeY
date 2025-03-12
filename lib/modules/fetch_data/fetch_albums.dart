import 'dart:developer';
import 'package:get/get.dart';
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

enum LState { initial, loading, loaded, noInternet }

enum Resulttypes {
  songs(val: 'Songs'),
  playlists(val: 'Playlists'),
  albums(val: 'Albums');

  final String val;
  const Resulttypes({required this.val});
}

class LastSearch {
  String query;
  int page = 1;
  final SourceEngine sourceEngine;
  bool hasReachedMax = false;
  List<MediaItemModel> mediaItemList = List.empty(growable: true);
  LastSearch({required this.query, required this.sourceEngine});
}

class SearchResultsController extends GetxController {
  var loadingState = LState.initial.obs;
  var playlistItems = <PlaylistModel>[].obs;

  Future<void> fetchHomeData(
    String query, {
    SourceEngine sourceEngine = SourceEngine.eng_YTM,
  }) async {
    log("Fetching Playlists", name: "FetchSearchRes");
    loadingState.value = LState.loading;

    try {
      List<PlaylistModel> playlists = [];
      switch (sourceEngine) {
        case SourceEngine.eng_YTM:
          final res = await YtMusicService().search(
            query,
            filter: "featured_playlists",
          );
          playlists = ytmMap2Playlists({
            'playlists': res.isNotEmpty ? res[0]['items'] : [],
          });
          break;

        case SourceEngine.eng_YTV:
          final searchResults = await YouTubeServices().fetchSearchResults(
            query,
            playlist: true,
          );
          playlists = ytvMap2Playlists({
            'playlists': searchResults[0]['items'],
          });
          break;

        case SourceEngine.eng_JIS:
          final res = await SaavnAPI().fetchPlaylistResults(query);
          playlists = saavnMap2Playlists({'Playlists': res});
          break;

        default:
          log("Invalid Source Engine", name: "FetchSearchRes");
          break;
      }

      playlistItems.assignAll(playlists);
      loadingState.value = LState.loaded;
      log("Got results: ${playlists.length}", name: "FetchSearchRes");
    } catch (e) {
      log("Error fetching playlists: $e", name: "FetchSearchRes");
      loadingState.value = LState.noInternet;
    }
  }

  void clearSearch() {
    playlistItems.clear();
    loadingState.value = LState.initial;
  }
}
