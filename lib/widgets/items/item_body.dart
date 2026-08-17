import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:glider/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glider/models/item.dart';
import 'package:glider/models/item_tree.dart';
import 'package:glider/models/tree_item.dart';
import 'package:glider/pages/item_page.dart';
import 'package:glider/providers/item_provider.dart';
import 'package:glider/providers/persistence_provider.dart';
import 'package:glider/utils/text_style_extension.dart';
import 'package:glider/widgets/common/block.dart';
import 'package:glider/widgets/common/refreshable_body.dart';
import 'package:glider/widgets/common/sliver_smooth_animated_list.dart';
import 'package:glider/widgets/items/collapsible_item_tile.dart';
import 'package:glider/widgets/items/comment_tile_loading.dart';
import 'package:glider/widgets/items/story_tile_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ItemBody extends HookConsumerWidget {
  const ItemBody({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StreamProvider<ItemTree> provider =
        itemTreeStreamProvider(id);

    useMemoized(() => ref.invalidate(provider));

    return RefreshableBody<ItemTree>(
      provider: provider,
      onRefresh: () async => ref.invalidate(provider),
      loadingBuilder: () => <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int index) => _buildItemLoading(index),
          ),
        ),
      ],
      dataBuilder: (ItemTree itemTree) {
        Item? firstItem;
        int? parentId;

        if (itemTree.treeItems.isNotEmpty) {
          firstItem = ref
              .watch(itemNotifierProvider(itemTree.treeItems.first.id))
              .value;
          parentId = firstItem?.parent ?? firstItem?.poll;
        }

        bool isCollapsed(int id) =>
            ref.watch(collapsedProvider(id)).value ?? false;

        // Descendants of a collapsed ancestor render as nothing anyway (see
        // CollapsibleItemTile); keeping them out of the animated list
        // entirely avoids playing an insert animation for every comment that
        // streams in behind a collapsed parent.
        final Iterable<TreeItem> visibleTreeItems = itemTree.treeItems.where(
          (TreeItem treeItem) => !treeItem.ancestorIds.any(
            (int ancestorId) =>
                ancestorId != firstItem?.id && isCollapsed(ancestorId),
          ),
        );

        return <Widget>[
          if (parentId != null)
            SliverToBoxAdapter(child: _buildOpenParent(context, parentId)),
          SliverSmoothAnimatedList<TreeItem>(
            items: visibleTreeItems,
            builder: (_, TreeItem treeItem, int index) => CollapsibleItemTile(
              key: ValueKey<int>(treeItem.id),
              id: treeItem.id,
              ancestorIds: treeItem.ancestorIds,
              descendantIds: treeItem.descendantIds,
              root: firstItem,
              loading: ({int indentation = 0}) =>
                  _buildItemLoading(index, indentation: indentation),
            ),
            equalityChecker: (TreeItem a, TreeItem b) => a.id == b.id,
          ),
          if (!itemTree.done)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int index) => _buildItemLoading(
                  itemTree.treeItems.length + index,
                  indentation: itemTree.treeItems.isEmpty && index == 0 ? 0 : 1,
                ),
                childCount: firstItem?.descendants != null
                    ? firstItem!.descendants! - itemTree.treeItems.length + 1
                    : null,
              ),
            ),
        ];
      },
    );
  }

  Widget _buildItemLoading(int index, {int indentation = 0}) {
    return index == 0
        ? const StoryTileLoading()
        : CommentTileLoading(indentation: indentation);
  }

  Widget _buildOpenParent(BuildContext context, int parentId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ItemPage(id: parentId)),
        ),
        child: Hero(
          tag: 'open_parent',
          child: Block(
            child: Row(
              children: <Widget>[
                Icon(
                  FluentIcons.arrow_circle_up_24_regular,
                  size: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.scaledFontSize(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).openParent,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
