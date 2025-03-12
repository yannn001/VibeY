// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:vibey/modules/Recently/cubit/Recently_cubit.dart';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).textTheme.bodyMedium!.color,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Recently',
            style: const TextStyle(
              color: Default_Theme.accentColor1,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        ),
        body: BlocProvider(
          create: (context) => RecentlyCubit(),
          child: BlocBuilder<RecentlyCubit, RecentlyState>(
            builder: (context, state) {
              return (state is RecentlyInitial)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: state.mediaPlaylist.mediaItems.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SongCardWidget(
                        song: state.mediaPlaylist.mediaItems[index],
                        onTap: () {
                          context
                              .read<VibeyPlayerCubit>()
                              .vibeyplayer
                              .addQueueItem(
                                state.mediaPlaylist.mediaItems[index],
                              );
                        },
                        onOptionsTap:
                            () => showMoreBottomSheet(
                              context,
                              state.mediaPlaylist.mediaItems[index],
                            ),
                      );
                    },
                  );
            },
          ),
        ),
      ),
    );
  }

  ListTile settingListTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).scaffoldBackgroundColor,
          fontSize: 17,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          fontSize: 12.5,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}
