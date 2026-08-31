import 'package:flutter/material.dart';
import 'package:glider/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Block extends HookConsumerWidget {
  const Block({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.blockColor,
      ),
      child: child,
    );
  }
}
