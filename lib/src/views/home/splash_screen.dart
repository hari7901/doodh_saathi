import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/choose_login.dart';
import 'home_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _rotateAnimation;
  Animation<double>? _fadeInAnimation;
  bool _isTextVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // Duration for the rotation
      vsync: this,
    );

    _rotateAnimation = Tween(begin: 0.0, end: 2 * 3.141592653589793238).animate(_animationController!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isTextVisible = true; // Once rotation completes, show the text
          });
        }
      });

    _fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    _animationController!.forward(); // Start the rotation

    navigateToNextScreen(); // Call this function to determine which screen to navigate to
  }

  void navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Duration of splash screen

   if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeView()),
      );
      } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChooseLogin()),
      );
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.greenAccent,
                  Colors.green,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotateAnimation!,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation!.value,
                      child: child,
                    );
                  },
                  child: Center(
                    child: Image.asset(
                      'android/assets/mooFarm.png', // Replace with your actual logo asset path
                      width: MediaQuery.of(context).size.width * 1, // Adjust the size as needed
                    ),
                  ),
                ),
                SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _isTextVisible ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.alata(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: AppLocalizations.of(context)!.doodh, style: TextStyle(color: Color(0xFF319B4B))),
                        TextSpan(text: ' ${AppLocalizations.of(context)!.hari}', style: TextStyle(color: Colors.white)),
                      ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
