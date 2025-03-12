// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  bool autoUpdateNotify;
  bool autoSlideCharts;
  String downPath;
  String downQuality;
  String ytDownQuality;
  String strmQuality;
  String ytStrmQuality;
  String backupPath;
  bool autoBackup;
  String historyClearTime;
  bool autoGetCountry;
  String countryCode;
  List<bool> sourceEngineSwitches;
  Map chartMap;
  bool isDolbyEnabled; // New property to track Dolby audio state

  SettingsState({
    required this.autoUpdateNotify,
    required this.autoSlideCharts,
    required this.downPath,
    required this.downQuality,
    required this.ytDownQuality,
    required this.strmQuality,
    required this.ytStrmQuality,
    required this.backupPath,
    required this.autoBackup,
    required this.historyClearTime,
    required this.autoGetCountry,
    required this.countryCode,
    required this.sourceEngineSwitches,
    required this.chartMap,
    required this.isDolbyEnabled, // Include new property in constructor
  });

  SettingsState copyWith({
    bool? autoUpdateNotify,
    bool? autoSlideCharts,
    String? downPath,
    String? downQuality,
    String? ytDownQuality,
    String? strmQuality,
    String? ytStrmQuality,
    String? backupPath,
    bool? autoBackup,
    String? historyClearTime,
    bool? autoGetCountry,
    String? countryCode,
    List<bool>? sourceEngineSwitches,
    Map? chartMap,
    bool? isDolbyEnabled, // Add new property to copyWith
  }) {
    return SettingsState(
      autoUpdateNotify: autoUpdateNotify ?? this.autoUpdateNotify,
      autoSlideCharts: autoSlideCharts ?? this.autoSlideCharts,
      downPath: downPath ?? this.downPath,
      downQuality: downQuality ?? this.downQuality,
      ytDownQuality: ytDownQuality ?? this.ytDownQuality,
      strmQuality: strmQuality ?? this.strmQuality,
      ytStrmQuality: ytStrmQuality ?? this.ytStrmQuality,
      backupPath: backupPath ?? this.backupPath,
      autoBackup: autoBackup ?? this.autoBackup,
      historyClearTime: historyClearTime ?? this.historyClearTime,
      autoGetCountry: autoGetCountry ?? this.autoGetCountry,
      countryCode: countryCode ?? this.countryCode,
      sourceEngineSwitches:
          List.from(sourceEngineSwitches ?? this.sourceEngineSwitches),
      chartMap: Map.from(chartMap ?? this.chartMap),
      isDolbyEnabled:
          isDolbyEnabled ?? this.isDolbyEnabled, // Include in the new state
    );
  }

  @override
  List<Object?> get props => [
        autoUpdateNotify,
        autoSlideCharts,
        downPath,
        downQuality,
        ytDownQuality,
        strmQuality,
        ytStrmQuality,
        backupPath,
        autoBackup,
        historyClearTime,
        autoGetCountry,
        countryCode,
        sourceEngineSwitches,
        chartMap,
        isDolbyEnabled, // Add to the list of properties for equality comparison
      ];
}

class SettingsInitial extends SettingsState {
  SettingsInitial()
      : super(
          autoUpdateNotify: false,
          autoSlideCharts: true,
          downPath: "",
          downQuality: "320 kbps",
          ytDownQuality: "High",
          strmQuality: "96 kbps",
          ytStrmQuality: "Low",
          backupPath: "",
          autoBackup: true,
          historyClearTime: "30",
          autoGetCountry: true,
          countryCode: "IN",
          sourceEngineSwitches: SourceEngine.values.map((e) => true).toList(),
          chartMap: {},
          isDolbyEnabled: false, // Default value for Dolby setting
        );
}
