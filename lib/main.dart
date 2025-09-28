import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibey/Repo/Youtube/youtube_api.dart';
import 'package:vibey/modules/AddToPlaylist/cubit/add_to_playlist_cubit.dart';
import 'package:vibey/modules/connectivity/cubit/connectivity_cubit.dart';
import 'package:vibey/modules/downloader/downloader_cubit.dart';
import 'package:vibey/modules/fetch_data/fetch_albums.dart';
import 'package:vibey/modules/library/cubit/library_items_cubit.dart';
import 'package:vibey/modules/lyrics/lyrics_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/modules/mini_player/mini_player_bloc.dart';
import 'package:vibey/modules/notification/notification_cubit.dart';
import 'package:vibey/modules/fetch_data/fetch_search_results.dart';
import 'package:vibey/modules/settings_cubit/cubit/settings_cubit.dart';
import 'package:vibey/screens/pages/library_views/cubit/current_playlist_cubit.dart';
import 'package:vibey/screens/pages/library_views/cubit/import_playlist_cubit.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/services/file_manager.dart';
import 'package:vibey/services/shortcuts_intents.dart';
import 'package:vibey/theme/ThemeCubit.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/importer.dart';
import 'package:vibey/utils/urls.dart';
import 'package:vibey/values/routes.dart';

Future<void> importItems(String path) async {
  bool _res = await FileManager.importMediaItem(path);
  if (_res) {
    SnackbarService.showMessage("Media Item Imported");
  } else {
    _res = await FileManager.importPlaylist(path);
    if (_res) {
      SnackbarService.showMessage("Playlist Imported");
    } else {
      SnackbarService.showMessage("Invalid File Format");
    }
  }
}

