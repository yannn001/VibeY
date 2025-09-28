import 'package:vibey/modules/settings_cubit/cubit/settings_cubit.dart';
import 'package:vibey/screens/pages/analytics/music_analytics_screen.dart';
import 'package:vibey/services/UpdateChecker.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibey/theme/ThemeCubit.dart';
// navigation is performed via context.push (go_router) or Navigator; no direct import needed here

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
// removed Get dependency; using go_router for navigation
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Adjust',
          style: TextStyle(
            color: Default_Theme.accentColor1,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _GlassHeader(
                title: 'Settings',
                subtitle: 'Tune your experience',
              ),
              const SizedBox(height: 12),
              _GlassCard(
                child: Column(
                  children: [
              settingListTile(
                context,
                title: "Updates",
                subtitle: "Check for VibeY updates",
                icon: Icons.download_rounded,
                onTap: () async {
                  final bool updateAvailable =
                      await UpdateChecker.checkForUpdates();
                  if (!context.mounted) return;
                  if (updateAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('A new update is available!'),
                        action: SnackBarAction(
                          label: 'Download',
                          onPressed: () {
                            // Open the download page
                            launchUrl(Uri.parse('https://vibey.pages.dev/'));
                          },
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Your app is up to date.')),
                    );
                  }
                },
              ),
              const Divider(height: 8),
              settingListTile(
                context,
                title: "Vibe Quality",
                subtitle: "Quality of audio.",
                icon: Icons.headphones_rounded,

                trailing: DropdownButton(
                  value: state.strmQuality,
                  iconEnabledColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<SettingsCubit>().setStrmQuality(newValue);
                    }
                  },
                  items:
                      <String>[
                        '96 kbps',
                        '160 kbps',
                        '320 kbps',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
              const Divider(height: 8),
              settingListTile(
                context,
                title: "Songs Clarity",
                subtitle: "Clarity of your Songs",
                icon: Icons.earbuds,
                trailing: DropdownButton(
                  value: state.ytStrmQuality,
                  iconEnabledColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<SettingsCubit>().setYtStrmQuality(newValue);
                    }
                  },
                  items:
                      <String>['High', 'Low'].map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
              const Divider(height: 8),
              settingListTile(
                context,
                title: "Audio Settings",
                subtitle: "Open audio settings.",
                icon: Icons.volume_up,
                onTap: () async {
                  // Open general audio settings
                  final intent = AndroidIntent(
                    action: 'android.settings.SOUND_SETTINGS',
                    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                  );
                  await intent.launch();
                  if (!context.mounted) return;
                },
              ),
              const Divider(height: 8),
              settingListTile(
                context,
                title: "GitHub",
                subtitle: "Give a star on GitHub",
                icon: Icons.code,
                onTap: () async {
                  const url = 'https://github.com/yannn001/VibeY';
                  final Uri githubUrl = Uri.parse(url);

                  await launchUrl(
                    githubUrl,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!context.mounted) return;
                },
              ),
              const Divider(height: 8),
              //buy me a coffee
              settingListTile(
                context,
                title: "Support Us",
                subtitle: "Buy me a coffee",
                icon: Icons.coffee,
                onTap: () async {
                  const url = 'https://buymeacoffee.com/yannn001';
                  final Uri buyMeACoffeeUrl = Uri.parse(url);

                  await launchUrl(
                    buyMeACoffeeUrl,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!context.mounted) return;
                },
              ),
              const Divider(height: 8),
              settingListTile(
                context,
                title: "Dark Mode",
                subtitle: "Toggle dark mode",
                icon: Icons.dark_mode,
                trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme(value);
                      },
                    );
                  },
                ),
              ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _GlassCard(
                child: settingListTile(
                  context,
                  title: "Music Analytics",
                  subtitle:
                      "Gain insights into your listening habits and preferences",
                  icon: Icons.insights_rounded,
                  onTap: () {
                    Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MusicAnalyticsScreen()),
              );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _GlassCard(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Yannn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color:
                              Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version: v2.0.0+10',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ListTile settingListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final tc = Theme.of(context).textTheme.bodyMedium!.color;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      leading: Icon(icon, size: 26, color: tc),
      title: Text(
        title,
        style: TextStyle(
          color: tc,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: tc?.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? scheme.surface.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
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
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : scheme.primary.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: child,
    );
  }
}

class _GlassHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _GlassHeader({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).textTheme.bodyMedium!.color;
    return _GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: tc,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ).merge(Default_Theme.secondoryTextStyle),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: tc?.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ).merge(Default_Theme.secondoryTextStyleMedium),
              ),
            ],
          ),
          const Icon(Icons.tune_rounded, size: 22),
        ],
      ),
    );
  }
}
