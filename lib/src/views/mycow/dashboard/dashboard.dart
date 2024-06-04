import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/elevated_button.dart';
import 'enter_cow_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.teal, // Lighter color
                  Colors.lightGreen, // Darker color
                ],
              ),
            ),
          ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.green,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'android/assets/sell_cows.png', // Add a suitable image
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              '${AppLocalizations.of(context)!.readyToSell}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.alata(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
                buttonText: AppLocalizations.of(context)!.listYourCow,
                destinationPage: EnterCowDetailsPage()

            ),
          ],
        ),
      ),
    );
  }
}
