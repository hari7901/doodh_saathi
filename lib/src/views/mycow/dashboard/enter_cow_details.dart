import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../services/marketplace_service.dart';
import '../../../utils/marketplace_data_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EnterCowDetailsPage extends StatefulWidget {
  @override
  _EnterCowDetailsPageState createState() => _EnterCowDetailsPageState();
}

class _EnterCowDetailsPageState extends State<EnterCowDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<File> _cowImages = [];
  final TextEditingController _cowNameController = TextEditingController();
  final TextEditingController _cowBreedController = TextEditingController();
  final TextEditingController _cowPriceController = TextEditingController();
  final TextEditingController _cowWeightController = TextEditingController();
  final TextEditingController _cowLactationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _lastFeverController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _vaccineDateController = TextEditingController();

  Future<void> _selectLastFeverDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _lastFeverController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  bool _isLoading = false;

  MarketplaceService marketplaceService = MarketplaceService();

  Future<void> _pickCowImage(ImageSource source) async {
    if (_cowImages.length < 3) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _cowImages.add(File(pickedFile.path));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 3 images allowed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectVaccineDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _vaccineDateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _addCowToFirestore() async {

    setState(() {
      _isLoading = true;
    });

    try {

      List<String> imageUrls = await _uploadImagesToFirebaseStorage();

      Cow newCow = Cow(
        cowName: _cowNameController.text,
        cowBreed: _cowBreedController.text,
        cowPrice: double.parse(_cowPriceController.text),
        cowWeight: double.parse(_cowWeightController.text),
        cowLactation: int.parse(_cowLactationController.text),
        cowImages: imageUrls,
        phoneNumber: _phoneNumberController.text,
        medication: _medicationController.text.isNotEmpty ? _medicationController.text : 'None',
        lastFeverDate: _lastFeverController.text.isNotEmpty ? _lastFeverController.text : 'None',
        disease: _diseaseController.text.isNotEmpty ? _diseaseController.text : 'None',
        vaccineName: _vaccineNameController.text.isNotEmpty ? _vaccineNameController.text : 'None',
        vaccineDate: _vaccineDateController.text.isNotEmpty ? _vaccineDateController.text : 'None',
      );

      Map<String, dynamic> cowData = {
        'cowName': newCow.cowName,
        'cowBreed': newCow.cowBreed,
        'cowPrice': newCow.cowPrice,
        'cowWeight': newCow.cowWeight,
        'cowLactation': newCow.cowLactation,
        'cowImages': newCow.cowImages,
        'phoneNumber': _phoneNumberController.text,
        'medication': _medicationController.text.isNotEmpty ? _medicationController.text : 'None',
        'lastFeverDate': _lastFeverController.text.isNotEmpty ? _lastFeverController.text : 'None',
        'disease': _diseaseController.text.isNotEmpty ? _diseaseController.text : 'None',
        'vaccineName': _vaccineNameController.text.isNotEmpty ? _vaccineNameController.text : 'None',
        'vaccineDate': _vaccineDateController.text.isNotEmpty ? _vaccineDateController.text : 'None',
      };

      marketplaceService.addCowToFirestore('listed_cows', cowData);

      // Add the cow to the local state using Provider
      Provider.of<CowProvider>(context, listen: false).addCow(newCow);

      // Clear the form and reset the state
      _formKey.currentState?.reset();
      _cowImages.clear();

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cow added successfully!'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      // Handle errors during the upload process
      print('Error uploading cow: $e');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add cow. Please try again.'),
        duration: Duration(seconds: 2),
      ));
    } finally {
      // Set loading state to false
      setState(() {
        _isLoading = false;
        Navigator.pop(context);
      });
    }
  }

  Future<List<String>> _uploadImagesToFirebaseStorage() async {
    List<String> imageUrls = [];

    for (File imageFile in _cowImages) {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('cow_images/$imageName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadURL);
    }

    return imageUrls;
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
                    _pickCowImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    _pickCowImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.enterCowDetails, style: GoogleFonts.alata(color: Colors.white)),
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _cowNameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.cowName,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.cow, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Cow name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _cowBreedController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.breed,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.cow, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the breed type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _cowPriceController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.price,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.moneyBill, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _cowWeightController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.weight,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.weight, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the weight';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _cowLactationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.lactation,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.wineBottle, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the lactation details';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phoneNumberController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phoneNumber,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.phone, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _medicationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.medication,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.pills, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () => _selectLastFeverDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _lastFeverController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.lastFeverDate,
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(FontAwesomeIcons.thermometer, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _diseaseController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.disease,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(FontAwesomeIcons.heartbeat, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vaccineNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.vaccineName,
                          labelStyle: TextStyle(color: Colors.white),
                          // ... (existing code)
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectVaccineDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _vaccineDateController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.vaccineDate,
                              labelStyle: TextStyle(color: Colors.white),
                              // ... (existing code)
                              suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Text(
                  AppLocalizations.of(context)!.cowImages,
                  style: GoogleFonts.alata(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cowImages.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _cowImages.length) {
                        return InkWell(
                          onTap: () => _showPickOptionsDialog(context),
                          child: Container(
                            width: 150,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!, width: 2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.grey[600], size: 40),
                                  Text(AppLocalizations.of(context)!.addImage, style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: 150,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _cowImages[index],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child:_isLoading? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed:(){
                      _addCowToFirestore();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.addCow,
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green.shade900, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
