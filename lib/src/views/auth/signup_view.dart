import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/user_controller.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final UserController _userController = UserController();
  bool _isLoading = false;
  String _countryCode = '+91';
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: -1.0, end: 3.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.green,
                Colors.teal,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: Stack(
        children: <Widget>[
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
                      'android/assets/mooFarm.png',
                      // Replace with the path to your image
                      width: MediaQuery.of(context).size.width *
                          0.8, // Adjust the size as needed
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
                    AppLocalizations.of(context)!.enterPhoneNumberToGetStarted,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: <Widget>[
                      CountryCodePicker(
                        onChanged: (CountryCode countryCode) {
                          setState(() {
                            _countryCode = countryCode.toString();
                          });
                        },
                        initialSelection: 'भारत',
                        favorite: ['+91', 'भारत'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.phoneNumber,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone, color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                        child: _isLoading ? CircularProgressIndicator(color: Colors.white,)
                        : ElevatedButton(
                          onPressed: _isLoading ? null : _performSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 30.0),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.signIn,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSignUp() async {
    setState(() => _isLoading = true);

    String phone = _countryCode + _phoneController.text;

    try {
      // Add 'await' here to wait for the asynchronous sign-up process
       _userController.signUpWithPhone(phone, context);
    } finally {
      // Hide the circular progress indicator and reset loading state
      setState(() => _isLoading = false);
    }
  }


}
