import 'package:DoodhSaathi/src/views/auth/signup_view.dart';
import 'package:DoodhSaathi/src/views/auth/veterinary_signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChooseLogin extends StatefulWidget {
  @override
  _ChooseLogin createState() => _ChooseLogin();
}

class _ChooseLogin extends State<ChooseLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.green,
              Colors.teal,
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: SingleChildScrollView( // Ensures the view is scrollable if content doesn't fit
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'android/assets/mooFarm.png', // Your logo asset path
                  width: MediaQuery.of(context).size.width * 0.8, // Adjust the size as needed
                ),
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.alata(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                        text: AppLocalizations.of(context)!.welcome,
                        style: TextStyle(color: Colors.white)),
                    TextSpan(
                        text: ' ${AppLocalizations.of(context)!.doodh}',
                        style: TextStyle(color: Colors.green.shade900)),
                    TextSpan(
                        text: ' ${AppLocalizations.of(context)!.saathi}',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
              AppLocalizations.of(context)!.chooseYourLoginmethod,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40), // Added space before buttons for visual separation
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpView())),
                child: Text(AppLocalizations.of(context)!.userSignIn, style: GoogleFonts.alata(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF319B4B), // Button background color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Button padding
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VeterinarySignInView())),
                child: Text(AppLocalizations.of(context)!.veterinarySignIn, style: GoogleFonts.alata(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF319B4B), // Button background color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Button padding
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}