import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/user_controller.dart';
import '../views/MenuViews/cart.dart';
import '../views/MenuViews/edit_profile_view.dart';



class CustomDrawer extends StatelessWidget {
  final UserController _userController = UserController(); // Assuming UserController is accessible here

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.teal,
                  Colors.green,
                ],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    "android/assets/mooFarm.png",
                    width: 270,
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(FontAwesomeIcons.userPen, AppLocalizations.of(context)!.editProfile, context,EditProfilePage()),
          _buildDrawerItem(FontAwesomeIcons.cartShopping, AppLocalizations.of(context)!.cart, context, CartPage()),
          _buildLogoutItem(context),
          // Add more list tiles...
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, Widget destinationPage) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );// Close the drawer
      },
      child: Container(
        height: 70,
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal.shade500],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24.0),
                SizedBox(width: 16.0),
                Text(
                  title,
                  style: GoogleFonts.alata(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return InkWell(
      onTap: () {
        _showLogoutConfirmationDialog(context);
      },
      child: Container(
        height: 70,
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal.shade500],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.exit_to_app, color: Colors.white, size: 24.0),
                SizedBox(width: 16.0),
                Text(
                  AppLocalizations.of(context)!.logOut, // You can replace this with AppLocalizations.of(context)!.logout if you have a logout translation
                  style: GoogleFonts.alata(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout Confirmation"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _userController.logout(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}