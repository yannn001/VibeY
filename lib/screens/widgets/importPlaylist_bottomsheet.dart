// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/screens/widgets/playlist_import.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/services/file_manager.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/importer.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImportType { spotifyPlaylist, youtubeMusicPlaylist, storage }

void showImportMediaBottomSheet(BuildContext context) {
  showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Import",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ).merge(Default_Theme.secondoryTextStyle),
              ),
              const SizedBox(height: 10),
              Divider(color: Default_Theme.accentColor2.withOpacity(0.5)),
              const SizedBox(height: 10),
              ImportFromBtn(
                btnName: "Playlist from Spotify",
                btnIcon: Icon(
                  FontAwesome.spotify_brand,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                onClickFunc: () {
                  Navigator.pop(context);
                  getIdAndShowBottomSheet(
                    context,
                    hintText: "https://open.spotify.com/playlist/XXXXX",
                    importType: ImportType.spotifyPlaylist,
                  );
                },
              ),
              ImportFromBtn(
                btnName: "Playlist from Youtube-Music",
                btnIcon: Image.asset(
                  'assets/icons/ytm.png',
                  width: 28,
                  height: 28,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                onClickFunc: () {
                  Navigator.pop(context);
                  getIdAndShowBottomSheet(
                    context,
                    hintText: "https://music.youtube.com/playlist?list=XXXXXX",
                    importType: ImportType.youtubeMusicPlaylist,
                  );
                },
              ),
              ImportFromBtn(
                btnName: "Playlist from Storage",
                btnIcon: Image.asset(
                  'assets/icons/storage.png',
                  width: 28,
                  height: 28,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                onClickFunc: () {
                  Navigator.pop(context);
                  FilePicker.platform.pickFiles().then((value) {
                    if (value != null) {
                      log(value.files[0].path.toString(), name: "Import File");
                      if (value.files[0].path != null) {
                        if (value.files[0].path!.endsWith('.vyb')) {
                          FileManager.importPlaylist(value.files[0].path!);
                          SnackbarService.showMessage(
                            "Started Importing Playlist",
                          );
                        } else {
                          log("Invalid File Format", name: "Import File");
                          SnackbarService.showMessage("Invalid File Format");
                        }
                      }
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Default_Theme.accentColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20,
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ImportFromBtn extends StatelessWidget {
  final String btnName;
  final Widget btnIcon; // Accepts both Icon and Image
  final VoidCallback onClickFunc;

  const ImportFromBtn({
    Key? key,
    required this.btnName,
    required this.btnIcon,
    required this.onClickFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Default_Theme.accentColor2.withOpacity(0.1),
      onTap: onClickFunc,
      title: Text(
        btnName,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color!,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ).merge(Default_Theme.secondoryTextStyle),
      ),
      leading: SizedBox(
        width: 28,
        height: 28,
        child: btnIcon, // Now supports Image.asset or Icon
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

Future<void> getIdAndShowBottomSheet(
  BuildContext context, {
  String hintText = "Playlist ID",
  required ImportType importType,
}) {
  return showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  cursorHeight: 30,
                  showCursor: true,
                  cursorWidth: 3,
                  cursorRadius: const Radius.circular(5),
                  cursorColor: Default_Theme.accentColor2,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Default_Theme.accentColor2,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color?.withOpacity(0.5),
                      fontSize: 18,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Default_Theme.primaryColor2.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Default_Theme.accentColor2,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ImporterDialogWidget(
                          strm:
                              importType == ImportType.spotifyPlaylist
                                  ? ExternalMediaImporter.sfyPlaylistImporter(
                                    url: value,
                                  )
                                  : ExternalMediaImporter.ytmPlaylistImporter(
                                    value,
                                  ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Default_Theme.accentColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
