import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibey/Repo/Youtube/youtube_api.dart';
import 'package:vibey/models/Yt_Video.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';

class ImportPlaylistState {
  String playlistName;
  String itemName;
  int totalLength;
  int currentItem;
  ImportPlaylistState({
    required this.playlistName,
    required this.itemName,
    required this.totalLength,
    required this.currentItem,
  });

  @override
  bool operator ==(covariant ImportPlaylistState other) {
    if (identical(this, other)) return true;

    return other.playlistName == playlistName &&
        other.itemName == itemName &&
        other.totalLength == totalLength &&
        other.currentItem == currentItem;
  }

  @override
  int get hashCode {
    return playlistName.hashCode ^
        itemName.hashCode ^
        totalLength.hashCode ^
        currentItem.hashCode;
  }

  ImportPlaylistState copyWith({
    String? playlistName,
    String? itemName,
    int? totalLength,
    int? currentItem,
  }) {
    return ImportPlaylistState(
      playlistName: playlistName ?? this.playlistName,
      itemName: itemName ?? this.itemName,
      totalLength: totalLength ?? this.totalLength,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}

class ImportPlaylistStateInitial extends ImportPlaylistState {
  ImportPlaylistStateInitial()
    : super(
        playlistName: 'Loading',
        itemName: 'Loading',
        totalLength: 1,
        currentItem: 0,
      );
}

class ImportPlaylistStateComplete extends ImportPlaylistState {
  ImportPlaylistStateComplete()
    : super(
        playlistName: 'Complete',
        itemName: 'Complete',
        totalLength: 1,
        currentItem: 1,
      );
}

//------------------------------------------------------------------------------
class ImportPlaylistCubit extends Cubit<ImportPlaylistState> {
  BehaviorSubject<ImportPlaylistState> importYtPlaylistBS =
      BehaviorSubject.seeded(ImportPlaylistStateInitial());

  ImportPlaylistCubit() : super(ImportPlaylistStateInitial());
  Future<void> fetchYtPlaylistByID(String ytPlaylistID, DBCubit dbCubit) async {
    importYtPlaylistBS.add(ImportPlaylistStateInitial());
    // try {
    final result = await YouTubeServices().fetchPlaylistItems(ytPlaylistID);
    print("1 ${result.toString()}");
    final playlist = (result[0]["items"] as List);
    print("2 ${playlist.toString()}");
    if (playlist.isNotEmpty) {
      print("3");
      for (int i = 0; i < playlist.length; i++) {
        print("4 ${result[0]["metadata"]}");
        print(playlist[i].toString());
        importYtPlaylistBS.add(
          ImportPlaylistState(
            playlistName: result[0]["metadata"].title,
            itemName: playlist[i]["title"],
            totalLength: playlist.length,
            currentItem: i,
          ),
        );
        MediaItemModel mediaItemModel = fromYtVidSongMap2MediaItem(playlist[i]);
        dbCubit.addMediaItemToPlaylist(
          mediaItemModel,
          MediaPlaylistDB(playlistName: result[0]["metadata"].title),
        );
      }
    }
    importYtPlaylistBS.add(ImportPlaylistStateComplete());
    await Future.delayed(const Duration(milliseconds: 2000));
    importYtPlaylistBS.add(ImportPlaylistStateInitial());
  }

  @override
  Future<void> close() async {
    importYtPlaylistBS.close();
    super.close();
  }
}
