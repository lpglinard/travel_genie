import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Widget that provides required date range selection
/// Follows Single Responsibility Principle - only handles date range selection
class DateRangePickerField extends StatelessWidget {
  const DateRangePickerField({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
  });

  final DateTimeRange? selectedDateRange;
  final ValueChanged<DateTimeRange?> onDateRangeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selection Button
        _DateSelectionButton(
          selectedDateRange: selectedDateRange,
          onPressed: () => _showDateRangePicker(context),
        ),

        // Required helper text
        if (selectedDateRange == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Please select your travel dates',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF5B6EFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }
}

/// Button widget for date selection
/// Follows Single Responsibility Principle - only handles date button display
class _DateSelectionButton extends StatelessWidget {
  const _DateSelectionButton({
    required this.selectedDateRange,
    required this.onPressed,
  });

  final DateTimeRange? selectedDateRange;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedDateRange != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.calendar_today,
          size: 20,
          color: hasSelection
              ? const Color(0xFF5B6EFF)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        label: Row(
          children: [
            Expanded(
              child: Text(
                hasSelection
                    ? _formatDateRange(selectedDateRange!, context)
                    : AppLocalizations.of(context)!.selectDates,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasSelection
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            if (hasSelection)
              IconButton(
                onPressed: () => _clearSelection(context),
                icon: Icon(
                  Icons.clear,
                  size: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _clearSelection(BuildContext context) {
    // Find the parent DateRangePickerField and clear the selection
    final parentWidget = context
        .findAncestorWidgetOfExactType<DateRangePickerField>();
    if (parentWidget != null) {
      parentWidget.onDateRangeSelected(null);
    }
  }

  String _formatDateRange(DateTimeRange dateRange, BuildContext context) {
    final formatter = DateFormat.MMMd();
    final startFormatted = formatter.format(dateRange.start);
    final endFormatted = formatter.format(dateRange.end);

    // If same year, don't repeat it
    if (dateRange.start.year == dateRange.end.year) {
      if (dateRange.start.month == dateRange.end.month) {
        // Same month: "Oct 15 - 22"
        final dayFormatter = DateFormat.d();
        return '${DateFormat.MMM().format(dateRange.start)} ${dayFormatter.format(dateRange.start)} - ${dayFormatter.format(dateRange.end)}';
      } else {
        // Different months, same year: "Oct 15 - Nov 22"
        return '$startFormatted - $endFormatted';
      }
    } else {
      // Different years: "Dec 28, 2024 - Jan 5, 2025"
      final fullFormatter = DateFormat.yMMMd();
      return '${fullFormatter.format(dateRange.start)} - ${fullFormatter.format(dateRange.end)}';
    }
  }
}
