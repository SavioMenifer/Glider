import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:glider/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class TileLoading extends HookConsumerWidget {
  const TileLoading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return child;
    } else {
      return Shimmer.fromColors(
        baseColor: AppTheme.blockColor,
        highlightColor: AppTheme.blockColor.withOpacity(0.25),
        child: child,
      );
    }
  }
}
