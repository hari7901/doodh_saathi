import 'package:DoodhSaathi/src/widgets/elevated_button.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../home/home_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OTPInputView extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  OTPInputView({Key? key, required this.verificationId, required this.phoneNumber}) : super(key: key);

  @override
  _OTPInputViewState createState() => _OTPInputViewState();
}

class _OTPInputViewState extends State<OTPInputView> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _animationController;
  late Animation _animation;
  bool _isLoading = false;
  late CountDownController _countDownController;
  int _remainingSeconds = 60;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: -1.0, end: 3.0).animate(_animationController);
    _countDownController = CountDownController();
    startResendTimer();

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      _remainingSeconds = 60;
    });

    _countDownController.restart(duration: _remainingSeconds);
  }

  void resendOTP() {
    // Implement your logic to resend OTP
    startResendTimer(); // Restart the timer after resending OTP
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background
          Container(
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
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'android/assets/mooFarm.png', // Replace with your actual logo asset path
                      width: MediaQuery.of(context).size.width * 1, // Adjust the size as needed
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.enterOtp,
                    style: GoogleFonts.alata(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.enterPhoneNumberToGetStarted,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 30),
                  Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF319B4B),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onCompleted: (pin) {
                      print("Completed: " + pin);
                      // Implement OTP verification logic
                    },
                  ),
                  SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                            begin: Alignment(_animation.value, 0),
                            end: Alignment(-1, 0),
                            colors: [
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _OTPEntered,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : Text(
                            AppLocalizations.of(context)!.verifyOTP,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.didNotGetCode,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5,),
                      CircularCountDownTimer(
                        width: 40,
                        height: 40,
                        duration: _remainingSeconds,
                        controller: _countDownController,
                        ringColor: Colors.white.withOpacity(0.6),
                        fillColor: Colors.white.withOpacity(0.3),
                        strokeWidth: 5.0,
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        isReverse: true,
                        isReverseAnimation: true,
                        onComplete: () {
                          resendOTP();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _OTPEntered() async {
    setState(() => _isLoading = true);
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String userId = userCredential.user!.uid;

      UserRepository userRepository = UserRepository();
      AppUser newUser = AppUser(phone: widget.phoneNumber, userId: userId, registrationDate: DateTime.timestamp());
      await userRepository.saveUser(newUser);

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeView()),
          (route)=> false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }


}


