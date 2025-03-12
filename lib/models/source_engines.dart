import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/values/Strings_Const.dart';

enum SourceEngine {
  eng_YTM("Trending"),
  eng_YTV("Popular"),
  eng_JIS("Recommended");

  final String value;
  const SourceEngine(this.value);
}

Map<SourceEngine, List<String>> sourceEngineCountries = {
  SourceEngine.eng_YTM: [],
  SourceEngine.eng_YTV: [],
  SourceEngine.eng_JIS: ["IN", "NP", "BT", "LK"],
};

Future<List<SourceEngine>> availableSourceEngines() async {
  String country =
      await DBService.getSettingStr(GlobalStrConsts.countryCode) ?? "IN";
  List<SourceEngine> availSourceEngines = [];
  for (var engine in SourceEngine.values) {
    bool isAvailable = await DBService.getSettingBool(engine.value) ?? true;
    if (isAvailable == true) {
      if (sourceEngineCountries[engine]!.contains(country) ||
          sourceEngineCountries[engine]!.isEmpty) {
        availSourceEngines.add(engine);
      }
    }
  }

  return availSourceEngines;
}
