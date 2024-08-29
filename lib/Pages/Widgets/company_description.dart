import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyDescription extends StatelessWidget {
  const CompanyDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CRYO PRECISION TECHNOLOGIES',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.logoblue,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Cryo Precision Technologies (Cryptel) has been created to addresss the high demand in the aerospace industry, for reliable precision manufacturing services',
          style: GoogleFonts.openSans(
            fontSize: 13,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'We are promoted by a group of professionals with a combined experience of more than 20 years in the aerospace and defencce industries in india.',
          style: GoogleFonts.openSans(
            fontSize: 13,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'We understand both functional and assembly requirements in the aerospace industry, in terms of geometrical and dimensional tolerances and the need to meet them strictly.',
          style: GoogleFonts.openSans(
            fontSize: 13,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
