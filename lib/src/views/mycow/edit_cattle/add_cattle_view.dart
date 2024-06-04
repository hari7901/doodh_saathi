  import 'package:DoodhSaathi/src/views/mycow/edit_cattle/cattle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/cattle_model.dart';
import '../../../services/user_profile_service.dart';
import '../../../utils/cattleId.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCattlePage extends StatefulWidget {
  final CattleEntry? cattle;
  final bool isEditing;

  AddCattlePage({Key? key, this.cattle, this.isEditing = false})
      : super(key: key);

  @override
  _AddCattlePageState createState() => _AddCattlePageState();
}

class _AddCattlePageState extends State<AddCattlePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  final TextEditingController _tagNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _inseminatorController = TextEditingController();
  final TextEditingController _herdController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.cattle != null) {
      _populateFields(widget.cattle!);
    }
  }

  void _populateFields(CattleEntry cattle) {
    _tagNumberController.text = cattle.tagNumber;
    _nameController.text = cattle.name;
    _dateController.text = cattle.birthday;
    _breedController.text = cattle.breed;
    _motherController.text = cattle.mother;
    _inseminatorController.text = cattle.inseminator;
    _herdController.text = cattle.herd;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveCattleData() async {
    if (_formKey.currentState!.validate()) {
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // Inline function to handle mapping, local to _saveCattleData
      CattleEntry fromMap(Map<String, dynamic> data, [String? id]) {
        return CattleEntry(
            id: id ?? '',
            tagNumber: data['tagNumber'] ?? '',
            name: data['name'] ?? '',
            birthday: data['birthday'] ?? '',
            breed: data['breed'] ?? '',
            mother: data['mother'] ?? '',
            inseminator: data['inseminator'] ?? '',
            herd: data['herd'] ?? '',
        );
      }

      Map<String, dynamic> cattleData = {
        'tagNumber': _tagNumberController.text,
        'name': _nameController.text,
        'birthday': _dateController.text,
        'breed': _breedController.text,
        'mother': _motherController.text,
        'inseminator': _inseminatorController.text,
        'herd': _herdController.text,
      };

      UserService firebaseService = UserService();

      try {
        if (widget.isEditing && widget.cattle != null) {
          // Update existing cattle entry in Firestore
          await firebaseService.updateCattleData(
              currentUserId!, widget.cattle!.id, cattleData);
          // Update the local model
          Provider.of<CattleModel>(context, listen: false)
              .updateCattleEntry(fromMap(cattleData, widget.cattle!.id));

        } else {


          // Add new cattle entry to Firestore and wait for the cattleId
          String cattleId =
          await firebaseService.addCattleData(currentUserId!, cattleData);

          // Update the cattle ID in the provider
          Provider.of<CattleIdProvider>(context, listen: false)
              .setCattleId(cattleId);
          // Add the new entry to the local model with the obtained cattleId
          Provider.of<CattleModel>(context, listen: false)
              .addCattleEntry(fromMap(cattleData, cattleId));

          Navigator.pop(context);
        }

      } catch (error) {
        // Handle any errors appropriately
        print("Error saving cattle data: $error");
      }
    }
  }

  Future<void> saveCattleToFirestore(CattleEntry cattle) async {
    final docRef = FirebaseFirestore.instance.collection('cattle').doc(cattle.id);

    await docRef.set(cattle.toMap(), SetOptions(merge: true));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppLocalizations.of(context)!.addCattle,
              style: GoogleFonts.alata(color: Colors.white)),
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.teal, Colors.lightGreen],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _tagNumberController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tagNumber),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tag number';
                  }
                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),  // Limiting input to 15 characters
                ],
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),  // Limiting input to 15 characters
                ],
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.birth,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter birthday';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.breed),
              ),

              TextFormField(
                controller: _motherController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.mother),
              ),
              TextFormField(
                controller: _inseminatorController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.inseminator),
              ),
              TextFormField(
                controller: _herdController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.herd),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveCattleData,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)!.save,
                          style: GoogleFonts.alata(
                              color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context)!.cancel,
                          style: GoogleFonts.alata(
                              color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tagNumberController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _breedController.dispose();
    _motherController.dispose();
    _inseminatorController.dispose();
    _herdController.dispose();
    super.dispose();
  }
}