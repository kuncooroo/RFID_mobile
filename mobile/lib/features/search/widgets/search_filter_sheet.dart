import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_color_swatch.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/search_filter.dart';

/// Kutuku Filter By bottom sheet (price, color, location).
class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({
    super.key,
    required this.initialFilter,
    required this.options,
  });

  final SearchFilter initialFilter;
  final SearchFilterOptions options;

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late RangeValues _priceRange;
  late List<String> _selectedColorIds;
  late List<String> _selectedLocations;

  double get _priceMin => widget.options.minPrice;
  double get _priceMax => widget.options.maxPrice;

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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Price Range', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${formatMoney(_priceRange.start)} — ${formatMoney(_priceRange.end)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _priceMin,
                    max: _priceMax,
                    divisions: 30,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primarySoft,
                    labels: RangeLabels(
                      formatMoney(_priceRange.start),
                      formatMoney(_priceRange.end),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                        _minPriceController.text =
                            values.start.round().toString();
                        _maxPriceController.text =
                            values.end.round().toString();
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
                          hintText: _priceMax.toStringAsFixed(0),
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
                    children: widget.options.colors.map((color) {
                      final selected = _selectedColorIds.contains(color.id);
                      return Tooltip(
                        message: color.name,
                        child: AppColorSwatch(
                          color: _parseColor(color.hex),
                          selected: selected,
                          onTap: () => setState(() {
                            if (selected) {
                              _selectedColorIds.remove(color.id);
                            } else {
                              _selectedColorIds.add(color.id);
                            }
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Location', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: widget.options.locations.map((location) {
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
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Apply Filter',
            onPressed: () => Navigator.of(context).pop(_buildFilter()),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _reset,
            child: Text(
              'Reset',
              style: AppTextStyles.link,
            ),
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
    var minPrice = minText.isEmpty ? null : double.tryParse(minText);
    var maxPrice = maxText.isEmpty ? null : double.tryParse(maxText);

    // Treat full-range selection as "no price filter".
    if (minPrice != null && minPrice <= _priceMin) minPrice = null;
    if (maxPrice != null && maxPrice >= _priceMax) maxPrice = null;

    return widget.initialFilter.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      colorIds: List<String>.from(_selectedColorIds),
      locations: List<String>.from(_selectedLocations),
      clearMinPrice: minPrice == null,
      clearMaxPrice: maxPrice == null,
    );
  }

  void _reset() {
    setState(() {
      _priceRange = RangeValues(_priceMin, _priceMax);
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedColorIds = [];
      _selectedLocations = [];
    });
    Navigator.of(context).pop(
      SearchFilter(
        query: widget.initialFilter.query,
        sort: widget.initialFilter.sort,
      ),
    );
  }

  Color _parseColor(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
