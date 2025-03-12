import 'dart:async';
import 'dart:developer';
import 'package:vibey/services/db/db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:vibey/models/MediaPlaylist.dart';
part 'Recently_state.dart';

class RecentlyCubit extends Cubit<RecentlyState> {
  StreamSubscription<void>? watcher;
  RecentlyCubit() : super(RecentlyInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }
  Future<void> watchRecentlyPlayed() async {
    watcher = (await DBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("Recently Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await DBService.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }
}
