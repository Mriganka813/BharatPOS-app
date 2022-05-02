import 'package:flutter/material.dart';
import 'package:magicstep/src/config/colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final EdgeInsets padding;
  const CustomButton(
      {Key? key,
      required this.title,
      required this.onTap,
      this.padding = const EdgeInsets.all(10)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: ColorsConst.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: padding,
      ),
      onPressed: () {
        onTap();
      },
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
