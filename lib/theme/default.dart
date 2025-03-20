import 'package:flutter/material.dart';

class Default_Theme {
  //Text Styles
  static const primaryTextStyle = TextStyle(fontFamily: "Fjalla");
  static const secondoryTextStyle = TextStyle(fontFamily: "Gilroy");
  static const secondoryTextStyleMedium = TextStyle(
    fontFamily: "Gilroy",
    fontWeight: FontWeight.w700,
  );
  static const tertiaryTextStyle = TextStyle(fontFamily: "CodePro");
  static const fontAwesomeRegularFont = TextStyle(
    fontFamily: "FontAwesome-Regular",
  );
  static const fontAwesomeSolidFont = TextStyle(
    fontFamily: "FontAwesome-Solids",
  );

  //Colors
  static const themeColor = Color(0xFF0A040C);
  static const primaryColor1 = Color.fromARGB(255, 255, 255, 255);
  static const primaryColor01 = Color(0xFFDAEAF7);
  static const textColor1 = Color(0xFFDAEAF7);
  static const primaryColor2 = Color.fromARGB(255, 242, 231, 240);
  static const accentColor1 = Color.fromARGB(255, 224, 14, 14);
  static const accentColor1light = Color.fromARGB(255, 237, 84, 24);
  static const accentColor2 = Color.fromARGB(255, 212, 32, 0);
  static const successColor = Color(0xFF5EFF43);
  static const searchBarColor = Color.fromARGB(255, 19, 19, 19);
  static const playerscreenbg = Color.fromARGB(255, 12, 4, 9);
  static const tablistbg = Color.fromARGB(244, 236, 237, 238);

  ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: themeColor,
    textTheme: TextTheme(bodyMedium: TextStyle(color: primaryColor1)),
    cardColor: Colors.grey[900],
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: accentColor2,
      secondary: accentColor1,
      brightness: Brightness.dark,
      surface: themeColor,
    ),
    iconTheme: const IconThemeData(color: primaryColor01),
    appBarTheme: const AppBarTheme(
      backgroundColor: themeColor,
      // elevation: 0,
      iconTheme: IconThemeData(color: primaryColor01),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentColor2,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: accentColor2,
      selectionColor: accentColor2,
      selectionHandleColor: accentColor2,
    ),
    brightness: Brightness.dark,
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(primaryColor01),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? accentColor1 : accentColor2,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? accentColor1
                : primaryColor2.withOpacity(0),
      ),
    ),
    searchBarTheme: const SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(themeColor),
    ),
  );

  ThemeData lightThemeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: primaryColor1,
    textTheme: TextTheme(bodyMedium: TextStyle(color: themeColor)),
    cardColor: Default_Theme.tablistbg,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: accentColor2,
      secondary: accentColor1,
      brightness: Brightness.light,
      surface: primaryColor1,
    ),
    iconTheme: const IconThemeData(color: themeColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor1,
      // elevation: 0,
      iconTheme: IconThemeData(color: themeColor),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentColor2,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: accentColor2,
      selectionColor: accentColor2,
      selectionHandleColor: accentColor2,
    ),
    brightness: Brightness.light,
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(themeColor),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? accentColor1 : accentColor2,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? accentColor1
                : themeColor.withOpacity(0),
      ),
    ),
    searchBarTheme: const SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(primaryColor1),
    ),
  );
}
