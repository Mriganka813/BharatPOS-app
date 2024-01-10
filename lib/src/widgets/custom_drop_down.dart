import 'package:flutter/material.dart';

class CustomDropDownField extends StatefulWidget {
  final List<String> items;
  final String? hintText;
  final Function(String) onSelected;
  final Function(String?)? validator;
  final String? initialValue;
  const CustomDropDownField({
    Key? key,
    required this.items,
    required this.onSelected,
    this.validator,
    this.initialValue,
    required this.hintText,
  }) : super(key: key);

  @override
  State<CustomDropDownField> createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      items: widget.items.map(
        (e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        },
      ).toList(),
      onChanged: (e) {
        // do other stuff with _category
        if (e == null) {
          return;
        }
        _selected = e;
        widget.onSelected(e);
      },
      validator: (e) {
        if (widget.validator != null) {
          return widget.validator!(e);
        }
        if (e == null || e.isEmpty) {
          return 'Please select a Business Type';
        }
        return null;
      },
      value: _selected ?? widget.initialValue,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: widget.hintText,
      ),
      iconEnabledColor: Colors.white,
    );
  }
}
