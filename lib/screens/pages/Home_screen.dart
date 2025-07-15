import 'dart:math' as random;

import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/modules/fetch_data/fetch_albums.dart';
import 'package:vibey/modules/home/cubit/recently_cubits.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/modules/fetch_data/fetch_search_results.dart';
import 'package:vibey/screens/pages/home_views/recents_view.dart';
import 'package:vibey/screens/widgets/album_card.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/playlist_card.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:vibey/screens/pages/home_views/setting_views/setting_view.dart';
import 'package:vibey/theme/default.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/carousal_widget.dart';
import '../widgets/tabList_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SearchResultsController searchResultsController = Get.put(
    SearchResultsController(),
  );
  bool isUpdateChecked = false;
  YTMusicCubit yTMusicCubit = YTMusicCubit();

  final List<String> randomPlaylist = [
    "Feel Good",
    "Sad Songs",
    "Relaxing Music",
    "Happy Tunes",
    "Workout Mix",
    "Driving Music",
    "Dance Party",
  ];

  final List<String> randomQueries = [
    "Alec Benjamin",
    "Justin Bieber",
    "Ariana Grande",
    "Drake",
    "The Weeknd",
    "Dua Lipa",
    "Billie Eilish",
    "Ed Sheeran",
    "Taylor Swift",
    "Kanye West",
    "Beyonce",
    "Rihanna",
    "Katy Perry",
    "Lady Gaga",
    "Bruno Mars",
    "Adele",
    "Shawn Mendes",
    "Selena Gomez",
    "Sia",
    "Lana Del Rey",
    "Nicki Minaj",
    "Kendrick Lamar",
    "Eminem",
    "Post Malone",
    "Travis Scott",
    "J. Cole",
    "Khalid",
    "Lil Uzi Vert",
    "Lil Baby",
    "Lil Wayne",
    "Lil Nas X",
    "Lil Durk",
  ];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _fetchRandomList();
    _fetchRandomAlbum();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        statusBarIconBrightness: Theme.of(context).brightness,
      ),
    );
  }

  Future<void> _fetchRandomAlbum() async {
    final randomIndex = random.Random().nextInt(randomQueries.length);
    final randomQuery = randomQueries[randomIndex];

    context.read<FetchSearchResultsCubit>().fetchAlbums(randomQuery);
  }

  Future<void> _fetchRandomList() async {
    final randomIndex = random.Random().nextInt(randomPlaylist.length);
    final randomQuery = randomPlaylist[randomIndex];

    await searchResultsController.fetchHomeData(randomQuery);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RecentlyCubit>(
            create: (context) => RecentlyCubit(),
            lazy: false,
          ),
          BlocProvider(create: (context) => yTMusicCubit, lazy: false),
        ],
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await yTMusicCubit.fetchYTMusic();
              await _fetchRandomAlbum();
              await _fetchRandomList();
            },
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              slivers: [
                customBar(context),
                SliverList(
                  delegate: SliverChildListDelegate([
                    CarouselWidget(
                      imageUrls: [
                        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        'https://images.unsplash.com/photo-1602785157071-103d66e87cfc?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        'https://images.unsplash.com/photo-1707944495111-78ec6daa214d?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      ],
                      titles: ['Pop Vibes', 'Hip-Hop Heat', 'Rock Legends'],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        child: BlocBuilder<RecentlyCubit, RecentlyCubitState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20.0,
                                    10,
                                    15,
                                    1.0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const HistoryView(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Recently Played",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium!.color,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium!.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 1000),
                                  child:
                                      state is RecentlyCubitInitial
                                          ? const Center(
                                            child: SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                          : (state
                                                  .mediaPlaylist
                                                  .mediaItems
                                                  .isNotEmpty
                                              ? TabSongListWidget(
                                                list:
                                                    state.mediaPlaylist.mediaItems.map((
                                                      e,
                                                    ) {
                                                      return SongCardWidget(
                                                        song: e,
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                VibeyPlayerCubit
                                                              >()
                                                              .vibeyplayer
                                                              .updateQueue([
                                                                e,
                                                              ], doPlay: true);
                                                        },
                                                        onOptionsTap:
                                                            () =>
                                                                showMoreBottomSheet(
                                                                  context,
                                                                  e,
                                                                ),
                                                      );
                                                    }).toList(),
                                                category: " ",
                                              )
                                              : const SizedBox()),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      thickness: 2.0,
                      indent: 40,
                      endIndent: 40,
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Obx(() {
                        if (searchResultsController.loadingState.value ==
                            LState.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (searchResultsController.loadingState.value ==
                            LState.loaded) {
                          return _buildPlaylistList();
                        } else {
                          return const SignBoardWidget(
                            message: "Search your Vibes",
                            icon: Icons.hourglass_empty_rounded,
                          );
                        }
                      }),
                    ),
                    // BlocBuilder<
                    //   FetchSearchResultsCubit,
                    //   FetchSearchResultsState
                    // >(
                    //   builder: (context, fetchState) {
                    //     if (fetchState is FetchSearchResultsLoading) {
                    //       return const Center(
                    //         child: CircularProgressIndicator(
                    //           color: Colors.white,
                    //         ),
                    //       );
                    //     } else if (fetchState.loadingState ==
                    //         LoadingState.loaded) {
                    //       return _buildAlbumList(fetchState);
                    //     } else {
                    //       return const SignBoardWidget(
                    //         message: "Search your Vibes",
                    //         icon: Icons.hourglass_empty_rounded,
                    //       );
                    //     }
                    //   },
                    // ),
                  ]),
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  void requestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('onesignal_permission_asked') ?? false;

    if (!asked) {
      bool accepted = await OneSignal.Notifications.requestPermission(true);
      await prefs.setBool('onesignal_permission_asked', true);
      await prefs.setBool('onesignal_permission_accepted', accepted);
    }
  }

  // Widget _buildAlbumList(FetchSearchResultsState fetchState) {
  //   if (fetchState.albumItems.isNotEmpty) {
  //     return Align(
  //       alignment: Alignment.topCenter,
  //       child: SingleChildScrollView(
  //         physics: const BouncingScrollPhysics(),
  //         child: Wrap(
  //           alignment: WrapAlignment.center,
  //           runSpacing: 10,
  //           children:
  //               fetchState.albumItems.map((album) {
  //                 return AlbumCard(album: album);
  //               }).toList(),
  //         ),
  //       ),
  //     );
  //   } else {
  //     return const SignBoardWidget(
  //       message: "Nothing here!",
  //       icon: Icons.hourglass_empty_rounded,
  //     );
  //   }
  // }

  Widget _buildPlaylistList() {
    if (searchResultsController.playlistItems.isNotEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            children:
                searchResultsController.playlistItems.map((playlist) {
                  return PlaylistCard(
                    playlist: playlist,
                    sourceEngine: SourceEngine.eng_YTM,
                  );
                }).toList(),
          ),
        ),
      );
    } else {
      return const SignBoardWidget(
        message: "Nothing here!",
        icon: Icons.hourglass_empty_rounded,
      );
    }
  }

  SliverAppBar customBar(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 100,
      floating: true,
      centerTitle: true,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "VibeY",
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(fontSize: 38, color: Default_Theme.accentColor1),
            ),
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
            icon: Image.asset(
              'assets/icons/settings_icn.png',
              width: 30,
              height: 30,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ],
      ),
    );
  }
}
