import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glider/providers/persistence_provider.dart';
import 'package:glider/utils/color_extension.dart';
import 'package:glider/utils/swipeable_page_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppTheme {
  AppTheme._();

  static Iterable<Color> get themeColors => Colors.primaries.map(
        (MaterialColor materialColor) => <int>[300, 400, 500, 600]
            .map((int shade) => materialColor[shade]!)
            .firstWhere(
              (Color color) => color.isDark,
              orElse: () => materialColor.shade700,
            ),
      );

  static final Color defaultColor = themeColors.first;

  // A subtle neutral tint used as the fill behind inline "blocks" - code and
  // quote blocks, chips, the favicon placeholder, username tags, shimmer. Kept
  // translucent so the one value reads correctly on every background theme
  // (light, dark, black, space) without a per-theme opaque shade.
  //
  // This is deliberately NOT wired into colorScheme.surface: Material paints
  // floating overlays (most visibly the text selection toolbar) with the raw
  // surface color whenever it differs from the SDK default, and a translucent
  // surface there lets whatever is underneath bleed through the menu.
  static final Color blockColor = Colors.grey.withOpacity(0.15);
  static final Color errorColor = Colors.red.shade400;
  static const Color onErrorColor = Colors.white;
  static final Color lightBackgroundColor = Colors.grey.shade50;
  static final Color darkBackgroundColor = Colors.grey.shade900;
  static const Color blackBackgroundColor = Colors.black;
  static const Color spaceBackgroundColor = Color(0xff242933);
  static const TextStyle tallTextStyle = TextStyle(height: 1.25);

  static ThemeData lightTheme(WidgetRef ref, Color color) =>
      _buildTheme(ref, color, backgroundColor: lightBackgroundColor);

  static ThemeData darkTheme(WidgetRef ref, Color color) =>
      _buildTheme(ref, color, backgroundColor: darkBackgroundColor);

  static ThemeData blackTheme(WidgetRef ref, Color color) =>
      _buildTheme(ref, color, backgroundColor: blackBackgroundColor);

  static ThemeData spaceTheme(WidgetRef ref, Color color) =>
      _buildTheme(ref, color, backgroundColor: spaceBackgroundColor);

  static ThemeData _buildTheme(WidgetRef ref, Color color,
      {required Color backgroundColor}) {
    final Brightness brightness =
        ThemeData.estimateBrightnessForColor(backgroundColor);
    final Brightness colorBrightness =
        ThemeData.estimateBrightnessForColor(color);
    final Color onColor = colorBrightness.isDark ? Colors.white : Colors.black;
    final Color canvasColor = backgroundColor.lighten(0.05);
    // Opaque equivalent of [blockColor] over the scaffold, so components that
    // treat colorScheme.surface as a solid overlay (e.g. the text selection
    // toolbar) don't show content bleeding through.
    final Color surfaceColor = Color.alphaBlend(blockColor, backgroundColor);
    final Color appBarBackgroundColor =
        brightness.isDark ? backgroundColor : color;
    final bool appBarIsDark = brightness.isDark || colorBrightness.isDark;
    final bool useGestures = ref.watch(useGesturesProvider).value ?? true;

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
      colorScheme: brightness.isDark
          ? ColorScheme.dark(
              primary: color,
              secondary: color,
              surface: surfaceColor,
              error: errorColor,
              onPrimary: onColor,
              onSecondary: onColor,
              onError: onErrorColor,
            )
          : ColorScheme.light(
              primary: color,
              secondary: color,
              surface: surfaceColor,
              error: errorColor,
              onPrimary: onColor,
              onSecondary: onColor,
              // ignore: avoid_redundant_argument_values
              onError: onErrorColor,
            ),
      canvasColor: canvasColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: canvasColor,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: const TextTheme(
        displayLarge: tallTextStyle,
        displayMedium: tallTextStyle,
        displaySmall: tallTextStyle,
        headlineLarge: tallTextStyle,
        headlineMedium: tallTextStyle,
        headlineSmall: tallTextStyle,
        titleLarge: tallTextStyle,
        titleMedium: tallTextStyle,
        titleSmall: tallTextStyle,
        bodyLarge: tallTextStyle,
        bodyMedium: tallTextStyle,
        bodySmall: tallTextStyle,
      ),
      pageTransitionsTheme: useGestures
          ? PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                for (TargetPlatform targetPlatform in TargetPlatform.values)
                  targetPlatform: const SwipeablePageTransitionsBuilder(),
              },
            )
          : null,
      dialogBackgroundColor: canvasColor,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? color : null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? color : null,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? color : null,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        iconTheme: IconThemeData(
          color: brightness.isDark ? Colors.white : onColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarBrightness:
              appBarIsDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness:
              appBarIsDark ? Brightness.light : Brightness.dark,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
      chipTheme: ChipThemeData.fromDefaults(
        brightness: brightness,
        secondaryColor: color,
        labelStyle: const TextStyle(),
      ).copyWith(
        backgroundColor: backgroundColor,
        selectedColor: surfaceColor,
        side: MaterialStateBorderSide.resolveWith(
          (Set<MaterialState> states) => BorderSide(
            color:
                states.contains(MaterialState.selected) ? color : surfaceColor,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        valueIndicatorTextStyle: TextStyle(
          color: brightness.isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}

class SwipeablePageTransitionsBuilder extends PageTransitionsBuilder {
  const SwipeablePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SwipeablePageRouteMixin.buildPageTransitions<T>(
        route, context, animation, secondaryAnimation, child);
  }
}
