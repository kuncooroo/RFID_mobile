import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_color_swatch.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/search_filter.dart';
import '../repository/mock_search_repository.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key, required this.initialFilter});

  final SearchFilter initialFilter;

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late RangeValues _priceRange;
  late List<String> _selectedColorIds;
  late List<String> _selectedLocations;

  static const _priceMin = 0.0;
  static const _priceMax = 300.0;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    final min = filter.minPrice ?? _priceMin;
    final max = filter.maxPrice ?? _priceMax;
    _priceRange = RangeValues(
      min.clamp(_priceMin, _priceMax),
      max.clamp(_priceMin, _priceMax),
    );
    _minPriceController = TextEditingController(
      text: filter.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: filter.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _selectedColorIds = List<String>.from(filter.colorIds);
    _selectedLocations = List<String>.from(filter.locations);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Price Range', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          RangeSlider(
            values: _priceRange,
            min: _priceMin,
            max: _priceMax,
            divisions: 30,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
                _minPriceController.text = values.start.round().toString();
                _maxPriceController.text = values.end.round().toString();
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _minPriceController,
                  label: 'Min',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _syncRangeFromFields(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _maxPriceController,
                  label: 'Max',
                  hintText: '300',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _syncRangeFromFields(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Color', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: MockSearchRepository.filterColors.map((color) {
              final selected = _selectedColorIds.contains(color.id);
              return AppColorSwatch(
                color: _parseColor(color.hex),
                selected: selected,
                onTap: () => setState(() {
                  if (selected) {
                    _selectedColorIds.remove(color.id);
                  } else {
                    _selectedColorIds.add(color.id);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Location', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: MockSearchRepository.filterLocations.map((location) {
              final selected = _selectedLocations.contains(location);
              return AppChip(
                label: location,
                selected: selected,
                onTap: () => setState(() {
                  if (selected) {
                    _selectedLocations.remove(location);
                  } else {
                    _selectedLocations.add(location);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(
            label: 'Apply Filter',
            onPressed: () => Navigator.of(context).pop(_buildFilter()),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Reset',
            variant: AppButtonVariant.text,
            onPressed: _reset,
          ),
        ],
      ),
    );
  }

  void _syncRangeFromFields() {
    final min = double.tryParse(_minPriceController.text) ?? _priceMin;
    final max = double.tryParse(_maxPriceController.text) ?? _priceMax;
    setState(() {
      _priceRange = RangeValues(
        min.clamp(_priceMin, _priceMax),
        max.clamp(_priceMin, _priceMax),
      );
    });
  }

  SearchFilter _buildFilter() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();
    final minPrice = minText.isEmpty ? null : double.tryParse(minText);
    final maxPrice = maxText.isEmpty ? null : double.tryParse(maxText);

    return widget.initialFilter.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      colorIds: _selectedColorIds,
      locations: _selectedLocations,
      clearMinPrice: minPrice == null,
      clearMaxPrice: maxPrice == null,
    );
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(_priceMin, _priceMax);
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedColorIds = [];
      _selectedLocations = [];
    });
    Navigator.of(context).pop(
      SearchFilter(query: widget.initialFilter.query),
    );
  }

  Color _parseColor(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
