import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

class LabelTextWidget extends StatelessWidget {
  const LabelTextWidget({
    super.key, required this.text,
  });

  final String text ;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          color: kRegularTextColor,
          fontSize: kSubtitleFontSize,
        ),
      ),
    );
  }
}

