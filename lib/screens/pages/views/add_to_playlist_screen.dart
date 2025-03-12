import 'package:vibey/modules/library/cubit/library_items_cubit.dart';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibey/modules/AddToPlaylist/cubit/add_to_playlist_cubit.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:vibey/screens/widgets/libitem_tile.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/values/Constants.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';

class AddToPlaylistScreen extends StatefulWidget {
  const AddToPlaylistScreen({super.key});

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  List<PlaylistItemProperties> playlistsItems = List.empty(growable: true);

  List<PlaylistItemProperties> filteredPlaylistsItems = List.empty(
    growable: true,
  );
  final TextEditingController _searchController = TextEditingController();

  Future<void> searchFilter(String query) async {
    if (query.length > 0) {
      setState(() {
        filteredPlaylistsItems =
            playlistsItems.where((element) {
              return element.playlistName.toLowerCase().contains(
                query.toLowerCase(),
              );
            }).toList();
      });
    } else {
      setState(() {
        filteredPlaylistsItems = playlistsItems;
      });
    }
  }

  MediaItemModel currentMediaModel = mediaItemModelNull;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add to Playlist',
          style: TextStyle(
            color: Default_Theme.accentColor1,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AddToPlaylistCubit, AddToPlaylistState>(
            builder: (context, state) {
              if (state is AddToPlaylistInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  ),
                );
              } else {
                if (state.mediaItemModel != mediaItemModelNull) {
                  currentMediaModel = state.mediaItemModel;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF262626),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: LoadImageCached(
                                imageUrl:
                                    state.mediaItemModel.artUri.toString(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.mediaItemModel.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.mediaItemModel.artist ?? "Unknown",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                if (state is LibraryItemsInitial) {
                  return const SignBoardWidget(
                    message: "No Playlists",
                    icon: MingCute.playlist_line,
                  );
                } else {
                  playlistsItems = state.playlists;
                  final finalList =
                      filteredPlaylistsItems.isEmpty ||
                              _searchController.text.isEmpty
                          ? playlistsItems
                          : filteredPlaylistsItems;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: finalList.length,
                    itemBuilder: (context, index) {
                      if (finalList[index].playlistName == "recently_played" ||
                          finalList[index].playlistName ==
                              GlobalStrConsts.downloadPlaylist) {
                        return const SizedBox();
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (currentMediaModel != mediaItemModelNull) {
                                context.read<LibraryItemsCubit>().addToPlaylist(
                                  currentMediaModel,
                                  MediaPlaylistDB(
                                    playlistName: finalList[index].playlistName,
                                  ),
                                );
                                context.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF333333),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: LoadImageCached(
                                        imageUrl:
                                            finalList[index].coverImgUrl ??
                                            "null",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          finalList[index].playlistName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          finalList[index].subTitle ??
                                              "Unverified",
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(153),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Default_Theme.accentColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                createPlaylistBottomSheet(context);
              },
              child: Text(
                "Create New Playlist",
                style: Default_Theme.secondoryTextStyle.merge(
                  const TextStyle(
                    color: Default_Theme.accentColor1,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
