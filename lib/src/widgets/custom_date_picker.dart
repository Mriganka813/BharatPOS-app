import 'package:flutter/material.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

class CustomDatePicker extends StatelessWidget {
  final String? label;
  final Function(DateTime value) onChanged;
  final Function(DateTime?) onSave;
  final String? Function(DateTime?) validator;
  final DateTime? value;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDatePicker({
    required this.label,
    required this.onChanged,
    required this.onSave,
    required this.value,
    required this.validator,
    this.hintText,
    this.firstDate,
    this.lastDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: ColorsConst.primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: ColorsConst.primaryColor,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate:
                firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
            lastDate: lastDate ?? DateTime.now(),
          );
          if (date != null) {
            onChanged(date);
          }
        },
        child: Container(
          color: Colors.transparent,
          child: IgnorePointer(
            child: CustomTextField(
              onSave: (_) {
                onSave(value);
              },
              label: label,
              validator: (_) {
                return validator(value);
              },
              value: value == null
                  ? null
                  : "${value?.day}/${value?.month}/${value?.year}",
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }
}
