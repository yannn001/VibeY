import 'package:vibey/models/songModel.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/values/Strings_Const.dart';

String _sanitizeText(dynamic value, {String fallback = 'Unknown'}) {
  final String s = (value ?? '').toString().trim();
  if (s.isEmpty) return fallback;
  if (s.toLowerCase() == 'null') return fallback;
  return s;
}

MediaItemModel fromSaavnSongMap2MediaItem(Map<dynamic, dynamic> songItem) {
  return MediaItemModel(
    id: _sanitizeText(songItem["id"]),
    title: _sanitizeText(songItem["title"]),
    album: _sanitizeText(songItem["album"]),
    artist: _sanitizeText(songItem["artist"]),
    artUri: Uri.parse(_sanitizeText(songItem["image"], fallback: '')),
    genre: _sanitizeText(songItem["genre"]),
    duration: Duration(
      seconds:
          (songItem["duration"] == "null" ||
                  songItem["duration"] == null ||
                  songItem["duration"] == "")
              ? 120
              : int.parse(songItem["duration"]),
    ),
    extras: {
      "url": _sanitizeText(songItem["url"]),
      "source": "saavn",
      "perma_url": _sanitizeText(songItem["perma_url"]),
      "language": _sanitizeText(songItem["language"]),
    },
  );
}

List<MediaItemModel> fromSaavnSongMapList2MediaItemList(
  List<dynamic> songList,
) {
  List<MediaItemModel> mediaList = [];
  mediaList =
      songList
          .map((e) => fromSaavnSongMap2MediaItem(e as Map<dynamic, dynamic>))
          .toList();
  return mediaList;
}

Future<String?> getJsQualityURL(String url, {bool isStreaming = true}) async {
  String ops =
      isStreaming ? GlobalStrConsts.strmQuality : GlobalStrConsts.downQuality;
  String? kUrl;
  await DBService.getSettingStr(ops).then((value) {
    switch (value) {
      case "96 kbps":
        kUrl = url;
      case "160 kbps":
        kUrl = url.replaceAll('_96', '_160').replaceAll('_320', '_160');
      case "320 kbps":
        kUrl = url.replaceAll('_96', '_320').replaceAll('_160', '_320');
      default:
        kUrl = url.replaceAll('_160', '_96').replaceAll('_320', '_96');
    }
  });
  return kUrl;
}
