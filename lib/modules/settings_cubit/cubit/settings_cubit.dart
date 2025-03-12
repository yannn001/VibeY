import 'dart:convert';
import 'dart:developer';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    initSettings();
    autoUpdate();
  }

  void initSettings() {
    // Initialize auto-update notification setting
    DBService.getSettingBool(GlobalStrConsts.autoUpdateNotify).then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });

    // Initialize auto slide charts setting
    DBService.getSettingBool(GlobalStrConsts.autoSlideCharts).then((value) {
      emit(state.copyWith(autoSlideCharts: value ?? true));
    });

    // Initialize download path setting
    String? path;
    DBService.getSettingStr(GlobalStrConsts.downPathSetting).then((
      value,
    ) async {
      await getDownloadsDirectory().then((value) {
        if (value != null) {
          path = value.path;
        }
      });
      emit(
        state.copyWith(
          downPath:
              (value ?? path) ??
              (await getApplicationDocumentsDirectory()).path,
        ),
      );
    });

    // Initialize download quality setting
    DBService.getSettingStr(
      GlobalStrConsts.downQuality,
      defaultValue: '320 kbps',
    ).then((value) {
      emit(state.copyWith(downQuality: value ?? "320 kbps"));
    });

    // Initialize YouTube download quality setting
    DBService.getSettingStr(GlobalStrConsts.ytDownQuality).then((value) {
      emit(state.copyWith(ytDownQuality: value ?? "High"));
    });

    // Initialize streaming quality setting
    DBService.getSettingStr(GlobalStrConsts.strmQuality).then((value) {
      emit(state.copyWith(strmQuality: value ?? "96 kbps"));
    });

    // Initialize YouTube streaming quality setting
    DBService.getSettingStr(GlobalStrConsts.ytStrmQuality).then((value) {
      if (value == "High" || value == "Low") {
        emit(state.copyWith(ytStrmQuality: value ?? "Low"));
      } else {
        DBService.putSettingStr(GlobalStrConsts.ytStrmQuality, "Low");
        emit(state.copyWith(ytStrmQuality: "Low"));
      }
    });

    // Initialize history clear time setting
    DBService.getSettingStr(GlobalStrConsts.historyClearTime).then((value) {
      emit(state.copyWith(historyClearTime: value ?? "30"));
    });

    // Initialize backup path setting
    DBService.getSettingStr(GlobalStrConsts.backupPath).then((value) async {
      if (value == null || value == "") {
        await DBService.putSettingStr(
          GlobalStrConsts.backupPath,
          (await getApplicationDocumentsDirectory()).path,
        );
        emit(
          state.copyWith(
            backupPath: (await getApplicationDocumentsDirectory()).path,
          ),
        );
      } else {
        emit(state.copyWith(backupPath: value));
      }
    });

    // Initialize auto backup setting
    DBService.getSettingBool(GlobalStrConsts.autoBackup).then((value) {
      emit(state.copyWith(autoBackup: value ?? false));
    });

    // Initialize auto get country setting
    DBService.getSettingBool(GlobalStrConsts.autoGetCountry).then((value) {
      emit(state.copyWith(autoGetCountry: value ?? false));
    });

    // Initialize country code setting
    DBService.getSettingStr(GlobalStrConsts.countryCode).then((value) {
      emit(state.copyWith(countryCode: value ?? "IN"));
    });

    // Initialize source engine switches
    for (var eg in SourceEngine.values) {
      DBService.getSettingBool(eg.value).then((value) {
        List<bool> switches = List.from(state.sourceEngineSwitches);
        switches[SourceEngine.values.indexOf(eg)] = value ?? true;
        emit(state.copyWith(sourceEngineSwitches: switches));
        log(switches.toString(), name: 'SettingsCubit');
      });
    }

    // Initialize chart show map setting
    Map chartMap = Map.from(state.chartMap);
    DBService.getSettingStr(GlobalStrConsts.chartShowMap).then((value) {
      if (value != null) {
        chartMap = jsonDecode(value);
      }
      emit(state.copyWith(chartMap: Map.from(chartMap)));
    });

    // Initialize Dolby setting
    DBService.getSettingBool(GlobalStrConsts.dolbyEnabled).then((value) {
      emit(state.copyWith(isDolbyEnabled: value ?? false));
    });
  }

  void autoUpdate() {
    DBService.getSettingBool(GlobalStrConsts.autoBackup).then((value) {
      if (value != null || value == true) {
        DBService.createBackUp();
      }
    });
  }

  // Method to set streaming quality
  void setStrmQuality(String value) {
    DBService.putSettingStr(GlobalStrConsts.strmQuality, value);
    emit(state.copyWith(strmQuality: value));
  }

  // Method to set YouTube streaming quality
  void setYtStrmQuality(String value) {
    DBService.putSettingStr(GlobalStrConsts.ytStrmQuality, value);
    emit(state.copyWith(ytStrmQuality: value));
  }

  // Method to toggle Dolby setting
  void toggleDolby(bool value) {
    DBService.putSettingBool(GlobalStrConsts.dolbyEnabled, value);
    emit(state.copyWith(isDolbyEnabled: value));
  }

  // Method to reset download path
  Future<void> resetDownPath() async {
    String? path;

    await getDownloadsDirectory().then((value) {
      if (value != null) {
        path = value.path;
        log(path.toString(), name: 'SettingsCubit');
      }
    });

    if (path != null) {
      DBService.putSettingStr(GlobalStrConsts.downPathSetting, path!);
      emit(state.copyWith(downPath: path));
      log(path.toString(), name: 'SettingsCubit');
    } else {
      log("Path is null", name: 'SettingsCubit');
    }
  }
}
