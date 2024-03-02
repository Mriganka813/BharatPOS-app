import 'package:flutter/material.dart';
import 'package:shopos/src/config/colors.dart';

enum ButtonType { normal, outlined }

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final bool isDisabled;
  final bool isLoading;
  final TextStyle? style;
  final ButtonType type;
  final double? paddingOutside;
  const CustomButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.isDisabled = false,
    this.isLoading = false,    
    this.style,
    this.padding = const EdgeInsets.all(10),
    this.type = ButtonType.normal,
    this.paddingOutside = 20.0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(paddingOutside!),
      child: TextButton(
        
        style: type == ButtonType.outlined
            ? OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDisabled ? Colors.grey : ColorsConst.primaryColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: padding,
              )
            : TextButton.styleFrom(
                backgroundColor:
                    isDisabled ? Colors.grey : ColorsConst.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: padding,
              ),
        onPressed: () {
          if (isDisabled) return;
          onTap();
        },
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                title,
                style: style ??
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                          color: type == ButtonType.normal
                              ? Colors.white
                              : ColorsConst.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
              ),
      ),
    );
  }
}
