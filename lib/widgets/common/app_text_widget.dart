import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool softWrap;
  final TextDecoration? decoration;
  final double? height;
  final double? letterSpacing;

  const AppText(
      this.text, {
        super.key,
        this.style,
        this.color,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.fontWeight,
        this.fontSize,
        this.softWrap = true,
        this.decoration,
        this.height,
        this.letterSpacing,
      });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? TextStyles.bodyMd;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow:
      overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
      style: baseStyle.copyWith(
        color: color ?? baseStyle.color ?? AppColors.textPrimary,
        fontWeight: fontWeight ?? baseStyle.fontWeight,
        fontSize: fontSize ?? baseStyle.fontSize,
        decoration: decoration,
        height: height ?? baseStyle.height,
        letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      ),
    );
  }
}