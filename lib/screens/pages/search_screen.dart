// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:vibey/modules/mediaPlayer/PlayerCubit.dart';
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/album_card.dart';
import 'package:vibey/screens/widgets/artist_card.dart';
import 'package:vibey/screens/widgets/more_bottom_sheet.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:vibey/modules/connectivity/cubit/connectivity_cubit.dart';
import 'package:vibey/modules/fetch_data/fetch_search_results.dart';
import 'package:vibey/screens/pages/search_views/search_page.dart';
import 'package:vibey/theme/default.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  const SearchScreen({Key? key, this.searchQuery = ""}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<SourceEngine> availSourceEngines;
  late SourceEngine _sourceEngine;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<ResultTypes> resultType = ValueNotifier(
    ResultTypes.songs,
  );

  @override
  void dispose() {
    _scrollController.removeListener(loadMoreResults);
    _scrollController.dispose();
    _textEditingController.dispose();
    resultType.dispose();
    super.dispose();
  }

  void loadMoreResults() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _sourceEngine == SourceEngine.eng_YTV &&
        context.read<FetchSearchResultsCubit>().state.hasReachedMax == false) {
      context.read<FetchSearchResultsCubit>().searchYTMTracks(
        _textEditingController.text,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    availSourceEngines = SourceEngine.values;
    _sourceEngine = availSourceEngines[0];

    setState(() {
      availableSourceEngines().then((value) {
        availSourceEngines = value;
        _sourceEngine = availSourceEngines[0];
      });
    });
    _scrollController.addListener(loadMoreResults);
    if (widget.searchQuery != "") {
      _textEditingController.text = widget.searchQuery;
      context.read<FetchSearchResultsCubit>().search(
        widget.searchQuery.toString(),
        sourceEngine: _sourceEngine,
        resultType: resultType.value,
      );
    }
  }

  Widget sourceEngineRadioButton(SourceEngine sourceEngine) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        height: 27,
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Easing.standardAccelerate,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _sourceEngine = sourceEngine;
                context.read<FetchSearchResultsCubit>().checkAndRefreshSearch(
                  query: _textEditingController.text.toString(),
                  sE: sourceEngine,
                  rT: resultType.value,
                );
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.only(left: 10, right: 10),
              backgroundColor:
                  _sourceEngine == sourceEngine
                      ? Theme.of(context).textTheme.bodyMedium!.color
                      : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.transparent,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Text(
              sourceEngine.value,
              style: TextStyle(
                color:
                    _sourceEngine == sourceEngine
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Theme.of(context).textTheme.bodyMedium!.color,
                fontSize: 13,
              ).merge(Default_Theme.secondoryTextStyleMedium),
            ),
          ),
        ),
      ),
    );
  }

  Widget resultTypeRadioButton(ResultTypes type) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        height: 35,
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Easing.standardAccelerate,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                resultType.value = type;
                context.read<FetchSearchResultsCubit>().checkAndRefreshSearch(
                  query: _textEditingController.text.toString(),
                  sE: _sourceEngine,
                  rT: type,
                );
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.only(left: 10, right: 10),
              backgroundColor:
                  resultType.value == type
                      ? Default_Theme.accentColor1
                      : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(
                color: Default_Theme.accentColor1,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Text(
              type.val,
              style: TextStyle(
                color:
                    resultType.value == type
                        ? Default_Theme.primaryColor2
                        : Default_Theme.accentColor1,
                fontSize: 13,
              ).merge(Default_Theme.secondoryTextStyleMedium),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        onVerticalDragEnd:
            (DragEndDetails details) =>
                FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 90,
            shadowColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            title: SizedBox(
              height: 70.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: SearchPageDelegate(
                        _sourceEngine,
                        resultType.value,
                      ),
                      query: _textEditingController.text,
                    ).then((value) {
                      if (value != null) {
                        _textEditingController.text = value.toString();
                      }
                    });
                  },
                  child: TextField(
                    controller: _textEditingController,
                    enabled: false,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.55),
                    ),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      filled: true,
                      suffixIcon: Icon(
                        MingCute.search_2_fill,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color?.withOpacity(0.4),
                      ),
                      fillColor: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color?.withAlpha(30),
                      contentPadding: const EdgeInsets.only(
                        top: 5,
                        left: 15,
                        right: 5,
                      ),
                      hintText: "What's your vibe today?",
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color?.withOpacity(0.3),
                        fontFamily: "Unageo",
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 5,
                        bottom: 5,
                      ),
                      child: FutureBuilder(
                        future: availableSourceEngines(),
                        builder: (context, snapshot) {
                          return snapshot.hasData || snapshot.data != null
                              ? Wrap(
                                direction: Axis.horizontal,
                                runSpacing: 8,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  for (var type in ResultTypes.values)
                                    resultTypeRadioButton(type),
                                  SizedBox(width: 10.0),
                                  for (var sourceEngine in availSourceEngines)
                                    sourceEngineRadioButton(sourceEngine),
                                ],
                              )
                              : const SizedBox();
                        },
                      ),
                    ),
                  ),
                ],
            body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child:
                      state == ConnectivityState.disconnected
                          ? const SignBoardWidget(
                            icon: MingCute.wifi_off_line,
                            message: "No internet connection!",
                          )
                          : BlocConsumer<
                            FetchSearchResultsCubit,
                            FetchSearchResultsState
                          >(
                            builder: (context, state) {
                              if (state is FetchSearchResultsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Default_Theme.accentColor1,
                                  ),
                                );
                              } else if (state.loadingState ==
                                  LoadingState.loaded) {
                                if (state.resultType == ResultTypes.songs &&
                                    state.mediaItems.isNotEmpty) {
                                  log(
                                    "Search Results: ${state.mediaItems.length}",
                                    name: "SearchScreen",
                                  );
                                  return ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        state.hasReachedMax
                                            ? state.mediaItems.length
                                            : state.mediaItems.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == state.mediaItems.length) {
                                        return const Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(
                                              color: Default_Theme.accentColor1,
                                            ),
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: SongCardWidget(
                                          song: state.mediaItems[index],
                                          onTap: () {
                                            context
                                                .read<VibeyPlayerCubit>()
                                                .vibeyplayer
                                                .updateQueue([
                                                  state.mediaItems[index],
                                                ], doPlay: true);
                                          },
                                          onOptionsTap:
                                              () => showMoreBottomSheet(
                                                context,
                                                state.mediaItems[index],
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (state.resultType ==
                                        ResultTypes.albums &&
                                    state.albumItems.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        runSpacing: 10,
                                        children: [
                                          for (var album in state.albumItems)
                                            AlbumCard(album: album),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (state.resultType ==
                                        ResultTypes.artists &&
                                    state.artistItems.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        runSpacing: 10,
                                        children: [
                                          for (var artist in state.artistItems)
                                            ArtistCard(artist: artist),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SignBoardWidget(
                                    message: "Not found!",
                                    icon: Icons.hourglass_empty_rounded,
                                  );
                                }
                              } else {
                                return const SignBoardWidget(
                                  message: "Search your Vibes",
                                  icon: MingCute.search_2_line,
                                );
                              }
                            },
                            listener: (
                              BuildContext context,
                              FetchSearchResultsState state,
                            ) {
                              resultType.value = state.resultType;
                              if (state is! FetchSearchResultsLoaded &&
                                  state is! FetchSearchResultsInitial) {
                                _sourceEngine =
                                    state.sourceEngine ?? _sourceEngine;
                              }
                            },
                          ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
