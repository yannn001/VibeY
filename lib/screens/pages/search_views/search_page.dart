// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:vibey/models/source_engines.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibey/modules/fetch_data/fetch_search_results.dart';
import 'package:vibey/theme/default.dart';
import 'package:icons_plus/icons_plus.dart';

class SearchPageDelegate extends SearchDelegate {
  List<String> searchList = [];
  SourceEngine sourceEngine = SourceEngine.eng_YTM;
  ResultTypes resultType = ResultTypes.songs;
  SearchPageDelegate(this.sourceEngine, this.resultType);

  @override
  String? get searchFieldLabel => "Discover new music...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
      scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3) ??
              Colors.grey.withOpacity(0.3),
        ).merge(Default_Theme.secondoryTextStyle),
      ),
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.replaceAll(' ', '').isNotEmpty) {
      context.read<FetchSearchResultsCubit>().search(
        query,
        sourceEngine: sourceEngine,
        resultType: resultType,
      );
    }
    close(context, query);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(MingCute.close_fill),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(MingCute.arrow_left_fill),
      onPressed: () => Navigator.of(context).pop(),
      // Exit from the search screen.
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> searchResults =
        searchList
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]),
          onTap: () {
            // Handle the selected search result.
            close(context, searchResults[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return FutureBuilder(
      future: context.read<FetchSearchResultsCubit>().getSearchSuggestions(
        query,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(color: Default_Theme.accentColor1),
          );
        } else if (snapshot.data!.isEmpty) {
          return const Center(
            child: SignBoardWidget(
              message: "Nothing here",
              icon: Icons.hourglass_empty_rounded,
            ),
          );
        }
        List<String> suggestionList = snapshot.data!;
        return ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                suggestionList[index],
                style: TextStyle(
                  color: textColor,
                ).merge(Default_Theme.secondoryTextStyle),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 8),
              leading: Icon(
                MingCute.search_line,
                size: 22,
                color: textColor.withOpacity(0.5),
              ),

              onTap: () {
                query = suggestionList[index];
                showResults(context);
                // Show the search results based on the selected suggestion.
              },
            );
          },
        );
      },
    );
  }
}
