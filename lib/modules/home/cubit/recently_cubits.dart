// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'package:vibey/Repo/Youtube/yt_music_api.dart';
import 'package:vibey/utils/country_info.dart';
import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/chart.dart';
import 'package:vibey/Repo/Youtube/yt_charts_home.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'recent_states.dart';

class RecentlyCubit extends Cubit<RecentlyCubitState> {
  StreamSubscription<void>? watcher;
  RecentlyCubit() : super(RecentlyCubitInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }

  Future<void> watchRecentlyPlayed() async {
    watcher = (await DBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("Recently Played Updated");
    });
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await DBService.getRecentlyPlayed(limit: 15);
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }
}

Map<String, List<dynamic>> parseYTMusicData(String source) {
  final dynamicMap = jsonDecode(source);

  Map<String, List<dynamic>> listDynamicMap;
  if (dynamicMap is Map) {
    listDynamicMap = dynamicMap.map((key, value) {
      List<dynamic> list = [];
      if (value is List) {
        list = value;
      }
      return MapEntry(key, list);
    });
  } else {
    listDynamicMap = {};
  }
  return listDynamicMap;
}

class YTMusicCubit extends Cubit<YTMusicCubitState> {
  YTMusicCubit() : super(YTMusicCubitInitial()) {
    fetchYTMusicDB();
    fetchYTMusic();
  }

  void fetchYTMusicDB() async {
    final data = await DBService.getAPICache("YTMusic");
    if (data != null) {
      final ytmData = await compute(parseYTMusicData, data);
      if (ytmData.isNotEmpty) {
        emit(state.copyWith(ytmData: ytmData));
      }
    }
  }

  Future<void> fetchYTMusic() async {
    String countryCode = await getCountry();
    final ytCharts = await Isolate.run(
      () => YtMusicService().getMusicHome(countryCode: countryCode),
    );
    if (ytCharts.isNotEmpty) {
      emit(state.copyWith(ytmData: Map<String, List<dynamic>>.from(ytCharts)));
      final ytChartsJson = await compute(jsonEncode, ytCharts);
      DBService.putAPICache("YTMusic", ytChartsJson);
      log("YTMusic Fetched", name: "YTMusic");
    }
  }
}
