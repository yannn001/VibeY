// Page for editing playlist title,description and reordering playlist items
import 'dart:developer';
import 'dart:ui';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/screens/pages/library_views/cubit/current_playlist_cubit.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class PlaylistEditView extends StatefulWidget {
  const PlaylistEditView({super.key});

  @override
  State<PlaylistEditView> createState() => _PlaylistEditViewState();
}

class _PlaylistEditViewState extends State<PlaylistEditView> {
  TextEditingController titleController = TextEditingController();
  List<MediaItemModel> mediaItems = [];
  List<int> mediaOrder = [];
  @override
  void initState() {
    context.read<CurrentPlaylistCubit>().getItemOrder().then((value) {
      mediaOrder = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
        builder: (context, state) {
          titleController.text = state.mediaPlaylist.playlistName;
          mediaItems = state.mediaPlaylist.mediaItems;
          if (state is! CurrentPlaylistInitial &&
                  state is! CurrentPlaylistLoading ||
              state.mediaPlaylist.mediaItems.isNotEmpty) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  toolbarHeight: 90,
                  floating: true,
                  centerTitle: true,
                  iconTheme: IconThemeData(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  surfaceTintColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Text(
                    "Edit Playlist",
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                      const TextStyle(
                        fontSize: 26,
                        color: Default_Theme.accentColor1,
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          // check if title is empty or playlist already exist
                          // check if item order is changed or not
                          if (mediaItems.length == mediaOrder.length &&
                              mediaItems.isNotEmpty &&
                              titleController.text.isNotEmpty) {
                            context.read<CurrentPlaylistCubit>().updatePlaylist(
                              mediaOrder,
                            );
                            SnackbarService.showMessage("Playlist Updated!");
                          }
                          Navigator.of(context).pop();
                        },
                        padding: const EdgeInsets.only(right: 8, left: 8),
                        icon: const Icon(
                          MingCute.check_fill,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Long press to drag up or down.",
                      textAlign: TextAlign.center,
                      style: Default_Theme.secondoryTextStyleMedium.merge(
                        TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  ),
                ),
                // Sliver list of playlist items
                SliverPlaylistItems(
                  state: state,
                  updatePlaylistItems: (p0, p1) {
                    if (p0.length == p1.length &&
                        p0.length == mediaItems.length) {
                      mediaItems = p0;
                      mediaOrder = p1;
                      log("New Order: $mediaOrder");
                    }
                  },
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class SliverPlaylistItems extends StatefulWidget {
  const SliverPlaylistItems({
    Key? key,
    required this.state,
    this.updatePlaylistItems,
  }) : super(key: key);

  final CurrentPlaylistState state;
  // Callback function to update the playlistItems
  final Function(List<MediaItemModel>, List<int>)? updatePlaylistItems;

  @override
  State<SliverPlaylistItems> createState() => _SliverPlaylistItemsState();
}

class _SliverPlaylistItemsState extends State<SliverPlaylistItems> {
  List<MediaItemModel> mediaItems = [];
  List<int> mediaOrder = [];

  @override
  void initState() {
    setState(() {
      mediaItems = widget.state.mediaPlaylist.mediaItems;
    });
    context.read<CurrentPlaylistCubit>().getItemOrder().then((value) {
      mediaOrder = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      sliver: SliverReorderableList(
        itemBuilder: (context, index) {
          return ReorderableDelayedDragStartListener(
            key: ValueKey(mediaItems[index].id),
            index: index,
            child: SongCardWidget(song: mediaItems[index], showOptions: false),
          );
        },
        itemExtent: 70,
        itemCount: mediaItems.length,
        proxyDecorator: proxyDecorator,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final MediaItemModel item = mediaItems.removeAt(oldIndex);
            mediaItems.insert(newIndex, item);
            final int itemId = mediaOrder.removeAt(oldIndex);
            mediaOrder.insert(newIndex, itemId);
            if (widget.updatePlaylistItems != null) {
              widget.updatePlaylistItems!(mediaItems, mediaOrder);
            }
          });
        },
      ),
    );
  }
}

Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: const Color.fromARGB(255, 0, 48, 66),
        borderRadius: BorderRadius.circular(12),
        shadowColor: Theme.of(context).textTheme.bodyMedium!.color,
        child: child,
      );
    },
    child: child,
  );
}
