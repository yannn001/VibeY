// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../theme/default.dart';

// ignore: must_be_immutable
class TabSongListWidget extends StatelessWidget {
  final List<Widget> list;
  final String category;
  const TabSongListWidget({
    Key? key,
    required this.list,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                category,
                style: Default_Theme.secondoryTextStyle.merge(
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            buildCards(list, context),
          ],
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}

Widget buildCards(List<Widget> items, BuildContext context) {
  if (items.isEmpty) {
    return Container();
  }

  double itemWidth =
      MediaQuery.of(context).size.width - 40; // Full width minus padding
  double cardHeight = 85.0; // Height for each card

  // Limit the number of items to show
  int visibleItemsCount =
      items.length < 5 ? items.length : 4; // Show up to 5 items

  Color backgroundColor = Theme.of(context).cardColor;

  return SizedBox(
    height: cardHeight * visibleItemsCount + 10,
    child: ListView.builder(
      itemCount: visibleItemsCount,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling if it's inside a scrollable widget
      itemBuilder: (context, index) {
        return SizedBox(
          width: itemWidth,
          height: cardHeight, // Set card height
          child: Card(
            elevation: 0,
            color: backgroundColor, // Set background color based on theme mode
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0), // Rounded corners
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 5,
            ), // Space between cards
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding inside card
              child: Center(child: items[index]), // Center content in the card
            ),
          ),
        );
      },
    ),
  );
}
