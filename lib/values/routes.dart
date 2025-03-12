import 'package:vibey/screens/widgets/globalNav.dart';
import 'package:vibey/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/screens/pages/views/add_to_playlist_screen.dart';
import 'package:vibey/screens/pages/player_screen.dart';
import 'package:vibey/screens/pages/Home_screen.dart';
import 'package:vibey/screens/pages/library_screen.dart';
import 'package:vibey/screens/pages/library_views/playlist_screen.dart';
import 'package:vibey/screens/pages/search_screen.dart';
import 'package:vibey/screens/pages/chart/chart_view.dart';

class GlobalRoutes {
  static final GlobalKey<NavigatorState> globalRouterKey =
      GlobalKey<NavigatorState>();

  // Explicitly define the type of globalRouter
  static final GoRouter globalRouter = GoRouter(
    initialLocation: '/Splash',
    navigatorKey: globalRouterKey,
    routes: [
      GoRoute(
        path: '/Splash',
        builder:
            (context, state) => SplashScreen(
              onSplashComplete: () {
                globalRouter.go('/Explore');
              },
            ),
      ),
      GoRoute(
        name: GlobalStrConsts.playerScreen,
        path: "/MusicPlayer",
        parentNavigatorKey: globalRouterKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const AudioPlayerView(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                reverseCurve: Curves.easeIn,
                curve: Curves.easeInOut,
              );
              final offsetAnimation = curvedAnimation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          );
        },
      ),
      GoRoute(
        name: GlobalStrConsts.playlistView,
        // parentNavigatorKey: globalRouterKey,
        path: '/PlaylistView',
        builder: (context, state) {
          return const PlaylistView();
        },
      ),
      GoRoute(
        path: '/AddToPlaylist',
        parentNavigatorKey: globalRouterKey,
        name: GlobalStrConsts.addToPlaylistScreen,
        builder: (context, state) => const AddToPlaylistScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                GlobalFooter(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.homeScreen,
                path: '/Explore',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    name: GlobalStrConsts.ChartScreen,
                    path: 'ChartScreen:chartName',
                    builder:
                        (context, state) => ChartScreen(
                          chartName:
                              state.pathParameters['chartName'] ?? "none",
                          genre: state.pathParameters['chartName'] ?? "none",
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.searchScreen,
                path: '/Search',
                builder: (context, state) {
                  if (state.uri.queryParameters['query'] != null) {
                    return SearchScreen(
                      searchQuery:
                          state.uri.queryParameters['query']!.toString(),
                    );
                  } else {
                    return const SearchScreen();
                  }
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: GlobalStrConsts.libraryScreen,
                path: '/Library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
