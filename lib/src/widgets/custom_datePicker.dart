import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final String? label;
  final Function(String)? onChanged;
  final Function(String?)? onSave;
  final String Function(String?)? validator;

  const CustomDatePicker(
      this.label, this.onChanged, this.onSave, this.validator);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
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
        Container(
          child: DateTimePicker(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'dd/mm/yyyy',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 10,
                ),
              ),
              cursorWidth: 0,
              dateHintText: 'dd/mm/yyyy',
              dateMask: 'd/MM/yyyy',
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              // dateLabelText: 'Date',
              onChanged: (e) {
                if (widget.onChanged == null) {
                  return;
                }
                widget.onChanged!(e);
              },
              validator: (e) {
                if (widget.validator != null) {
                  return widget.validator!(e);
                }
                if (e == null || e.isEmpty) {
                  return '${widget.label ?? "Field"} is required';
                }
                return null;
              },
              onSaved: (e) {
                if (widget.onSave == null) {
                  return;
                }
                widget.onSave!(e);
              }),
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(10)),
        ),
      ],
    );
  }
}
