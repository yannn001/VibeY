import 'dart:developer';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/db_service.dart';

part 'DBState.dart';

class DBCubit extends Cubit<MediadbState> {
  DBService vibeyDBService = DBService();
  DBCubit() : super(MediadbInitial()) {
    addNewPlaylistToDB(MediaPlaylistDB(playlistName: "Your Likes"));
  }

  Future<void> addNewPlaylistToDB(
    MediaPlaylistDB mediaPlaylistDB, {
    bool undo = false,
  }) async {
    List<String> _list = await getListOfPlaylists();
    if (!_list.contains(mediaPlaylistDB.playlistName)) {
      DBService.addPlaylist(mediaPlaylistDB);
      // refreshLibrary.add(true);
      if (!undo) {
        SnackbarService.showMessage(
          "Playlist ${mediaPlaylistDB.playlistName} added",
        );
      }
    }
  }

  Future<void> setLike(MediaItem mediaItem, {isLiked = false}) async {
    DBService.addMediaItem(MediaItem2MediaItemDB(mediaItem), "Your Likes");
    // refreshLibrary.add(true);
    DBService.likeMediaItem(MediaItem2MediaItemDB(mediaItem), isLiked: isLiked);
    if (isLiked) {
      SnackbarService.showMessage("Added to Likes");
    } else {
      SnackbarService.showMessage("Removed from Likes");
    }
  }

  Future<bool> isLiked(MediaItem mediaItem) {
    // bool res = true;
    return DBService.isMediaLiked(MediaItem2MediaItemDB(mediaItem));
  }

  List<MediaItemDB> reorderByRank(
    List<MediaItemDB> orgMediaList,
    List<int> rankIndex,
  ) {
    List<MediaItemDB> reorderedList = orgMediaList;
    orgMediaList.forEach((element) {
      log('orgMEdia - ${element.id} - ${element.title}', name: "DBCubit");
    });
    log(rankIndex.toString(), name: "DBCubit");
    if (rankIndex.length == orgMediaList.length) {
      reorderedList =
          rankIndex
              .map((e) => orgMediaList.firstWhere((element) => e == element.id))
              .map((e) => e)
              .toList();

      return reorderedList;
    } else {
      return orgMediaList;
    }
  }

  Future<MediaPlaylist> getPlaylistItems(
    MediaPlaylistDB mediaPlaylistDB,
  ) async {
    MediaPlaylist _mediaPlaylist = MediaPlaylist(
      mediaItems: [],
      playlistName: mediaPlaylistDB.playlistName,
    );

    var _dbList = await DBService.getPlaylistItems(mediaPlaylistDB);
    final playlist = await DBService.getPlaylist(mediaPlaylistDB.playlistName);
    final info = await DBService.getPlaylistInfo(mediaPlaylistDB.playlistName);
    if (playlist != null) {
      _mediaPlaylist = fromPlaylistDB2MediaPlaylist(
        mediaPlaylistDB,
        playlistsInfoDB: info,
      );

      if (_dbList != null) {
        List<int> _rankList = await DBService.getPlaylistItemsRank(
          mediaPlaylistDB,
        );

        if (_rankList.isNotEmpty) {
          _dbList = reorderByRank(_dbList, _rankList);
        }
        _mediaPlaylist.mediaItems.clear();

        for (var element in _dbList) {
          _mediaPlaylist.mediaItems.add(MediaItemDB2MediaItem(element));
        }
      }
    }
    return _mediaPlaylist;
  }

  Future<void> setPlayListItemsRank(
    MediaPlaylistDB mediaPlaylistDB,
    List<int> rankList,
  ) async {
    DBService.setPlaylistItemsRank(mediaPlaylistDB, rankList);
  }

  Future<Stream> getStreamOfPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    return await DBService.getStream4MediaList(mediaPlaylistDB);
  }

  Future<List<String>> getListOfPlaylists() async {
    List<String> mediaPlaylists = [];
    final _albumList = await DBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element.playlistName);
      });
    }
    return mediaPlaylists;
  }

  Future<List<MediaPlaylist>> getListOfPlaylists2() async {
    List<MediaPlaylist> mediaPlaylists = [];
    final _albumList = await DBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element);
      });
    }
    return mediaPlaylists;
  }

  Future<void> reorderPositionOfItemInDB(
    String playlistName,
    int old_idx,
    int new_idx,
  ) async {
    DBService.reorderItemPositionInPlaylist(
      MediaPlaylistDB(playlistName: playlistName),
      old_idx,
      new_idx,
    );
  }

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    DBService.removePlaylist(mediaPlaylistDB);
  }

  Future<void> removeMediaFromPlaylist(
    MediaItem mediaItem,
    MediaPlaylistDB mediaPlaylistDB,
  ) async {
    MediaItemDB _mediaItemDB = MediaItem2MediaItemDB(mediaItem);
    DBService.removeMediaItemFromPlaylist(
      _mediaItemDB,
      mediaPlaylistDB,
    ).then((value) {});
  }

  Future<int?> addMediaItemToPlaylist(
    MediaItemModel mediaItemModel,
    MediaPlaylistDB mediaPlaylistDB, {
    bool undo = false,
  }) async {
    final _id = await DBService.addMediaItem(
      MediaItem2MediaItemDB(mediaItemModel),
      mediaPlaylistDB.playlistName,
    );
    // refreshLibrary.add(true);
    if (!undo) {
      SnackbarService.showMessage(
        "${mediaItemModel.title} is added to ${mediaPlaylistDB.playlistName}.",
      );
    }
    return _id;
  }

  Future<bool?> getSettingBool(String key) async {
    return await DBService.getSettingBool(key);
  }

  Future<void> putSettingBool(String key, bool value) async {
    if (key.isNotEmpty) {
      DBService.putSettingBool(key, value);
    }
  }

  Future<String?> getSettingStr(String key) async {
    return await DBService.getSettingStr(key);
  }

  Future<void> putSettingStr(String key, String value) async {
    if (key.isNotEmpty && value.isNotEmpty) {
      DBService.putSettingStr(key, value);
    }
  }

  Future<Stream<AppSettingsStrDB?>?> getWatcher4SettingStr(String key) async {
    if (key.isNotEmpty) {
      return await DBService.getWatcher4SettingStr(key);
    } else {
      return null;
    }
  }

  Future<Stream<AppSettingsBoolDB?>?> getWatcher4SettingBool(String key) async {
    if (key.isNotEmpty) {
      var _watcher = await DBService.getWatcher4SettingBool(key);
      if (_watcher != null) {
        return _watcher;
      } else {
        DBService.putSettingBool(key, false);
        return DBService.getWatcher4SettingBool(key);
      }
    } else {
      return null;
    }
  }

  @override
  Future<void> close() async {
    super.close();
  }
}
