import 'package:flutter/material.dart';

/// A reusable search field widget that adapts to the current theme.
class SearchField extends StatelessWidget {
  /// Creates a search field widget.
  ///
  /// The [controller] is used to control the text being edited.
  /// The [hintText] is displayed when the field is empty.
  /// The [onSubmitted] callback is called when the user submits the search.
  /// The [onChanged] callback is called when the user changes the text.
  /// The [onClear] callback is called when the user clears the field.
  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.suffixIcon,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The hint text to display when the field is empty.
  final String hintText;

  /// Called when the user submits the search.
  final ValueChanged<String>? onSubmitted;

  /// Called when the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user clears the field.
  final VoidCallback? onClear;

  /// The suffix icon to display.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            suffixIcon ??
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                // Removed granular search interaction tracking as per analytics strategy refactor
                controller.clear();
                if (onClear != null) {
                  onClear!();
                }
              },
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.inverseSurface.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
