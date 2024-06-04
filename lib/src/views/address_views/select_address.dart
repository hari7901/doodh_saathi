import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cart_model.dart';
import '../../services/address_service.dart';
import '../MenuViews/cart.dart';
import '../../models/address_model.dart';
import '../checkout/checkout_view.dart';
import '../checkout/payment_gateway.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'enter_address.dart';


class SelectAddress extends StatefulWidget {
  final CartModel cart;

  SelectAddress({Key? key, required this.cart}) : super(key: key);

  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  List<AddressData> addresses = []; // Assuming AddressData is your model class
  int? selectedAddressIndex;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
    selectedAddressIndex = 0;
  }

  void _deliverHere(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayPage(
          selectedAddress: addresses[index],
          cart: widget.cart,
        ),
      ),
    );
  }


  void _fetchAddresses() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      var fetchedAddresses = snapshot.docs
          .map((doc) => AddressData.fromMap(doc.data(), doc.id)) // Assuming AddressData has a fromMap constructor
          .toList();

      setState(() {
        addresses = fetchedAddresses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasAddresses = addresses.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CartPage()));
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: GoogleFonts.alata(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ],
      ),
      body: Container(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.selectDeliveryAddr,
                    style: GoogleFonts.alata(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              hasAddresses
                  ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  AddressData address = addresses[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          hintColor: Colors.teal, // Color for the expansion icon
                        ),
                        child: ExpansionTile(
                          backgroundColor: Colors.green[100], // Light background color
                          initiallyExpanded: index == 0,
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.home,color: Colors.white,),
                          ),
                          title: Text(
                            address.name,
                            style: GoogleFonts.alata(
                              color: Colors.teal.shade900, // Dark teal color for the text
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${address.flatHouseNo}, ${address.areaStreet}, ${address.city}, ${address.state}, ${address.pincode}\nPhone: ${address.phone}',
                            style: GoogleFonts.alata(
                              color: Colors.teal.shade600, // Slightly lighter color for the subtitle
                              fontSize: 16,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.black),
                            onPressed: () async {
                              await AddressService().deleteAddressFromFirebase(
                                FirebaseAuth.instance.currentUser!.uid,
                                address.id,
                              );
                              setState(() {
                                addresses.removeAt(index);
                              });
                            },
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  // Keeping your existing buttons unchanged
                                  ElevatedButton(
                                    child: Text(
                                      AppLocalizations.of(context)!.editDetails,
                                      style: GoogleFonts.alata(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(

                                              builder: (context) => EnterAddress(existingAddress: addresses[index]),
                                      ),
                                      );
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text(
                                      AppLocalizations.of(context)!.deliverHere,
                                      style: GoogleFonts.alata(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    onPressed: () => _deliverHere(index),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onExpansionChanged: (bool expanded) {
                            if (expanded) {
                              setState(() {
                                selectedAddressIndex = index;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              )

                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 80, color: Colors.teal),
                    Text(
                      AppLocalizations.of(context)!.noAddressesYet,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => EnterAddress()));
                    },
                    child: Text( AppLocalizations.of(context)!.addNewAdrr, style: GoogleFonts.alata(
                        color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}