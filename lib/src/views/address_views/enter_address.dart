
import 'package:DoodhSaathi/src/views/address_views/select_address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/address_model.dart';
import '../../models/cart_model.dart';
import '../../models/cityState.dart';
import '../../services/address_service.dart';
import '../MenuViews/cart.dart';

class EnterAddress extends StatefulWidget {
  final AddressData? existingAddress;

  EnterAddress({Key? key, this.existingAddress}) : super(key: key);

  @override
  _EnterAddressState createState() => _EnterAddressState();
}

class _EnterAddressState extends State<EnterAddress> {
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _flatHouseController = TextEditingController();
  final TextEditingController _areaStreetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  List<CityState> _cityStates = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      _nameController.text = widget.existingAddress!.name;
      _phoneController.text = widget.existingAddress!.phone;
      _flatHouseController.text = widget.existingAddress!.flatHouseNo;
      _areaStreetController.text = widget.existingAddress!.areaStreet;
      _landmarkController.text = widget.existingAddress!.landmark;
      _pincodeController.text = widget.existingAddress!.pincode;
      _cityController.text = widget.existingAddress!.city;
      _stateController.text = widget.existingAddress!.state;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _flatHouseController.dispose();
    _areaStreetController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _handleSaveAddress() async {
    // Validation: Check if required fields are filled
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _flatHouseController.text.isEmpty ||
        _areaStreetController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all required fields'),
      ));
      return;
    }

    // Getting the current user's ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No user logged in'),
      ));
      return;
    }

    // Creating AddressData instance
    AddressData address = AddressData(
      name: _nameController.text,
      phone: _phoneController.text,
      flatHouseNo: _flatHouseController.text,
      areaStreet: _areaStreetController.text,
      landmark: _landmarkController.text,
      // This is optional
      pincode: _pincodeController.text,
      city: _cityController.text,
      state: _stateController.text,
    );
    try {
      if (widget.existingAddress == null) {
        // New address
        await _addressService.saveAddressToFirebase(userId, address);
      } else {
        // Update existing address
        await _addressService.updateAddressInFirebase(userId, widget.existingAddress!.id, address);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SelectAddress(cart: Provider.of<CartModel>(context, listen: false),)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save address: ${e.toString()}'),
      ));
    }
  }


  InputDecoration _getInputDecoration(String label, {Widget? prefix}) {
    return InputDecoration(
      labelText: label,
      prefix: prefix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  Widget _cityAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        // Flatten all cities and filter based on the input
        return cityStates.expand((state) => state.cities)
            .where((city) => city.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: (String city) => city,
      onSelected: (String selectedCity) {
        // Update the city controller with the selected city
        _cityController.text = selectedCity;

        // Find the state for the selected city and update the state controller
        var foundState = cityStates.firstWhere(
                (state) => state.cities.contains(selectedCity),
            orElse: () => CityState('', [])
        );
        _stateController.text = foundState.name;
      },
      fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
          ) {
        return TextFormField(
          controller: fieldTextEditingController,
          decoration: _getInputDecoration('City'), // Using the common decoration method for consistency
          focusNode: fieldFocusNode,
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTextFieldWithShadow(TextEditingController controller,
      String label, String? Function(String?)? validator, {Widget? prefix}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: _getInputDecoration(label, prefix: prefix),
        validator: validator,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SelectAddress(cart: Provider.of<CartModel>(context, listen: false),)));
            }),
        actions: [
          TextButton(
            onPressed: () {
              // Logic to navigate back to the cart
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CartPage())); // Adjust this as per your navigation logic
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
        height: MediaQuery.of(context).size.height,
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.enterNewDeliveryAddr,
                    style: GoogleFonts.alata(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  _buildSectionHeader(AppLocalizations.of(context)!.personalDetails),
                  _buildTextFieldWithShadow(
                      _nameController,
                      AppLocalizations.of(context)!.name,
                      (value) =>
                          value!.isEmpty ? 'Please enter your name' : null),
                  _buildTextFieldWithShadow(
                      _phoneController,
                      AppLocalizations.of(context)!.phoneNumber,
                        (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter your phone number"; // "Please enter your phone number";
                      } else if (value.length != 10) {
                        return "Please enter a valid phone number" ; // "Please enter a valid phone number";
                      }
                      return null;
                    },
                    prefix: Container(
                      margin: EdgeInsets.only(right: 10), // Add some space between the prefix and the text
                      child: Text("+91", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSectionHeader(AppLocalizations.of(context)!.addressdetails),
                  _buildTextFieldWithShadow(
                      _flatHouseController,
                      AppLocalizations.of(context)!.flatHouseNumber,
                      (value) => value!.isEmpty
                          ? 'Please enter your flat/house no.'
                          : null),
                  _buildTextFieldWithShadow(
                      _areaStreetController,
                      AppLocalizations.of(context)!.areaStreetAddress,
                      (value) => value!.isEmpty
                          ? 'Please enter your area/street'
                          : null),
                  _buildTextFieldWithShadow(
                      _landmarkController,AppLocalizations.of(context)!.landmark, null),
                  _buildTextFieldWithShadow(
                      _pincodeController,
                      AppLocalizations.of(context)!.pincode,
                        (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your pincode";
                      } else if (value.length != 6) {
                        return "Please enter a valid pincode";
                      }
                      return null;
                    },
                  ),
                  _cityAutocomplete(),
                  SizedBox(height: 12),
                  _buildTextFieldWithShadow(
                    _stateController,
                    AppLocalizations.of(context)!.state,
                    null, // Since it's automatically filled, no need for a validator
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _handleSaveAddress(),
                      child: Text(AppLocalizations.of(context)!.useThisAddress,
                          style: GoogleFonts.alata(
                              color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
