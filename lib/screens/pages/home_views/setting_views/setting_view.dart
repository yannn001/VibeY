import 'package:vibey/modules/settings_cubit/cubit/settings_cubit.dart';
import 'package:vibey/services/UpdateChecker.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibey/theme/ThemeCubit.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).textTheme.bodyMedium!.color,
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
            children: [
              settingListTile(
                context,
                title: "Updates",
                subtitle: "Check for VibeY updates",
                icon: Icons.download_rounded,
                onTap: () async {
                  final bool updateAvailable =
                      await UpdateChecker.checkForUpdates();
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
                },
              ),
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
                },
              ),
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
              const SizedBox(height: 20),
              const Divider(
                color: Default_Theme.accentColor1,
                endIndent: 40,
                indent: 40,
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Yannn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Version: v1.0.3+3',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
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
    return ListTile(
      leading: Icon(
        icon,
        size: 27,
        color: Theme.of(context).textTheme.bodyMedium!.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontSize: 16,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(128),
          fontSize: 12,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      trailing: trailing,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}
