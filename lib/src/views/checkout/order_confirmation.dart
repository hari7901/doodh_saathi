import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../home/home_view.dart';

class OrderConfirmationPage extends StatefulWidget {
  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppLocalizations.of(context)!.orderConfirmation,
          style: GoogleFonts.alata(color: Colors.white,fontWeight: FontWeight.bold),),
        ),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 20.0),
            Text(
              '${AppLocalizations.of(context)!.thankYouForYourOrder}!',
              style: GoogleFonts.alata(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              AppLocalizations.of(context)!.yourOrderHasBeenPlacedSuccessfully,
              style: GoogleFonts.alata(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context)=> HomeView()),
                (route) => false,
            );
          },
          child: Text(AppLocalizations.of(context)!.continueShopping,
              style: GoogleFonts.alata(
                  color: Colors.white, fontSize: 18)),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding:
            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        )
          ],
        ),
      ),
    );
  }
}
