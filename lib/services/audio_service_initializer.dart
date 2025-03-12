import 'package:vibey/services/vibeyPlayer.dart';
import 'package:vibey/theme/default.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() {
    return _instance;
  }

  PlayerInitializer._internal();

  static bool _isInitialized = false;
  static Vibeyplayer? vibeyMusicPlayer;

  Future<void> _initialize() async {
    vibeyMusicPlayer = await AudioService.init(
      builder: () => Vibeyplayer(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.VibeY.notification.status',
        androidNotificationChannelName: 'VibeY',
        androidResumeOnClick: true,
        androidShowNotificationBadge: true,
        notificationColor: Default_Theme.accentColor1,
      ),
    );
  }

  Future<Vibeyplayer> getMusicPlayer() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
    return vibeyMusicPlayer!;
  }
}
