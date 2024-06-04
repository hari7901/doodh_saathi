import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.alata(
          color: Colors.white,
          fontSize: 28,
        )),
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.leftLong,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.green, // Lighter color
                Colors.teal, // Darker color
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView for scrollable content
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildCustomTextField(_nameController, 'Name', Icons.person),
            SizedBox(height: 15.0),
            _buildCustomTextField(_emailController, 'Email Address', Icons.email),
            SizedBox(height: 15.0),
            _buildCustomTextField(_companyController, 'Company Name', Icons.business),
            SizedBox(height: 25.0),
            SizedBox(
              child:_buildSubmitButton() ,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.green, // Lighter color
            Colors.teal, // Darker color
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2), // Small padding for border effect
        child: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white), // Text color
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.alata(color: Colors.white),
            prefixIcon: Icon(icon, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none, // Hides default border
            ),
            filled: true,
            fillColor: Colors.transparent, // Required for the gradient effect
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      child: Text('Save Changes', style: GoogleFonts.alata(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Color(0xFF319B4B), // Text color
        padding: EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder( // Rounded boundaries
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }


  void _submitForm() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is currently logged in')),
      );
      return;
    }
    UserService userService = UserService();

    userService.submitUserProfile(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _companyController.text.trim(),
      userId,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Updated Successfully')),
      );
      // Navigate back to HomeView after successful update
      Navigator.of(context).pop(
      ); // Use this if HomeView is the previous screen
      // OR use the following if HomeView is not the previous screen:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeView()));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $error')),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }
}
