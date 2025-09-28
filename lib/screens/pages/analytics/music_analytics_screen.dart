import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:vibey/theme/default.dart';

class MusicAnalyticsScreen extends StatefulWidget {
  const MusicAnalyticsScreen({super.key});

  @override
  State<MusicAnalyticsScreen> createState() => _MusicAnalyticsScreenState();
}

class _MusicAnalyticsScreenState extends State<MusicAnalyticsScreen> {
  late Future<_AnalyticsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAnalytics();
  }

  Future<_AnalyticsData> _loadAnalytics() async {
    final Isar isar = await DBService.db;

    // Last 30 days window
    final DateTime cutoff30 = DateTime.now().subtract(const Duration(days: 30));
    final DateTime cutoff7 = DateTime.now().subtract(const Duration(days: 7));

    final recently = isar.recentlyPlayedDBs.where().findAllSync();

    // Filter by windows
    final recent30 = recently
        .where((e) => e.lastPlayed.isAfter(cutoff30))
        .toList(growable: false);
    final recent7 = recently
        .where((e) => e.lastPlayed.isAfter(cutoff7))
        .toList(growable: false);

    // Load linked media items
    for (final r in recent30) {
      await r.mediaItem.load();
    }

    // Compute aggregates (unique tracks by design, one record per track)
    final int uniqueTracks30 = recent30.length;
    final int uniqueTracks7 = recent7.length;

    // Artists and genres
    final Map<String, int> artistCounts = {};
    final Map<String, int> genreCounts = {};

    // Estimated minutes played (unique) based on stored duration metadata
    int totalSeconds30 = 0;

    // Day-of-week heat (Mon..Sun)
    final List<int> heatMap = List.filled(7, 0);

    for (final r in recent30) {
      final item = r.mediaItem.value;
      if (item == null) continue;
      final artist = item.artist;
      final genre = item.genre;
      artistCounts.update(artist, (v) => v + 1, ifAbsent: () => 1);
      genreCounts.update(genre, (v) => v + 1, ifAbsent: () => 1);
      totalSeconds30 += (item.duration ?? 0);
    }

    for (final r in recent30) {
      final int idx = r.lastPlayed.weekday - 1; // 1..7 -> 0..6 (Mon..Sun)
      if (idx >= 0 && idx < heatMap.length) {
        heatMap[idx]++;
      }
    }

    List<MapEntry<String, int>> topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, int>> topGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _AnalyticsData(
      uniqueTracks7: uniqueTracks7,
      uniqueTracks30: uniqueTracks30,
      uniqueArtists: artistCounts.length,
      totalMinutes30: (totalSeconds30 / 60).round(),
      topArtists: topArtists.take(5).toList(),
      topGenres: topGenres.take(5).toList(),
      heatMap: heatMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Music Analytics',
          style: TextStyle(
            color: Default_Theme.accentColor1,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: FutureBuilder<_AnalyticsData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final textColor = Theme.of(context).textTheme.bodyMedium!.color;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Unique Tracks (7d)',
                        value: data.uniqueTracks7.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Unique Tracks (30d)',
                        value: data.uniqueTracks30.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Minutes (30d est.)',
                        value: data.totalMinutes30.toString(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Top Artists'),
              _GlassCard(
                child: _BarList(entries: data.topArtists),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Top Genres'),
              _GlassCard(
                child: _BarList(entries: data.topGenres),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Active Days (30d)'),
              _GlassCard(
                child: _WeekHeatBar(values: data.heatMap),
              ),
              const SizedBox(height: 12),
              Text(
                'Notes: Stats estimate unique plays from Recently Played. Multiple plays of the same track within the window aren’t counted separately.',
                style: TextStyle(
                  color: textColor?.withValues(alpha: 0.6),
                  fontSize: 12,
                ).merge(Default_Theme.secondoryTextStyleMedium),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnalyticsData {
  final int uniqueTracks7;
  final int uniqueTracks30;
  final int uniqueArtists;
  final int totalMinutes30;
  final List<MapEntry<String, int>> topArtists;
  final List<MapEntry<String, int>> topGenres;
  final List<int> heatMap;
  _AnalyticsData({
    required this.uniqueTracks7,
    required this.uniqueTracks30,
    required this.uniqueArtists,
    required this.totalMinutes30,
    required this.topArtists,
    required this.topGenres,
    required this.heatMap,
  });
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
      // Slightly translucent container tuned per theme
      color: isDark
        ? scheme.surface.withValues(alpha: 0.12)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.30)
                    : Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // In light mode, a subtle tint from primary improves separation
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : scheme.primary.withValues(alpha: 0.06),
                isDark
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor?.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ).merge(Default_Theme.secondoryTextStyle),
      ),
    );
  }
}

class _BarList extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  const _BarList({required this.entries});
  @override
  Widget build(BuildContext context) {
    final max = entries.isEmpty ? 1 : entries.first.value;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyMedium!.color;
    return Column(
      children: entries.map((e) {
        final double ratio = (e.value / max).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.value.toString(),
                    style: TextStyle(
                      color: textColor?.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
          backgroundColor:
            scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _WeekHeatBar extends StatelessWidget {
  final List<int> values; // length 7, Monday..Sunday order preserved
  const _WeekHeatBar({required this.values});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final max = values.isEmpty ? 1 : (values.reduce((a, b) => a > b ? a : b));
    final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final ratio = max == 0 ? 0.0 : (values[i] / max).clamp(0.0, 1.0);
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Track
                Container(
                  width: 28,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  ),
                ),
                // Fill
                Container(
                  width: 28,
                  height: 56 * ratio,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        scheme.primary.withValues(alpha: 0.85),
                        scheme.primary.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              labels[i],
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }
}
