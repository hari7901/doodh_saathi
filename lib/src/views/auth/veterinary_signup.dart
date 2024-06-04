import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/user_controller.dart';
import '../../services/identity_storage.dart';
import '../home/home_view.dart';
import '../vet_view/veterinary_view.dart';

class VeterinarySignInView extends StatefulWidget {
  @override
  _VeterinarySignInViewState createState() => _VeterinarySignInViewState();
}

class _VeterinarySignInViewState extends State<VeterinarySignInView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _proofOfIdentity;
  bool _isLoading = false;


  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserController _userController = UserController();

  Future<void> _pickProofOfIdentity(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _proofOfIdentity = File(pickedFile.path);
      });
    }
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    // Add more password criteria if needed
    return null;
  }

  void _showPickOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Photo Library'),
                  onTap: () {
                    _pickProofOfIdentity(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    _pickProofOfIdentity(ImageSource.camera);
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      },
    );
  }

  void _attemptSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Set loading state to true
        setState(() {
          _isLoading = true;
        });

        String? imageUrl;
        if (_proofOfIdentity != null) {
          // Use the FirebaseStorageService to upload the file
          FirebaseStorageService storageService = FirebaseStorageService();
          imageUrl = await storageService.uploadFile(_proofOfIdentity!);
        }

        // Continue with user creation and data storage as before
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('veterinary_registered')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'registrationDate': DateTime.now(),
            'proofOfIdentityUrl': imageUrl, // Store the uploaded file URL
          });

          // Hide loading indicator
          setState(() {
            _isLoading = false;
          });

          Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => VetView()),
            (route) => false
          );
        }
      } catch (e) {
        // Hide loading indicator
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sign up failed: ${e.toString()}")));
      }
    } else {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in the form correctly.")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
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
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Incorporating the aesthetic elements of your original design
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.alata(
                          fontSize: 26, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Welcome to ',
                            style: TextStyle(color: Colors.white)),
                        TextSpan(
                            text: 'Dhoodh',
                            style: TextStyle(color: Colors.green.shade900)),
                        TextSpan(
                            text: ' Saathi',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  style: TextStyle(color: Colors.white),
                  // Set text color to white
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.white),
                    // Set label text color to white
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    // Set icon color to white
                    enabledBorder: OutlineInputBorder(
                      // Normal state border
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Focused state border
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                        color: Colors.white
                            .withOpacity(0.6)), // Set hint text color to white
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  style: TextStyle(color: Colors.white),
                  // Set text color to white
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.white),
                    // Set label text color to white
                    prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                    // Set icon color to white
                    enabledBorder: OutlineInputBorder(
                      // Normal state border
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Focused state border
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _phoneController,
                  style: TextStyle(color: Colors.white),
                  // Set text color to white
                  decoration: InputDecoration(
                    labelText: 'Phone No.',
                    labelStyle: TextStyle(color: Colors.white),
                    // Set label text color to white
                    prefixIcon: Icon(Icons.phone, color: Colors.white),
                    // Set icon color to white
                    enabledBorder: OutlineInputBorder(
                      // Normal state border
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Focused state border
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                        color: Colors.white
                            .withOpacity(0.6)), // Set hint text color to white
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  // Text color
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    // Label text color
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                    // Icon color
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                        color:
                            Colors.white.withOpacity(0.6)), // Hint text color
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email address';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  // Text color
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    // Label text color
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    // Icon color
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                        color:
                            Colors.white.withOpacity(0.6)), // Hint text color
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Proof of Identity',
                  style: GoogleFonts.alata(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () => _showPickOptionsDialog(context),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!, width: 2),
                    ),
                    child: _proofOfIdentity != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _proofOfIdentity!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file,
                                    color: Colors.grey[600], size: 50),
                                Text('Upload Document',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: _isLoading? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      _attemptSignUp();
                    },
                    child: Text('Sign Up',
                        style: GoogleFonts.alata(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF319B4B)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
