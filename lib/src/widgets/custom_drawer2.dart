import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/cattle_model.dart';
import '../views/mycow/edit_cattle/add_cattle_view.dart';

class CustomDrawer2 extends StatelessWidget {
  CustomDrawer2({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.teal, Colors.green],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset("android/assets/mooFarm.png", width: 270, height: 200),
                  // Update asset path as necessary
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, FontAwesomeIcons.plus,
              AppLocalizations.of(context)!.addCattle,  AddCattlePage()),
          // Add more list tiles as needed...
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      Widget destinationPage) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destinationPage));
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.green, Colors.teal.shade500],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.0),
            const SizedBox(width: 16.0),
            Text(title,
                style: GoogleFonts.alata(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

}
