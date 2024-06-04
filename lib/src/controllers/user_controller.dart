import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../views/auth/choose_login.dart';
import '../views/auth/otp_input_view.dart';
import '../views/home/home_view.dart';
import 'dart:io';


class UserController {
  final UserRepository _userRepository = UserRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void signUpWithPhone(String phone, BuildContext context) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            // Sign in with the received credential
            UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
            String userId = userCredential.user!.uid;

            // Save the user to Firestore
            var newUser = AppUser(phone: phone, userId: userId, registrationDate: DateTime.now());
            await _userRepository.saveUser(newUser);

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeView()));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-retrieval error: ${e.toString()}')));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) {
          // Navigate to the OTPInputView with the verificationId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OTPInputView(verificationId: verificationId, phoneNumber: phone)),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout if needed
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error initiating phone authentication: ${e.toString()}')));
    }
  }
  Future<void> resendOTP(String phone, String verificationId, int? resendToken, BuildContext context) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle verification completion if needed
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
        },
        codeSent: (String newVerificationId, int? newResendToken) {
          // Update the verificationId and resendToken with the new ones
          verificationId = newVerificationId;
          resendToken = newResendToken;

          // Notify the user that a new OTP has been sent
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('New OTP has been sent')));
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {
          // Handle auto-retrieval timeout if needed
        },
        timeout: Duration(seconds: 60), // Set a timeout for the manual verification
        forceResendingToken: resendToken, // Pass the resendToken to trigger resend
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resending OTP: ${e.toString()}')));
    }
  }

  Future<void> loginAndStoreData(String email, String password, String firstName, String lastName, String phone, BuildContext context,File proofOfIdentity) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Create an instance of the VetUser model with all required fields
        VetUser vetUser = VetUser(
          userId: userCredential.user!.uid,
          email: email,
          phone: phone,
          firstName: firstName,
          lastName: lastName,
          registrationDate: DateTime.now(),
        );

        await FirebaseFirestore.instance.collection('veterinary_registered').doc(userCredential.user!.uid).set({
          'userId': vetUser.userId,
          'email': vetUser.email,
          'phone': vetUser.phone,
          'firstName': vetUser.firstName,
          'lastName': vetUser.lastName,
          'registrationDate': vetUser.registrationDate.toIso8601String(),
        });

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeView()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email address is already in use by another account.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Logout successful'),
        duration: Duration(seconds: 2),
      ));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChooseLogin())); // Replace YourSignInOrHomePage with the appropriate page for sign-in or home view after logout
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

}
