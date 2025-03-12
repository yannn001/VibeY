import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vibey/theme/default.dart';

enum LibItemTypes { userPlaylist, onlPlaylist, artist, album }

class LibItemCard extends StatelessWidget {
  final String title;
  final String coverArt;
  final String subtitle;
  final LibItemTypes type;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete; // Callback for delete action

  const LibItemCard({
    Key? key,
    required this.title,
    required this.coverArt,
    required this.subtitle,
    this.type = LibItemTypes.userPlaylist,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Slidable(
        key: ValueKey(title),
        closeOnScroll: true,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) => onDelete?.call(),
              backgroundColor: Default_Theme.accentColor1,
              foregroundColor: Colors.white,
              label: 'Delete',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        child: InkWell(
          splashColor: Default_Theme.primaryColor2.withOpacity(0.1),
          hoverColor: Colors.white.withOpacity(0.05),
          highlightColor: Default_Theme.primaryColor2.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          onTap: onTap ?? () {},
          onSecondaryTap: onSecondaryTap ?? () {},
          onLongPress: onLongPress ?? () {},
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                type == LibItemTypes.userPlaylist
                    ? StreamBuilder<String>(
                      stream:
                          context
                              .watch<VibeyPlayerCubit>()
                              .vibeyplayer
                              .queueTitle,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == title) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.asset(
                              'assets/icons/play_icn.png',
                              width: 15,
                              height: 15,
                              color: Default_Theme.accentColor1,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox.square(
                    dimension: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: switch (type) {
                        LibItemTypes.userPlaylist => LoadImageCached(
                          imageUrl: formatImgURL(
                            coverArt.toString(),
                            ImageQuality.medium,
                          ),
                        ),
                        LibItemTypes.onlPlaylist => LoadImageCached(
                          imageUrl: formatImgURL(
                            coverArt.toString(),
                            ImageQuality.medium,
                          ),
                        ),
                        LibItemTypes.artist => ClipOval(
                          child: LoadImageCached(
                            imageUrl: formatImgURL(
                              coverArt.toString(),
                              ImageQuality.medium,
                            ),
                          ),
                        ),
                        LibItemTypes.album => LoadImageCached(
                          imageUrl: formatImgURL(
                            coverArt.toString(),
                            ImageQuality.medium,
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Default_Theme.secondoryTextStyle.merge(
                          TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        style: Default_Theme.secondoryTextStyle.merge(
                          TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.fade,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
