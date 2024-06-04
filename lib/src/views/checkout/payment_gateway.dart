import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cart_model.dart';
import '../../models/address_model.dart';
import 'checkout_view.dart';
import 'order_confirmation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentGatewayPage extends StatefulWidget {
  final AddressData selectedAddress;
  final CartModel cart;

  PaymentGatewayPage({Key? key, required this.selectedAddress, required this.cart}) : super(key: key);

  @override
  _PaymentGatewayPageState createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('               ${AppLocalizations.of(context)!.paymentOptions}',
            style: GoogleFonts.alata(color: Colors.white)),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!, // Lighter green color
              Colors.white, // Darker green color
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.selectYourPaymentMethod,
                style: GoogleFonts.alata(fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildPaymentOption(
                title: AppLocalizations.of(context)!.payWithSaathiWallet,
                icon: Icons.account_balance_wallet,
                onTap: _handlePaymentWithMooWallet,
              ),
              SizedBox(height: 20),
              _buildPaymentOption(
                title: AppLocalizations.of(context)!.cashOnDelivery,
                icon: Icons.local_shipping,
                onTap: _handleCashOnDelivery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.alata(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  void _handlePaymentWithMooWallet() async {
    setState(() => isLoading = true);

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference walletRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('wallet_info').doc('credit_details');

      DocumentSnapshot walletSnapshot = await walletRef.get();
      double currentBalance = (walletSnapshot.data() as Map<String, dynamic>)['loan'].toDouble();
      double orderAmount = widget.cart.calculateSubtotal();

      if (currentBalance >= orderAmount) {
        // Navigate to CheckoutPage and pass the Wallet balance
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => CheckoutPage(
            selectedAddress: widget.selectedAddress,
            cart: widget.cart,
            walletBalance: currentBalance, // Pass the Wallet balance
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Insufficient balance in MooWallet.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error processing payment: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleCashOnDelivery() {
    // Navigate to CheckoutPage with walletBalance explicitly set to null
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          selectedAddress: widget.selectedAddress,
          cart: widget.cart,
          walletBalance: null, // Explicitly passing null for walletBalance
        ),
      ),
    );
  }

}