import 'package:flutter/material.dart';
import 'package:play5/core/theme/app_colors.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key, required this.options, required this.selected, required this.onSelected});

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: options
            .map((o) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: selected == o,
                    selectedColor: AppColors.gold,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected == o ? Colors.white : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => onSelected(o),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.gold)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
