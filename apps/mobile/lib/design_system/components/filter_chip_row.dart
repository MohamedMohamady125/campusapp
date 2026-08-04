import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// One filter option in a [FilterChipRow].
@immutable
class FilterChipOption<T> {
  const FilterChipOption({required this.label, this.value});

  final String label;

  /// `null` means "All".
  final T? value;
}

/// Single-row horizontal filter chips (whole.md §4.6).
///
/// Height 32, one horizontal ListView — never a Wrap. First chip is `All`,
/// selected by default. Value filters (price, condition) do not belong here;
/// pass [trailing] for a `Filters (n)` chip that opens a sheet.
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
    this.trailing,
  });

  final List<FilterChipOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    Widget chip(FilterChipOption<T> option) {
      final isSelected = option.value == selected;
      return Padding(
        padding: EdgeInsets.only(right: tokens.space2),
        child: FilterChip(
          label: Text(option.label),
          selected: isSelected,
          showCheckmark: false,
          backgroundColor: Colors.transparent,
          selectedColor: colors.secondaryContainer,
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: colors.outline),
          labelStyle: context.text.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
          ),
          onSelected: (_) => onSelected(option.value),
        ),
      );
    }

    return SizedBox(
      // 32dp chips + vertical breathing room to keep the 48dp target (Law 10).
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        children: [
          chip(FilterChipOption<T>(label: 'All')),
          for (final option in options) chip(option),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
