import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibey/screens/widgets/mini_player_widget.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../theme/default.dart';

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawerScrimColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerWidget(),
            Container(
              color: Colors.transparent,
              margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
              child: HorizontalNavBar(navigationShell: navigationShell),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalNavBar extends StatelessWidget {
  const HorizontalNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return StylishBottomBar(
      option: DotBarOptions(
        dotStyle: DotStyle.tile,
        inkColor: Colors.cyanAccent,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: navigationShell.currentIndex,
      onTap: (value) {
        navigationShell.goBranch(value);
      },
      items: [
        BottomBarItem(
          icon: Image.asset(
            "assets/icons/home_icn.png",
            color: Theme.of(context).textTheme.bodyMedium!.color,
            height: 24,
            width: 24,
          ),
          title: Text('Home'),
          selectedColor: Default_Theme.accentColor1,
          unSelectedColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        BottomBarItem(
          icon: Image.asset(
            "assets/icons/search_icn.png",
            color: Theme.of(context).textTheme.bodyMedium!.color,
            height: 24,
            width: 24,
          ),
          title: Text('Search'),
          selectedColor: Default_Theme.accentColor1,
        ),
        BottomBarItem(
          icon: Image.asset(
            "assets/icons/lib_icn.png",
            color: Theme.of(context).textTheme.bodyMedium!.color,
            height: 24,
            width: 24,
          ),
          title: Text('Hub'),
          selectedColor: Default_Theme.accentColor1,
        ),
      ],
    );
  }
}
