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

class WeightEntry {
  final double weight;
  final DateTime date;
  final String id;

  WeightEntry({required this.weight, required this.date, required this.id});

  static WeightEntry fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return WeightEntry(
      weight: data['weight'],
      date: (data['date'] as Timestamp).toDate(),
      id: snapshot.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'date': Timestamp.fromDate(date),
    };
  }
}


class WeightEntryPage extends StatefulWidget {
  final String cattleId;

  WeightEntryPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  State<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {
  final _weightController = TextEditingController();
  List<WeightEntry> weightEntries = [];
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeightEntries();
  }

  void _fetchWeightEntries() async {
    final userId = FirebaseAuth.instance.currentUser
        ?.uid; // Get the current user's ID
    if (userId == null) {
      print("User ID is null. Ensure the user is logged in.");
      return;
    }

    // Use the CattleService to get milk entries
    final stream = CattleService().getUserWeightEntries(
        userId, widget.cattleId);

    stream.listen((entries) {
      setState(() {
        weightEntries = entries;
      });
    }).onError((error) {
      // Handle errors or display an error message
      print("Error fetching milk entries: $error");
    });
  }

  void addWeightEntry() async {
    final weightText = _weightController.text;
    final weight = double.tryParse(weightText);
    final userId = _auth.currentUser?.uid;

    if (weight == null || _selectedDate == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid input or user not found")));
      return;
    }
    setState(() {
      _isUploading = true;
    });

    await CattleService().addWeightEntry(
        userId, widget.cattleId, weight, _selectedDate!);
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Milk entry added successfully")));
    _weightController.clear();
    _fetchWeightEntries();

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.weightEntry,style: GoogleFonts.alata(color: Colors.white),),
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
                child: Center(child: Text(AppLocalizations.of(context)!.addANewWeightEntry, style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  controller: _weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.weightInKg,
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
                child: _isUploading? CircularProgressIndicator(color: Colors.white,)
                : ElevatedButton(
                  onPressed: addWeightEntry,
                  child: Text(AppLocalizations.of(context)!.addEntry,style: GoogleFonts.alata(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${AppLocalizations.of(context)!.weightEntry}:', style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: weightEntries.length,
                itemBuilder: (context, index) {
                  final entry = weightEntries[index];
                  return Card(
                    color: Colors.lightGreen,
                    margin: EdgeInsets.all(6),
                    child: ListTile(
                      title: Text("${entry.weight} Kg", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(entry.date)}", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: IconButton(
                        icon: _isUploading? CircularProgressIndicator(color: Colors.white,)
                        : Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          setState(() {
                            _isUploading = true;
                          });

                          await CattleService().deleteWeightEntry(_auth.currentUser!.uid, widget.cattleId, entry.id);
                          setState(() {
                            _isUploading = false;
                          });
                          setState(() {
                            weightEntries.removeAt(index);
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
