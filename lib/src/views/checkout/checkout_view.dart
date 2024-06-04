import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/address_model.dart';
import '../../models/cart_model.dart';
import '../../models/products_model.dart';
import '../../services/user_profile_service.dart';
import 'order_confirmation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CheckoutPage extends StatefulWidget {
  final AddressData selectedAddress;
  final CartModel cart;
  double? walletBalance;

  CheckoutPage({Key? key, required this.selectedAddress, required this.cart, this.walletBalance}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double totalPrice = 0.0; // Initialize the totalPrice variable here
  bool isLoading = false;
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.checkoutView}',style:
          GoogleFonts.alata(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        backgroundColor: Colors.green,
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
        ),// Set the app bar background color
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderSummary(),
            SizedBox(height: 20),
            _buildAddressDetails(),
            SizedBox(height: 20),
            _buildConfirmOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    // Correctly handle totalPrice calculation outside of the build method to avoid state issues.
    double localTotalPrice = widget.cart.items.entries.fold(0, (previousValue, entry) => previousValue + entry.key.price * entry.value);

    return Card(
      color: Colors.green.shade600,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                AppLocalizations.of(context)!.orderSummary,
                style: GoogleFonts.alata(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
              ),
            ),
            Divider(color: Colors.white,),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(), // Add this to disable scrolling within the ListView
              shrinkWrap: true,
              itemCount: widget.cart.items.length,
              itemBuilder: (context, index) {
                final productEntry = widget.cart.items.entries.toList()[index];
                final product = productEntry.key;
                final quantity = productEntry.value;
                return ListTile(
                  leading: Image.network(
                    product.imageUrls.first,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(
                    product.name,
                    style: GoogleFonts.alata(fontWeight: FontWeight.bold,color:Colors.white),
                  ),
                  subtitle: Text('${AppLocalizations.of(context)!.quantity}: $quantity', style: GoogleFonts.alata(color:Colors.white,fontWeight: FontWeight.bold,),),
                  trailing: Text('${AppLocalizations.of(context)!.price}: \₹${(product.price * quantity).toStringAsFixed(2)}', style: GoogleFonts.alata(fontSize: 14,color:Colors.white),),
                );
              },
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${AppLocalizations.of(context)!.totalItems}: ${widget.cart.items.length}',
                style: GoogleFonts.alata(fontWeight: FontWeight.bold,color:Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${AppLocalizations.of(context)!.totalPrice}: \₹${localTotalPrice.toStringAsFixed(2)}', // Use localTotalPrice
                style: GoogleFonts.alata(fontWeight: FontWeight.bold,color:Colors.white),
              ),
            ),
            if (widget.walletBalance != null) // Check if walletBalance is not null
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${AppLocalizations.of(context)!.walletBalance}: \₹${widget.walletBalance?.toStringAsFixed(2)}', // Safely access walletBalance
                  style: GoogleFonts.alata(fontWeight: FontWeight.bold,color:Colors.white),
                ),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetails() {
    AddressData address = widget.selectedAddress;
    return Card(
      color: Colors.green.shade600,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.deliveryAddress,
              style: GoogleFonts.alata(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
            ),
            Divider(color: Colors.white,),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.teal.shade900,),
              title: Text(
                '${address.name}\n${address.flatHouseNo}, ${address.areaStreet}',
                style: GoogleFonts.alata(fontWeight: FontWeight.bold,color:Colors.white),
              ),
              subtitle: Text(
                '${address.city}, ${address.state}, ${address.pincode}',
                style: GoogleFonts.alata(color:Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.teal.shade900),
              title: Text(
                '${AppLocalizations.of(context)!.phone}: ${address.phone}',
                style: GoogleFonts.alata(color:Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmOrderButton() {
    return ElevatedButton(
      onPressed: () => _confirmOrder(),
      child: Text(AppLocalizations.of(context)!.confirmOrder,
          style: GoogleFonts.alata(
              color: Colors.white, fontSize: 18)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding:
        EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
    );
  }

  void _confirmOrder() async {
    setState(() => isLoading = true);
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final double orderAmount = widget.cart.items.entries.fold(0, (previousValue, entry) => previousValue + entry.key.price * entry.value);

    bool isWalletPayment = widget.walletBalance != null && widget.walletBalance! >= orderAmount;

    if (isWalletPayment) {
      double currentBalance = await UserService.fetchUserCredit(userId);
      if (currentBalance >= orderAmount) {
        double newBalance = currentBalance - orderAmount;
        await _userService.updateWalletBalance(userId, newBalance);

        // Update the state with the new wallet balance
        setState(() {
          widget.walletBalance = newBalance;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Insufficient balance in MooWallet.")));
        setState(() => isLoading = false);
        return; // Exit if insufficient funds
      }
    }

    try {
      // Create order document in Firestore
      DocumentReference orderRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('orders').doc();

      Map<String, dynamic> orderData = {
        'userId': userId,
        'totalPrice': orderAmount,
        'items': widget.cart.items.entries.map((entry) {
          final product = entry.key;
          final quantity = entry.value;
          return {
            'productId': product.id,
            'productName': product.name,
            'quantity': quantity,
            'pricePerItem': product.price,
            'imageUrl': product.imageUrls.first, // Assuming there's at least one image URL per product
          };
        }).toList(),
        'address': {
          'name': widget.selectedAddress.name,
          'flatHouseNo': widget.selectedAddress.flatHouseNo,
          'areaStreet': widget.selectedAddress.areaStreet,
          'city': widget.selectedAddress.city,
          'state': widget.selectedAddress.state,
          'pincode': widget.selectedAddress.pincode,
          'phone': widget.selectedAddress.phone,
        },
        'paymentMethod': isWalletPayment ? 'MooWallet' : 'Cash on Delivery',
        'orderStatus': 'Pending',
      };

      await orderRef.set(orderData);

      // Record a transaction for each product in the cart
      // Inside _confirmOrder method, iterating over cart items to record transactions
      widget.cart.items.entries.forEach((entry) async {
        final Product product = entry.key;
        final int quantity = entry.value;
        final double totalPriceForItem = product.price * quantity;
        final String imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls.first : "default_image_url"; // Use the first image URL or a default
        final String productName = product.name;

        await _userService.recordTransaction(
          userId,
          -totalPriceForItem, // Assuming negative value represents a deduction
          'Order',
          imageUrl,
          productName,
          quantity
        );
      });

      widget.cart.clearCart();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OrderConfirmationPage()), // Ensure this page exists and is imported
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error processing order: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
