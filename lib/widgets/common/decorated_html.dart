import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:glider/utils/url_util.dart';
import 'package:glider/widgets/common/block.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;

class DecoratedHtml extends HookConsumerWidget {
  const DecoratedHtml(
    String html, {
    super.key,
    bool prependParagraphTag = true,
  })
  // Hacker News prefixes every paragraph with a tag except the first one.
  : _html = prependParagraphTag ? '<p>$html' : html;

  final String _html;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HtmlWidget(
      _html,
      buildAsync: false,
      factoryBuilder: _DecoratedWidgetFactory.new,
      onTapUrl: (String url) => UrlUtil.tryLaunch(context, ref, url),
      textStyle: Theme.of(context).textTheme.bodyMedium,
      customStylesBuilder: (dom.Element element) =>
          element.localName == 'pre' || element.localName == 'code'
              ? <String, String>{'white-space': 'pre-wrap'}
              : null,
    );
  }
}

class _DecoratedWidgetFactory extends WidgetFactory {
  static final RegExp _quoteRegex = RegExp(r'\s*(&gt;)+\s*');
  static final RegExp _unescapedQuoteRegex = RegExp(r'\s*>+\s*');

  @override
  void parse(BuildMetadata meta) {
    final String innerHtml = meta.element.innerHtml;

    if (innerHtml.startsWith(_quoteRegex)) {
      final int quoteDepth = _quoteRegex.allMatches(innerHtml).length;
      final dom.Node? firstChild = meta.element.nodes.firstOrNull;

      if (firstChild is dom.Text) {
        firstChild.text =
            firstChild.text.replaceAll(_unescapedQuoteRegex, '');
      }

      meta.register(_buildQuoteOp(quoteDepth));
    } else {
      super.parse(meta);
    }
  }

  BuildOp _buildQuoteOp(int quoteDepth) => BuildOp(
        defaultStyles: (dom.Element element) =>
            <String, String>{'margin': '0'},
        onRenderBlock: (BuildTree tree, WidgetPlaceholder placeholder) {
          Widget child = SizedBox(width: double.infinity, child: placeholder);

          for (int i = 0; i < quoteDepth; i++) {
            child = Block(child: child);
          }

          return child;
        },
      );
}
