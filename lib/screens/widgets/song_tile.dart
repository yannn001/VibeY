// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/utils/imgurl_formator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/load_Image.dart';

class SongCardWidget extends StatelessWidget {
  final MediaItemModel song;
  final bool? showOptions;
  final bool? showPlayBtn;
  final bool? showCopyBtn;
  final bool? delDownBtn;
  final bool? isWide;
  final VoidCallback? onOptionsTap;
  final VoidCallback? onInfoTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onDelDownTap;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SongCardWidget({
    Key? key,
    required this.song,
    this.showOptions,
    this.showPlayBtn,
    this.delDownBtn,
    this.onOptionsTap,
    this.onInfoTap,
    this.onPlayTap,
    this.onTap,
    this.onDelDownTap,
    this.showCopyBtn,
    this.isWide = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Default_Theme.primaryColor01.withOpacity(0.2),
        hoverColor: Default_Theme.primaryColor2.withOpacity(0.1),
        highlightColor: Default_Theme.primaryColor2.withOpacity(0.1),
        onTap: () {
          if (onTap != null) onTap!();
        },
        onSecondaryTap: () {
          if (onOptionsTap != null) onOptionsTap!();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 2, top: 4, bottom: 4),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: StreamBuilder<MediaItem?>(
                  stream:
                      context.read<VibeyPlayerCubit>().vibeyplayer.mediaItem,
                  builder: (context, snapshot) {
                    return (snapshot.data != null &&
                            snapshot.data?.id == song.id)
                        ? Image.asset(
                          "assets/icons/play_icn.png",
                          color: Default_Theme.accentColor1,
                          height: 15.0,
                          width: 15.0,
                        )
                        : const SizedBox();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: ClipOval(
                  child:
                      isWide ?? false
                          ? SizedBox(
                            width: 55,
                            height: 55,
                            child: LoadImageCached(
                              imageUrl: formatImgURL(
                                song.artUri.toString(),
                                ImageQuality.low,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )
                          : SizedBox(
                            width: 55,
                            height: 55,
                            child: LoadImageCached(
                              imageUrl: formatImgURL(
                                song.artUri.toString(),
                                ImageQuality.low,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        song.title,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Default_Theme.tertiaryTextStyle.merge(
                          TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      song.artist ?? 'Unknown',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Default_Theme.tertiaryTextStyle.merge(
                        TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color?.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              (showPlayBtn ?? false)
                  ? Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: IconButton(
                      icon: Icon(
                        FontAwesome.play_solid,
                        size: 30,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      onPressed: () {
                        if (onPlayTap != null) onPlayTap!();
                      },
                    ),
                  )
                  : const SizedBox(),
              (showCopyBtn ?? false)
                  ? Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Tooltip(
                      message: "Copy to clipboard",
                      child: IconButton(
                        icon: Icon(
                          MingCute.copy_2_fill,
                          size: 30,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        onPressed: () {
                          try {
                            Clipboard.setData(
                              ClipboardData(
                                text: "${song.title} by ${song.artist}",
                              ),
                            );
                            SnackbarService.showMessage(
                              "Copied to clipboard",
                              duration: const Duration(seconds: 2),
                            );
                          } catch (e) {
                            SnackbarService.showMessage(
                              "Failed to copy ${song.title}",
                            );
                          }
                        },
                      ),
                    ),
                  )
                  : const SizedBox(),
              (delDownBtn ?? false)
                  ? Padding(
                    padding: const EdgeInsets.only(left: 2, right: 0),
                    child: IconButton(
                      icon: Icon(
                        MingCute.delete_2_line,
                        size: 28,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      onPressed: () {
                        try {
                          if (context
                                  .read<VibeyPlayerCubit>()
                                  .vibeyplayer
                                  .currentMedia
                                  .id !=
                              song.id) {
                            DBService.removeDownloadDB(song);
                            SnackbarService.showMessage(
                              "Removed ${song.title}",
                            );
                          } else {
                            SnackbarService.showMessage(
                              "Cannot delete currently playing song",
                            );
                          }
                        } catch (e) {
                          DBService.removeDownloadDB(song);
                          SnackbarService.showMessage("Removed ${song.title}");
                        }
                      },
                    ),
                  )
                  : const SizedBox(),
              !(showOptions ?? true)
                  ? const SizedBox()
                  : IconButton(
                    icon: Icon(
                      MingCute.more_2_fill,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    onPressed: () {
                      if (onOptionsTap != null) onOptionsTap!();
                    },
                  ),
              trailing ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class SongCardDummyWidget extends StatelessWidget {
  const SongCardDummyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Container(
                      width: 300,
                      height: 17,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
