import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glider/pages/item_page.dart';
import 'package:glider/pages/user_page.dart';

class UniLinksHandler {
  UniLinksHandler._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? uriSubscription;

  static Future<void> init(BuildContext context) async {
    if (!kIsWeb) {
      uriSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) => _handleUri(context, uri),
      );
    }
  }

  static void dispose() {
    uriSubscription?.cancel();
  }

  static void _handleUri(BuildContext context, Uri? uri) {
    if (uri != null) {
      switch (uri.pathSegments.first) {
        case 'item':
          _handleItemUri(context, uri);
          break;
        case 'user':
          _handleUserUri(context, uri);
          break;
      }
    }
  }

  static void _handleItemUri(BuildContext context, Uri uri) {
    const String idKey = 'id';

    if (uri.queryParameters.containsKey(idKey)) {
      final int? id = int.tryParse(uri.queryParameters[idKey]!);

      if (id != null) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ItemPage(id: id),
          ),
        );
      }
    }
  }

  static void _handleUserUri(BuildContext context, Uri uri) {
    const String idKey = 'id';

    if (uri.queryParameters.containsKey(idKey)) {
      final String? id = uri.queryParameters[idKey];

      if (id != null) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => UserPage(id: id),
          ),
        );
      }
    }
  }
}
