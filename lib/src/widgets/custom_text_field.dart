import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Function(String)? onChanged;
  final Function(String?)? onSave;
  final Function(String?)? validator;
  final Widget? prefixIcon;
  final String? hintText;
  final String? label;

  const CustomTextField({
    Key? key,
    this.onChanged,
    this.onSave,
    this.validator,
    this.hintText,
    this.label,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label ?? '',
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
          ),
        if (label != null) const SizedBox(height: 5),
        TextFormField(
          validator: (e) {
            if (validator != null) {
              return validator!(e);
            }
            if (e == null || e.isEmpty) {
              return '${label ?? "Field"} is required';
            }
            return null;
          },
          onChanged: (e) {
            if (onChanged == null) {
              return;
            }
            onChanged!(e);
          },
          onSaved: (e) {
            if (onSave == null) {
              return;
            }
            onSave!(e);
          },
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
