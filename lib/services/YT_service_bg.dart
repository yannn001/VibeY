import 'dart:developer';
import 'dart:isolate';
import 'package:async/async.dart';
import 'package:vibey/Repo/Youtube/youtube_api.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/values/Strings_Const.dart';

Future<void> cacheYtStreams({
  required String id,
  required String hURL,
  required String lURL,
}) async {
  final expireAt =
      RegExp('expire=(.*?)&').firstMatch(lURL)!.group(1) ??
      (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 5.5).toString();

  try {
    DBService.putYtLinkCache(id, lURL, hURL, int.parse(expireAt));
    log("Cached: $id, ExpireAt: $expireAt", name: "CacheYtStreams");
  } catch (e) {
    log(e.toString(), name: "CacheYtStreams");
  }
}

Future<void> ytbgIsolate(List<dynamic> opts) async {
  final appDocPath = opts[0] as String;
  final appSupPath = opts[1] as String;
  final SendPort port = opts[2] as SendPort;

  DBService(appDocPath: appDocPath, appSuppPath: appSupPath);
  final yt = YouTubeServices(appDocPath: appDocPath, appSuppPath: appSupPath);

  CancelableOperation<Map?> canOprn = CancelableOperation.fromFuture(
    Future.value(null),
  );

  final ReceivePort receivePort = ReceivePort();
  port.send(receivePort.sendPort);

  receivePort.listen((dynamic data) async {
    /*
      Map<String, dynamic> =>
      {
        "mediaId": "media_id",
        "id": "video_id",
        "quality": "high"
      }*/
    if (data is Map) {
      var time = DateTime.now().millisecondsSinceEpoch;

      await canOprn.cancel();
      canOprn = CancelableOperation.fromFuture(
        yt.refreshLink(data["id"], quality: 'Low'),
        onCancel: () {
          log("Operation Cancelled-${data['id']}", name: "IsolateBG");
        },
      );

      Map? refreshedUrl = await canOprn.value;
      int quality = 2;

      await DBService.getSettingStr(GlobalStrConsts.ytStrmQuality).then((
        value,
      ) {
        if (value != null) {
          switch (value) {
            case "Low":
              quality = 1;
              break;

            case "High":
              quality = 2;
              break;
            default:
              quality = 2;
          }
        }
      });
      // YtStreams? refreshedToken = await canOprn.value;

      var time2 = DateTime.now().millisecondsSinceEpoch;
      log(
        "Time taken: ${time2 - time}ms, quality: $quality",
        name: "IsolateBG",
      );
      if (refreshedUrl!['qurls'][0] == true) {
        port.send({
          "mediaId": data["mediaId"],
          "id": data["id"],
          "quality": data["quality"],
          "link": refreshedUrl['qurls'][quality],
        });
        cacheYtStreams(
          id: data["id"],
          hURL: refreshedUrl['qurls'][2],
          lURL: refreshedUrl['qurls'][1],
        );
      } else {
        port.send({
          "mediaId": data["mediaId"],
          "id": data["id"],
          "quality": data["quality"],
          "link": null,
        });
      }
    }
  });
}
