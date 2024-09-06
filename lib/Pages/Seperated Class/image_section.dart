import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageSection extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback pickImage;

  const ImageSection({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.pickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 3),
          child: imageFile != null
              ? Image.file(
                  imageFile!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : (imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          'No Image',
                          style: GoogleFonts.lato(
                              fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    )),
        ),
        // Positioned Edit Icon
        Positioned(
          top: 1,  // Positioning from the bottom
          right: 1,   // Positioning from the right
          child: InkWell(
            onTap: pickImage,
            child: const CircleAvatar(
              radius: 20, // Size of the edit icon container
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
