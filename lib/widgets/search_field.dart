import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_providers.dart';

/// A reusable search field widget that adapts to the current theme.
class SearchField extends ConsumerWidget {
  /// Creates a search field widget.
  ///
  /// The [controller] is used to control the text being edited.
  /// The [hintText] is displayed when the field is empty.
  /// The [onSubmitted] callback is called when the user submits the search.
  /// The [onChanged] callback is called when the user changes the text.
  /// The [onClear] callback is called when the user clears the field.
  const SearchField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.suffixIcon,
  }) : super(key: key);

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
  Widget build(BuildContext context, WidgetRef ref) {
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
                ref.read(analyticsServiceProvider).logSearchInteraction(
                  action: 'clear',
                  query: controller.text,
                  screenName: 'search_field',
                );
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
      onSubmitted: onSubmitted != null ? (value) {
        ref.read(analyticsServiceProvider).logSearchInteraction(
          action: 'submit',
          query: value,
          screenName: 'search_field',
        );
        onSubmitted!(value);
      } : null,
      onChanged: onChanged != null ? (value) {
        if (value.isNotEmpty) {
          ref.read(analyticsServiceProvider).logSearchInteraction(
            action: 'start',
            query: value,
            screenName: 'search_field',
          );
        }
        onChanged!(value);
      } : null,
    );
  }
}
