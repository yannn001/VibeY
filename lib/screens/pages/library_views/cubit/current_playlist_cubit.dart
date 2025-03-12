// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:vibey/services/db/db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';
import 'package:vibey/utils/pallete_generator.dart';
part 'current_playlist_state.dart';

class CurrentPlaylistCubit extends Cubit<CurrentPlaylistState> {
  MediaPlaylist? mediaPlaylist;
  PaletteGenerator? paletteGenerator;
  late DBCubit dbCubit;
  CurrentPlaylistCubit({this.mediaPlaylist, required this.dbCubit})
    : super(CurrentPlaylistInitial()) {}

  Future<void> setupPlaylist(String playlistName) async {
    emit(CurrentPlaylistLoading());
    mediaPlaylist = await dbCubit.getPlaylistItems(
      MediaPlaylistDB(playlistName: playlistName),
    );

    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      paletteGenerator = await getPalleteFromImage(
        mediaPlaylist!.mediaItems[0].artUri.toString(),
      );
    }
    // log(paletteGenerator.toString());
    emit(
      state.copyWith(
        playlistName: mediaPlaylist?.playlistName,
        isFetched: true,
        mediaPlaylist: mediaPlaylist,
        mediaItem: List<MediaItemModel>.from(mediaPlaylist!.mediaItems),
      ),
    );
  }

  Future<List<int>> getItemOrder() async {
    return await DBService.getPlaylistItemsRankByName(
      mediaPlaylist!.playlistName,
    );
  }

  String getTitle() {
    return state.mediaPlaylist.playlistName;
  }

  Future<void> updatePlaylist(List<int> newOrder) async {
    final oldOrder = await getItemOrder();
    if (!listEquals(newOrder, oldOrder) &&
        mediaPlaylist != null &&
        newOrder.length >= mediaPlaylist!.mediaItems.length) {
      await DBService.updatePltItemsRankByName(
        mediaPlaylist!.playlistName,
        newOrder,
      );
      final playlist = await dbCubit.getPlaylistItems(
        MediaPlaylistDB(playlistName: mediaPlaylist!.playlistName),
      );
      setupPlaylist(playlist.playlistName);
    }
  }

  int getPlaylistLength() {
    if (mediaPlaylist != null) {
      return mediaPlaylist?.mediaItems.length ?? 0;
    } else {
      return 0;
    }
  }

  String? getPlaylistCoverArt() {
    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      return mediaPlaylist?.mediaItems[0].artUri.toString();
    } else {
      return "";
    }
  }

  PaletteGenerator? getCurrentPlaylistPallete() {
    return paletteGenerator;
  }
}
