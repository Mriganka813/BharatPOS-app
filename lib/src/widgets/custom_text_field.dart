import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final Function(String)? onChanged;
  final Function(String?)? onSave;
  final Function(String?)? validator;
  final Widget? prefixIcon;
  final String? hintText;
  final String? label;
  final TextInputType? inputType;
  final String? value;

  const CustomTextField({
    Key? key,
    this.onChanged,
    this.onSave,
    this.value,
    this.validator,
    this.hintText,
    this.label,
    this.inputType,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label ?? '',
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
          ),
        if (widget.label != null) const SizedBox(height: 5),
        TextFormField(
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
          controller: widget.value != null
              ? TextEditingController(text: widget.value)
              : _controller,
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
