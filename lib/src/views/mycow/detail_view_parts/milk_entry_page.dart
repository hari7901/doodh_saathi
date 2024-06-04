import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../services/cattle_service.dart'; // Add intl package to your pubspec.yaml for date formatting
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MilkEntry {
  final double milk;
  final DateTime date;
  final String id;

  MilkEntry({required this.milk, required this.date, required this.id});

  static MilkEntry fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return MilkEntry(
      milk: data['milk'],
      date: (data['date'] as Timestamp).toDate(),
      id: snapshot.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'milk': milk,
      'date': Timestamp.fromDate(date),
    };
  }
}

class MilkEntryPage extends StatefulWidget {
  final String cattleId;

  MilkEntryPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  State<MilkEntryPage> createState() => _MilkEntryPageState();
}

class _MilkEntryPageState extends State<MilkEntryPage> {
  final _milkController = TextEditingController();
  List<MilkEntry> milkEntries = [];
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchMilkEntries();
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, VoidCallback onDelete) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this entry?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: onDelete, // Call the deletion function
            ),
          ],
        );
      },
    );
  }


  void _fetchMilkEntries() {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
    if (userId == null) {
      print("User ID is null. Ensure the user is logged in.");
      return;
    }

    // Use the CattleService to get milk entries
    final stream = CattleService().getUserMilkEntries(userId, widget.cattleId);

    stream.listen((entries) {
      setState(() {
        milkEntries = entries;
      });
    }).onError((error) {
      // Handle errors or display an error message
      print("Error fetching milk entries: $error");
    });
  }

  void _addMilkEntry() async {
    final milkText = _milkController.text;
    final milkAmount = double.tryParse(milkText);
    final userId = _auth.currentUser?.uid;

    if (milkAmount == null || _selectedDate == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid input or user not found")));
      return;
    }
    setState(() {
      _isUploading = true;
    });

    await CattleService().addMilkEntry(userId, widget.cattleId, milkAmount, _selectedDate!);
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Milk entry added successfully")));
    _milkController.clear();
    _fetchMilkEntries(); // Refresh list after adding
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.milkEntries,style: GoogleFonts.alata(color: Colors.white),),
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
                  child: Center(child: Text(AppLocalizations.of(context)!.addANewMilkEntry, style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    controller: _milkController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.milkInL,
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
                    onPressed: _addMilkEntry,
                    child: Text(AppLocalizations.of(context)!.addEntry,style: GoogleFonts.alata(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${AppLocalizations.of(context)!.milkEntries}:', style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: milkEntries.length,
                  itemBuilder: (context, index) {
                    final entry = milkEntries[index];
                    return Card(
                      color: Colors.lightGreen,
                      margin: EdgeInsets.all(6),
                      child: ListTile(
                        title: Text("${entry.milk} L", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text("${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(entry.date)}", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            // Show delete confirmation dialog
                            _showDeleteConfirmationDialog(context, () async {

                              await CattleService().deleteMilkEntry(_auth.currentUser!.uid, widget.cattleId, entry.id);

                              // Refresh the list by fetching entries again or removing the entry from the list
                              setState(() {
                                milkEntries.removeAt(index);
                              });

                              Navigator.of(context).pop(); // Close the confirmation dialog
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
