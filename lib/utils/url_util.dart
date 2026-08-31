import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glider/l10n/app_localizations.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:glider/pages/item_page.dart';
import 'package:glider/pages/user_page.dart';
import 'package:glider/providers/persistence_provider.dart';
import 'package:glider/repositories/website_repository.dart';
import 'package:glider/utils/scaffold_messenger_state_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:native_launcher/native_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UrlUtil {
  UrlUtil._();

  static Future<bool> tryLaunch(
      BuildContext context, WidgetRef ref, String urlString) async {
    final bool success = _tryNavigateInApp(context, urlString) ||
        await _tryLaunchNonBrowser(urlString) ||
        await ref.read(useCustomTabsProvider.future) &&
            await _tryLaunchCustomTab(context, urlString) ||
        await _tryLaunchPlatform(urlString);

    if (!success) {
      ScaffoldMessenger.of(context).replaceSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkError)),
      );
    }

    return success;
  }

  // Links to Hacker News items/users (e.g. a discussion cross-linked from a
  // comment) should open in-app instead of in a browser/custom tab.
  static bool _tryNavigateInApp(BuildContext context, String urlString) {
    final Uri? uri = Uri.tryParse(urlString);

    if (uri == null ||
        uri.host != WebsiteRepository.authority ||
        uri.pathSegments.length != 1) {
      return false;
    }

    switch (uri.pathSegments.first) {
      case 'item':
        // A link to a specific comment within a thread carries that comment's
        // id in the URL fragment (item?id=<story>#<comment>). Prefer it so the
        // page opens rooted at that comment - matching what happens when the
        // comment's own permalink (item?id=<comment>) is opened directly.
        final int? id = _itemIdFromFragment(uri.fragment) ??
            int.tryParse(uri.queryParameters['id'] ?? '');

        if (id != null) {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => ItemPage(id: id)),
          );
          return true;
        }
      case 'user':
        final String? id = uri.queryParameters['id'];

        if (id != null) {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => UserPage(id: id)),
          );
          return true;
        }
    }

    return false;
  }

  static int? _itemIdFromFragment(String fragment) {
    final Match? match = RegExp(r'\d+').firstMatch(fragment);
    return match != null ? int.tryParse(match[0]!) : null;
  }

  static Future<bool> _tryLaunchNonBrowser(String urlString) async {
    try {
      return await NativeLauncher.launchNonBrowser(urlString) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> _tryLaunchCustomTab(
      BuildContext context, String urlString) async {
    final AppBarThemeData appBarTheme = Theme.of(context).appBarTheme;

    try {
      await FlutterWebBrowser.openWebPage(
        url: urlString,
        customTabsOptions: CustomTabsOptions(
          defaultColorSchemeParams: CustomTabsColorSchemeParams(
            toolbarColor: appBarTheme.backgroundColor,
          ),
          shareState: CustomTabsShareState.on,
          showTitle: true,
        ),
        safariVCOptions: SafariViewControllerOptions(
          barCollapsingEnabled: true,
          preferredBarTintColor: appBarTheme.backgroundColor,
          preferredControlTintColor: appBarTheme.iconTheme?.color,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> _tryLaunchPlatform(String urlString) async {
    if (await canLaunchUrlString(urlString)) {
      return launchUrlString(
        urlString,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }
}
