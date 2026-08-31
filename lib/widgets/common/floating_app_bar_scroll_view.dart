import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glider/utils/color_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FloatingAppBarScrollView extends HookConsumerWidget {
  const FloatingAppBarScrollView({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    required this.body,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget body;

  // The scrim only starts fading in once the app bar is already this far
  // hidden, then ramps to full over the remainder - rather than starting
  // the instant any downward scroll begins.
  static const double _fadeStartFraction = 0.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double appBarExtent =
        kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    // A floating SliverAppBar slides itself away in direct proportion to
    // scroll delta (not total scroll offset), reappearing the instant the
    // direction reverses regardless of how far down the list is. Mirroring
    // that same delta accumulation here - rather than thresholding on total
    // offset - lets the gradient fade in lockstep with the app bar's own
    // slide instead of snapping in only once it's fully gone.
    final ValueNotifier<double> hiddenExtent = useState<double>(0);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.axis != Axis.vertical) {
          return false;
        }

        if (notification is ScrollUpdateNotification) {
          hiddenExtent.value = (hiddenExtent.value +
                  (notification.scrollDelta ?? 0))
              .clamp(0, appBarExtent);
        }

        return false;
      },
      child: Stack(
        children: <Widget>[
          NestedScrollView(
            headerSliverBuilder: (_, bool innerBoxIsScrolled) => <Widget>[
              SliverAppBar(
                leading: _buildFluentIconsLeading(context),
                title: title,
                actions: actions,
                bottom: bottom,
                forceElevated: innerBoxIsScrolled,
                floating: true,
              ),
            ],
            floatHeaderSlivers: true,
            body: body,
          ),
          // The app bar floats away once you scroll down past its own
          // height, exposing whatever's behind the (edge-to-edge,
          // always-transparent on Android 15+) status bar. The scrim fades
          // in over that same slide, matching what's really visible there
          // instead of the app bar's own color.
          _buildStatusBarScrim(
            context,
            progress: ((hiddenExtent.value / appBarExtent -
                        _fadeStartFraction) /
                    (1 - _fadeStartFraction))
                .clamp(0, 1),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusBarScrim(
    BuildContext context, {
    required double progress,
  }) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness.isDark;
    // Dark themes keep the app bar's own (already dark) accent color, since
    // it already contrasts with the light status bar icons used there.
    // Light theme instead pairs dark status bar icons with the plain
    // scaffold background, since white/light icons only made sense against
    // the app bar's own colorful background.
    final Color scrimColor = isDark
        ? theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary
        : theme.scaffoldBackgroundColor;

    final Widget gradient = Opacity(
      opacity: progress,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                scrimColor,
                scrimColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: statusBarHeight,
      // Only take over the status bar icon color once the app bar is more
      // than halfway hidden, matching roughly where the gradient becomes
      // visually dominant, rather than flipping the instant any fade starts.
      child: progress >= 0.5
          ? AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
              child: gradient,
            )
          : gradient,
    );
  }

  static Widget? _buildFluentIconsLeading(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    if (canPop) {
      if (useCloseButton) {
        return IconButton(
          icon: const Icon(FluentIcons.dismiss_24_regular),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        );
      } else {
        return IconButton(
          icon: const Icon(FluentIcons.arrow_left_24_regular),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        );
      }
    }

    return null;
  }
}
