import 'package:flutter/material.dart';
import 'package:vibey/charts/home_chart/Music_charts.dart';
import 'package:vibey/models/chart.dart';
import 'package:vibey/screens/widgets/chart_list_tile.dart';
import 'package:vibey/theme/default.dart';
import 'package:go_router/go_router.dart';

class ChartScreen extends StatelessWidget {
  final String genre;

  const ChartScreen({Key? key, required this.genre, required String chartName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the chart data based on genre
    ChartModel chart = MusicCharts.getChartByGenre(genre);

    return SafeArea(
      child: Scaffold(
        body:
            chart.chartItems!.isEmpty
                ? Center(
                  child: Text(
                    "Error: No Items in Chart",
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                      const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                )
                : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    customDiscoverBar(
                      context,
                      chart.chartName,
                    ), // AppBar showing chart info
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: ChartListTile(
                              title: chart.chartItems![index].name!,
                              subtitle: chart.chartItems![index].subtitle!,
                              imgUrl: chart.chartItems![index].imageUrl!,
                            ),
                          ),
                        );
                      }, childCount: chart.chartItems?.length),
                    ),
                  ],
                ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context, String chartName) {
    return SliverAppBar(
      elevation: 8,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          context.pop();
        },
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floating: false,
      toolbarHeight: 100,
      pinned: true,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Theme.of(context).textTheme.bodyMedium!.color,
      ),
      title: Text(
        chartName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          fontSize: 28,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }
}
