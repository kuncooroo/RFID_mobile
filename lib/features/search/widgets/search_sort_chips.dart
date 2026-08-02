import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_chip.dart';
import '../models/search_filter.dart';

class SearchSortChips extends StatelessWidget {
  const SearchSortChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SearchSort selected;
  final ValueChanged<SearchSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: SearchSort.values.map((sort) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppChip(
              label: sort.label,
              selected: selected == sort,
              onTap: () => onSelected(sort),
            ),
          );
        }).toList(),
      ),
    );
  }
}
