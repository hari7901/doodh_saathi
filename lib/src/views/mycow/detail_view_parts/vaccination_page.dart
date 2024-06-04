import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/cattle_service.dart';

class VaccinationEntry {
  final String name;
  final String type;
  final DateTime date;
  final String imageUrl; // Add this line
  final String id;

  VaccinationEntry({
    required this.name,
    required this.type,
    required this.date,
    required this.imageUrl, // Modify here
    required this.id,
  });

  static VaccinationEntry fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return VaccinationEntry(
      name: data['name'],
      type: data['type'],
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'], // Modify here
      id: snapshot.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl, // Modify here
    };
  }
}

class VaccinationEntryPage extends StatefulWidget {
  final String cattleId;

  VaccinationEntryPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  State<VaccinationEntryPage> createState() => _VaccinationEntryPageState();
}

class _VaccinationEntryPageState extends State<VaccinationEntryPage> {
  final _vaccineNameController = TextEditingController();
  final _vaccineTypeController = TextEditingController();
  List<VaccinationEntry> vaccinationEntries = [];
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  List<File> _vaccineImages = [];
  bool _isUploading = false;


  @override
  void initState() {
    super.initState();
    _fetchVaccinationEntries();
  }

  Future<void> _pickVaccineImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _vaccineImages.add(File(pickedFile.path));
      });
    }
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
                    _pickVaccineImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    _pickVaccineImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      },
    );
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('vaccination_images/$imageName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  void _fetchVaccinationEntries() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print("User ID is null. Ensure the user is logged in.");
      return;
    }



    final stream = CattleService().getUserVaccinationEntries(userId, widget.cattleId);

    stream.listen((entries) {
      setState(() {
        vaccinationEntries = entries;
      });
    }).onError((error) {
      print("Error fetching vaccination entries: $error");
    });
  }

  void _showFullSizeImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Hero(
            tag: 'imageHero$imageUrl',
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }



  void _deleteVaccinationEntry(String entryId) async {
    setState(() {
      _isUploading = true;
    });

    await CattleService().deleteVaccineEntry(_auth.currentUser!.uid, widget.cattleId, entryId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vaccination entry deleted successfully")));
    setState(() {
      _isUploading = false;
    });
    _fetchVaccinationEntries();
  }

  void _addVaccinationEntry() async {
    final name = _vaccineNameController.text.trim();
    final type = _vaccineTypeController.text.trim();
    final userId = _auth.currentUser?.uid;

    if (name.isEmpty || _selectedDate == null || userId == null || _vaccineImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Input")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final File imageFile = _vaccineImages[0];
      String imageUrl = await _uploadImageToFirebaseStorage(imageFile);

      await CattleService().addVaccineEntry(userId, widget.cattleId, name, type, imageUrl, _selectedDate!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vaccination entry added successfully")));

      _vaccineNameController.clear();
      _vaccineTypeController.clear();
      _vaccineImages.clear();
      _fetchVaccinationEntries();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add entry: $e")));
    } finally {

      setState(() {
        _isUploading = false;
      });
    }
  }

  void presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.vaccinationRecord,style: GoogleFonts.alata(color: Colors.white),),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.green.shade500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text(AppLocalizations.of(context)!.addNewVaccine, style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  controller: _vaccineNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.vaccinationName,
                    labelStyle: GoogleFonts.alata(color: Colors.white), // Set the label text color to white
                    enabledBorder: OutlineInputBorder( // Normal state border
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when TextField is focused
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    border: OutlineInputBorder(), // Default border that's displayed
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  controller: _vaccineTypeController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.vaccinationType,
                    labelStyle: GoogleFonts.alata(color: Colors.white), // Set the label text color to white
                    enabledBorder: OutlineInputBorder( // Normal state border
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when TextField is focused
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    border: OutlineInputBorder(), // Default border that's displayed
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showPickOptionsDialog(context),
                  child: Text(AppLocalizations.of(context)!.addPrescriptions,style: GoogleFonts.alata(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical:15 ),
                  ),
                ),
              ),
              _vaccineImages.isNotEmpty
                  ? Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _vaccineImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(_vaccineImages[index]),
                    );
                  },
                ),
              )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null ? AppLocalizations.of(context)!.noDateChosen: '${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(_selectedDate!)}',style:  GoogleFonts.alata(color:Colors.white,  fontSize: 16),),
                    TextButton(
                      onPressed: presentDatePicker,
                      child: Text(AppLocalizations.of(context)!.chooseDate,style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                  ],
                ),
              ),
              Center(
                child: _isUploading? CircularProgressIndicator(color: Colors.white,)
                : ElevatedButton(
                  onPressed: _addVaccinationEntry,
                  child: Text(AppLocalizations.of(context)!.addRecord,style: GoogleFonts.alata(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${AppLocalizations.of(context)!.vaccinationRecord}:", style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              ListView.builder(
                shrinkWrap: true, // Use within a SingleChildScrollView
                physics: NeverScrollableScrollPhysics(), // Disables scrolling within ListView
                itemCount: vaccinationEntries.length,
                itemBuilder: (context, index) {
                  final entry = vaccinationEntries[index];
                  return Card(
                    color: Colors.lightGreen,
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading:GestureDetector(
                        onTap: () => _showFullSizeImage(entry.imageUrl),
                        child: Hero(
                          tag: 'imageHero${entry.id}',
                          child: Image.network(entry.imageUrl, width: 100, fit: BoxFit.cover),
                        ),
                      ),
                      title: Text("${entry.name}", style: GoogleFonts.alata(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${AppLocalizations.of(context)!.type} ${entry.type}", style: GoogleFonts.alata(color: Colors.white, fontSize: 14)),
                          Text("${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(entry.date)}", style: GoogleFonts.alata(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: _isUploading ? CircularProgressIndicator(color: Colors.white,)
                        : Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deleteVaccinationEntry(entry.id),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
