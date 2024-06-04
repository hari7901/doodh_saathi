import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/cattle_service.dart'; // Add intl package to your pubspec.yaml for date formatting

class DiseaseEntry {
  final String disease;
  final DateTime date;
  final String id;

  DiseaseEntry({required this.disease, required this.date, required this.id});

  static DiseaseEntry fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return DiseaseEntry(
      disease: data['disease'],
      date: (data['date'] as Timestamp).toDate(),
      id: snapshot.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'date': Timestamp.fromDate(date),
    };
  }
}


class DiseaseEntryPage extends StatefulWidget {
  final String cattleId;

  DiseaseEntryPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  State<DiseaseEntryPage> createState() => _DiseaseEntryPageState();
}

class _DiseaseEntryPageState extends State<DiseaseEntryPage> {
  final _diseaseController = TextEditingController();
  List<DiseaseEntry> diseaseEntries = [];
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchDiseaseEntries();
  }

  void _fetchDiseaseEntries() {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
    if (userId == null) {
      print("User ID is null. Ensure the user is logged in.");
      return;
    }

    // Use the CattleService to get milk entries
    final stream = CattleService().getUserDiseaseEntries(userId, widget.cattleId);

    stream.listen((entries) {
      setState(() {
        diseaseEntries = entries;
      });
    }).onError((error) {
      // Handle errors or display an error message
      print("Error fetching milk entries: $error");
    });
  }

  void addDiseaseEntry() async {
    final disease = _diseaseController.text.trim();
    final userId = _auth.currentUser?.uid;
    if (_selectedDate == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid input or user not found")));
      return;
    }
    setState(() {
      _isUploading = true;
    });

    await CattleService().addDiseaseEntry(
        userId, widget.cattleId, disease, _selectedDate!);
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Disease entry added successfully")));
    _diseaseController.clear();
    _fetchDiseaseEntries();
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.diseaseRecord,style: GoogleFonts.alata(color: Colors.white),),
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
                child: Center(child: Text(AppLocalizations.of(context)!.addNewDisease, style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  controller: _diseaseController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.diseaseName,
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null ? AppLocalizations.of(context)!.noDateChosen : '${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(_selectedDate!)}',style:  GoogleFonts.alata(color:Colors.white,  fontSize: 16),),
                    TextButton(
                      onPressed: presentDatePicker,
                      child: Text(AppLocalizations.of(context)!.chooseDate,style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                  ],
                ),
              ),
              Center(
                child: _isUploading ? CircularProgressIndicator(color: Colors.white,)
                : ElevatedButton(
                  onPressed: addDiseaseEntry,
                  child: Text(AppLocalizations.of(context)!.addRecord,style: GoogleFonts.alata(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!.diseaseRecord, style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: diseaseEntries.length,
                itemBuilder: (context, index) {
                  final entry = diseaseEntries[index];
                  return Card(
                    color: Colors.lightGreen,
                    margin: EdgeInsets.all(6),
                    child: ListTile(
                      title: Text("${entry.disease} ", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(entry.date)}", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          // Call the delete method
                          await CattleService().deleteDiseaseEntry(_auth.currentUser!.uid, widget.cattleId, entry.id);
                          // Remove the entry from the list and update the UI
                          setState(() {
                            diseaseEntries.removeAt(index);
                          });
                        },
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
