import 'package:vibey/models/source_engines.dart';
import 'package:vibey/Repo/Youtube/ytmusic/nav.dart';
import 'package:vibey/screens/pages/views/album_view.dart';
import 'package:vibey/screens/pages/views/artist_view.dart';
import 'package:vibey/screens/pages/views/playlist_view.dart';
import 'package:vibey/screens/pages/library_views/cubit/current_playlist_cubit.dart';
import 'package:vibey/screens/pages/library_views/more_bottomsheet.dart';
import 'package:vibey/screens/widgets/createAIplaylist_bottomsheet.dart';
import 'package:vibey/screens/widgets/importPlaylist_bottomsheet.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibey/modules/library/cubit/library_items_cubit.dart';
import 'package:vibey/values/Strings_Const.dart';
import 'package:vibey/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:vibey/screens/widgets/libitem_tile.dart';
import 'package:vibey/theme/default.dart';
import 'package:icons_plus/icons_plus.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            appBar(context),
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                if (state is LibraryItemsInitial) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is! LibraryItemsInitial) {
                  return ListOfPlaylists(state: state);
                } else {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: SignBoardWidget(
                        message: "No Playlists",
                        icon: MingCute.playlist_fill,
                      ),
                    ),
                  );
                }
              },
            ),
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                return (state is LibraryItemsInitial && state.artists.isEmpty)
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverList.builder(
                      itemBuilder:
                          (context, index) => SizedBox(
                            height: 80,
                            child: LibItemCard(
                              title: state.artists[index].name,
                              coverArt: state.artists[index].imageUrl,
                              subtitle:
                                  'Artist - ${state.artists[index].source == "ytm" ? SourceEngine.eng_YTM.value : (state.artists[index].source == 'saavn' ? SourceEngine.eng_YTM.value : SourceEngine.eng_YTV.value)}',
                              type: LibItemTypes.artist,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ArtistView(
                                          artist: state.artists[index],
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                      itemCount: state.artists.length,
                    );
              },
            ),
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                return (state is LibraryItemsInitial && state.albums.isEmpty)
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverList.builder(
                      itemBuilder:
                          (context, index) => SizedBox(
                            height: 80,
                            child: LibItemCard(
                              title: state.albums[index].name,
                              coverArt: state.albums[index].imageURL,
                              subtitle:
                                  'Album - ${state.albums[index].source == "ytm" ? SourceEngine.eng_YTM.value : (state.albums[index].source == 'saavn' ? SourceEngine.eng_YTM.value : SourceEngine.eng_YTV.value)}',
                              type: LibItemTypes.album,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AlbumView(
                                          album: state.albums[index],
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                      itemCount: state.albums.length,
                    );
              },
            ),
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                return (state is LibraryItemsInitial &&
                        state.playlistsOnl.isEmpty)
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverList.builder(
                      itemBuilder:
                          (context, index) => SizedBox(
                            height: 80,
                            child: LibItemCard(
                              title: state.playlistsOnl[index].name,
                              coverArt: state.playlistsOnl[index].imageURL,
                              subtitle:
                                  'Playlist - ${state.playlistsOnl[index].source == "ytm" ? SourceEngine.eng_YTM.value : (state.playlistsOnl[index].source == 'saavn' ? SourceEngine.eng_YTM.value : SourceEngine.eng_YTV.value)}',
                              type: LibItemTypes.onlPlaylist,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => OnlPlaylistView(
                                          playlist: state.playlistsOnl[index],
                                          sourceEngine:
                                              state
                                                          .playlistsOnl[index]
                                                          .source ==
                                                      "ytm"
                                                  ? SourceEngine.eng_YTM
                                                  : (state.playlistsOnl[index] ==
                                                          'saavn'
                                                      ? SourceEngine.eng_YTV
                                                      : SourceEngine.eng_YTV),
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                      itemCount: state.playlistsOnl.length,
                    );
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  SliverAppBar appBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      toolbarHeight: 100,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Sound Hub",
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(fontSize: 34, color: Default_Theme.accentColor1),
            ),
          ),
          const Spacer(),
          OverflowBar(
            children: [
              IconButton(
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  createPlaylistBottomSheet(context);
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  size: 25,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  showImportMediaBottomSheet(context);
                },
                icon: Icon(
                  Icons.playlist_add_check_circle_rounded,
                  size: 25,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  AIPlaylistGenerator.showAIPromptDialog(context);
                },
                icon: Image.asset('assets/icons/ai.png', width: 32, height: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ListOfPlaylists extends StatefulWidget {
  final LibraryItemsState state;
  const ListOfPlaylists({super.key, required this.state});

  @override
  State<ListOfPlaylists> createState() => _ListOfPlaylistsState();
}

class _ListOfPlaylistsState extends State<ListOfPlaylists> {
  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.state.playlists.length,
      itemBuilder: (context, index) {
        final playlist = widget.state.playlists[index];
        if (playlist.playlistName == "recently_played" ||
            playlist.playlistName == GlobalStrConsts.downloadPlaylist) {
          return const SizedBox.shrink();
        } else {
          return LibItemCard(
            title: playlist.playlistName,
            coverArt: playlist.coverImgUrl.toString(),
            subtitle: playlist.subTitle ?? "Unknown",
            onTap: () {
              context.read<CurrentPlaylistCubit>().setupPlaylist(
                playlist.playlistName,
              );
              context.pushNamed(GlobalStrConsts.playlistView);
            },
            onDelete: () {
              // Show confirmation dialog before deletion
              _showDeleteConfirmationDialog(context, playlist.playlistName);
            },
          );
        }
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String playlistName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Delete Playlist',
            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          content: Text(
            "Are you sure you want to delete the playlist '$playlistName'?",
            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Confirm deletion and close the dialog
                _deletePlaylist(playlistName);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deletePlaylist(String playlistName) {
    context.read<LibraryItemsCubit>().removePlaylist(
      MediaPlaylistDB(playlistName: playlistName),
    ); // Handle deletion via cubit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Playlist '$playlistName' deleted successfully.")),
    );
  }
}
