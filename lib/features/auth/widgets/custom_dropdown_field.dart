import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';

/// Dropdown personnalisé avec effet de focus moderne
class CustomDropdownField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Dropdown avec effet de focus
        FormField<T>(
          validator: widget.validator,
          builder: (formFieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: formFieldState.hasError
                          ? AppColors.error.withValues(alpha: 0.8)
                          : _isFocused
                          ? AppColors.yellow.withValues(alpha: 0.8)
                          : AppColors.white.withValues(alpha: 0.25),
                      width: _isFocused ? 2.0 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: DropdownButtonFormField<T>(
                      value: widget.value,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        prefixIcon: Icon(
                          widget.icon,
                          color: _isFocused
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      dropdownColor: AppColors.primary.withValues(alpha: 0.95),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _isFocused
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                      items: widget.items.map((T item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Text(
                            widget.itemLabel(item),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (T? newValue) {
                        widget.onChanged(newValue);
                        formFieldState.didChange(newValue);
                      },
                      validator: (_) => widget.validator?.call(widget.value),
                    ),
                  ),
                ),

                // Message d'erreur
                if (formFieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      formFieldState.errorText!,
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
