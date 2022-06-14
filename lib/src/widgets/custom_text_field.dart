import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final Function(String)? onChanged;
  final Function(String?)? onSave;
  final Function(String?)? validator;
  final bool isLoading;
  final String? initialValue;
  final Widget? prefixIcon;
  final String? hintText;
  final String? label;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? value;
  final Widget? suffixIcon;
  final bool obsecureText;

  const CustomTextField(
      {Key? key,
      this.onChanged,
      this.initialValue,
      this.onSave,
      this.value,
      this.validator,
      this.hintText,
      this.label,
      this.isLoading = false,
      this.inputType,
      this.suffixIcon,
      this.prefixIcon,
      this.inputFormatters,
      this.obsecureText = false})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label ?? '',
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.normal),
          ),
        if (widget.label != null) const SizedBox(height: 5),
        TextFormField(
          obscureText: widget.obsecureText,
          inputFormatters: widget.inputFormatters,
          textInputAction: TextInputAction.next,
          validator: (e) {
            if (widget.validator != null) {
              return widget.validator!(e);
            }
            if (e == null || e.isEmpty) {
              return '${widget.label ?? "Field"} is required';
            }
            return null;
          },
          controller: widget.value != null || widget.initialValue != null
              ? TextEditingController(text: widget.value ?? widget.initialValue)
              : null,
          enabled: !widget.isLoading,
          onChanged: (e) {
            if (widget.onChanged == null) {
              return;
            }
            widget.onChanged!(e);
          },
          onSaved: (e) {
            if (widget.onSave == null) {
              return;
            }
            widget.onSave!(e);
          },
          keyboardType: widget.inputType,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            hintText: widget.hintText,
            suffixIcon: widget.suffixIcon,
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