Future<void> setHighRefreshRate() async {
  if (io.Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}

late VibeyPlayerCubit vibeyPlayerCubit;
void setupPlayerCubit() {
  vibeyPlayerCubit = VibeyPlayerCubit();
}

Future<void> initServices() async {
  String appDocPath = (await getApplicationDocumentsDirectory()).path;
  String appSuppPath = (await getApplicationSupportDirectory()).path;
  DBService(appDocPath: appDocPath, appSuppPath: appSuppPath);
  YouTubeServices(appDocPath: appDocPath, appSuppPath: appSuppPath);
}

Future<void> _ensureNotificationPermission() async {
  if (io.Platform.isAndroid) {
    // On Android 13+ (API 33), notifications require runtime permission.
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load .env file
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("6f1894eb-de73-4308-80b0-a8b5feadd6d9");
  GestureBinding.instance.resamplingEnabled = true;
  await initServices();
  await _ensureNotificationPermission();
  setHighRefreshRate();
  MetadataGod.initialize();
  setupPlayerCubit();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize the player
  // This widget is the root of your application.
  late StreamSubscription _intentSub;
  final sharedMediaFiles = <SharedMediaFile>[];
  @override
  void initState() {
    super.initState();
    if (io.Platform.isAndroid) {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((
        event,
      ) {
        sharedMediaFiles.clear();
        sharedMediaFiles.addAll(event);
        log(sharedMediaFiles[0].mimeType.toString(), name: "Shared Files");
        log(sharedMediaFiles[0].path, name: "Shared Files");

        ReceiveSharingIntent.instance.reset();
      });

      ReceiveSharingIntent.instance.getInitialMedia().then((event) {
        sharedMediaFiles.clear();
        sharedMediaFiles.addAll(event);
        log(
          sharedMediaFiles[0].mimeType.toString(),
          name: "Shared Files Offline",
        );
        log(sharedMediaFiles[0].path, name: "Shared Files Offline");
        ReceiveSharingIntent.instance.reset();
      });
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    vibeyPlayerCubit.vibeyplayer.audioPlayer.dispose();
    vibeyPlayerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => vibeyPlayerCubit, lazy: false),
              BlocProvider(
                create:
                    (context) => MiniPlayerBloc(playerCubit: vibeyPlayerCubit),
                lazy: true,
              ),
              BlocProvider(create: (context) => DBCubit(), lazy: false),
              BlocProvider(create: (context) => SettingsCubit(), lazy: false),

              BlocProvider(
                create: (context) => NotificationCubit(),
                lazy: false,
              ),

              BlocProvider(
                create: (context) => ConnectivityCubit(),
                lazy: false,
              ),
              BlocProvider(
                create:
                    (context) =>
                        CurrentPlaylistCubit(dbCubit: context.read<DBCubit>()),
                lazy: false,
              ),
              BlocProvider(
                create:
                    (context) =>
                        LibraryItemsCubit(dbCubit: context.read<DBCubit>()),
              ),
              BlocProvider(
                create: (context) => AddToPlaylistCubit(),
                lazy: false,
              ),
              BlocProvider(create: (context) => ImportPlaylistCubit()),
              BlocProvider(
                create: (context) => FetchSearchResultsCubit(),
                lazy: false,
              ),

              BlocProvider(create: (context) => LyricsCubit(vibeyPlayerCubit)),
            ],
            child: RepositoryProvider(
              create:
                  (context) => DownloaderCubit(
                    connectivityCubit: context.read<ConnectivityCubit>(),
                  ),
              lazy: false,
              child: BlocBuilder<VibeyPlayerCubit, VibeyPlayerState>(
                builder: (context, state) {
                  if (state is VibeyPlayerInitial) {
                    return const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return MaterialApp.router(
                      shortcuts: {
                        LogicalKeySet(LogicalKeyboardKey.space):
                            const PlayPauseIntent(),
                        LogicalKeySet(LogicalKeyboardKey.mediaPlayPause):
                            const PlayPauseIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                            const PreviousIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowRight):
                            const NextIntent(),
                        LogicalKeySet(LogicalKeyboardKey.keyR):
                            const RepeatIntent(),
                        LogicalKeySet(LogicalKeyboardKey.keyL):
                            const LikeIntent(),
                        LogicalKeySet(
                              LogicalKeyboardKey.arrowRight,
                              LogicalKeyboardKey.alt,
                            ):
                            const NSecForwardIntent(),
                        LogicalKeySet(
                              LogicalKeyboardKey.arrowLeft,
                              LogicalKeyboardKey.alt,
                            ):
                            const NSecBackwardIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowUp):
                            const VolumeUpIntent(),
                        LogicalKeySet(LogicalKeyboardKey.arrowDown):
                            const VolumeDownIntent(),
                      },
                      actions: {
                        PlayPauseIntent: CallbackAction(
                          onInvoke: (intent) {
                            if (context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .audioPlayer
                                .playing) {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .audioPlayer
                                  .pause();
                            } else {
                              context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .audioPlayer
                                  .play();
                            }
                            return null;
                          },
                        ),
                        NextIntent: CallbackAction(
                          onInvoke: (intent) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .skipToNext();
                            return null;
                          },
                        ),
                        PreviousIntent: CallbackAction(
                          onInvoke: (intent) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .skipToPrevious();
                            return null;
                          },
                        ),
                        NSecForwardIntent: CallbackAction(
                          onInvoke: (intent) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .seekNSecForward(const Duration(seconds: 5));
                            return null;
                          },
                        ),
                        NSecBackwardIntent: CallbackAction(
                          onInvoke: (intent) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .seekNSecBackward(const Duration(seconds: 5));
                            return null;
                          },
                        ),
                        VolumeUpIntent: CallbackAction(
                          onInvoke: (intent) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .audioPlayer
                                .setVolume(
                                  (context
                                              .read<VibeyPlayerCubit>()
                                              .vibeyplayer
                                              .audioPlayer
                                              .volume +
                                          0.1)
                                      .clamp(0.0, 1.0),
                                );
                            return null;
                          },
                        ),
                        VolumeDownIntent: CallbackAction(
                          onInvoke: (intent) {
                            context
                                .read<VibeyPlayerCubit>()
                                .vibeyplayer
                                .audioPlayer
                                .setVolume(
                                  (context
                                              .read<VibeyPlayerCubit>()
                                              .vibeyplayer
                                              .audioPlayer
                                              .volume -
                                          0.1)
                                      .clamp(0.0, 1.0),
                                );
                            return null;
                          },
                        ),
                      },
                      builder:
                          (context, child) => ResponsiveBreakpoints.builder(
                            child: child!,
                            breakpoints: [
                              const Breakpoint(
                                start: 0,
                                end: 450,
                                name: MOBILE,
                              ),
                              const Breakpoint(
                                start: 451,
                                end: 800,
                                name: TABLET,
                              ),
                              const Breakpoint(
                                start: 801,
                                end: 1920,
                                name: DESKTOP,
                              ),
                              const Breakpoint(
                                start: 1921,
                                end: double.infinity,
                                name: '4K',
                              ),
                            ],
                          ),
                      scaffoldMessengerKey: SnackbarService.messengerKey,
                      routerConfig: GlobalRoutes.globalRouter,
                      theme: Default_Theme().lightThemeData,
                      darkTheme: Default_Theme().darkThemeData,
                      themeMode: themeMode,
                      scrollBehavior: CustomScrollBehavior(),
                      debugShowCheckedModeBanner: false,
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // etc.
  };
}
