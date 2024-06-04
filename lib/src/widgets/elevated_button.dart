import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final Widget destinationPage;

  CustomElevatedButton({required this.buttonText, required this.destinationPage});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Text(
        buttonText,
        style: GoogleFonts.alata(color: Colors.white, fontSize: 18  ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.green.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
    );
  }
}
