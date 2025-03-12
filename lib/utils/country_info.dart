import 'dart:convert';
import 'dart:developer';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:http/http.dart';

Future<String> getCountry() async {
  String countryCode = "US";
  await DBService.getSettingBool(GlobalStrConsts.autoGetCountry).then((
    value,
  ) async {
    if (value != null && value == true) {
      try {
        final response = await get(Uri.parse('http://ip-api.com/json'));
        if (response.statusCode == 200) {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          countryCode = data['countryCode'];
          await DBService.putSettingStr(
            GlobalStrConsts.countryCode,
            countryCode,
          );
        }
      } catch (err) {
        await DBService.getSettingStr(GlobalStrConsts.countryCode).then((
          value,
        ) {
          if (value != null) {
            countryCode = value;
          } else {
            countryCode = "IN";
          }
        });
      }
    } else {
      await DBService.getSettingStr(GlobalStrConsts.countryCode).then((value) {
        if (value != null) {
          countryCode = value;
        } else {
          countryCode = "IN";
        }
      });
    }
  });
  log("Country Code: $countryCode");
  return countryCode;
}
