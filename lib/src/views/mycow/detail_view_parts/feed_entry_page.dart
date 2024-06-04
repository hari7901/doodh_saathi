import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../services/cattle_service.dart';
import '../calculators/feed_calculator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedEntry {
  final double feedQty;
  final String feedName;
  final DateTime date;
  final String id;

  FeedEntry( {required this.feedQty,required this.feedName, required this.date, required this.id});

  static FeedEntry fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return FeedEntry(
      feedQty: data['feedQty'],
      feedName: data['feedName'],
      date: (data['date'] as Timestamp).toDate(),
      id: snapshot.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feedQty': feedQty,
      'feedName': feedName,
      'date': Timestamp.fromDate(date),
    };
  }
}


class FeedEntryPage extends StatefulWidget {
  final String cattleId;

  FeedEntryPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  State<FeedEntryPage> createState() => _FeedEntryPageState();
}

class _FeedEntryPageState extends State<FeedEntryPage> {
  final _feedQtyController = TextEditingController();
  final _feedNameController = TextEditingController();
  List<FeedEntry> feedEntries = [];
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchFeedEntries();
  }

  void _fetchFeedEntries() async {
    final userId = FirebaseAuth.instance.currentUser
        ?.uid; // Get the current user's ID
    if (userId == null) {
      print("User ID is null. Ensure the user is logged in.");
      return;
    }

    // Use the CattleService to get milk entries
    final stream = CattleService().getUserFeedEntries(
        userId, widget.cattleId);

    stream.listen((entries) {
      setState(() {
        feedEntries = entries;
      });
    }).onError((error) {
      // Handle errors or display an error message
      print("Error fetching milk entries: $error");
    });
  }

  void addFeedEntry() async {
    final feedQtyText = _feedQtyController.text;
    final feedNames = _feedNameController.text;
    final feedQty = double.tryParse(feedQtyText);
    final userId = _auth.currentUser?.uid;

    if (feedQty == null || _selectedDate == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid input or user not found")));
      return;
    }
    setState(() {
      _isUploading = true;
    });

    await CattleService().addFeedEntry(
        userId, widget.cattleId, feedNames, feedQty, _selectedDate!);
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feed entry added successfully")));
    _feedQtyController.clear();
    _fetchFeedEntries();
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.feedEntries,style: GoogleFonts.alata(color: Colors.white),),
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
                child: Center(child: Text(AppLocalizations.of(context)!.useOurFeedCalc, style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FeedCalculatorPage())),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text(AppLocalizations.of(context)!.openFeedCalc, style: GoogleFonts.alata(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text(AppLocalizations.of(context)!.addNewFeedEntry, style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  controller: _feedNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.feedName,
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
                  style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  controller: _feedQtyController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.feedQTY,
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
                child:_isUploading? CircularProgressIndicator(color: Colors.white,)
                    : ElevatedButton(
                  onPressed: addFeedEntry,
                  child: Text(AppLocalizations.of(context)!.addEntry,style: GoogleFonts.alata(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${AppLocalizations.of(context)!.feedEntries}:', style:  GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: feedEntries.length,
                itemBuilder: (context, index) {
                  final entry = feedEntries[index];
                  return Card(
                    color: Colors.lightGreen,
                    margin: EdgeInsets.all(6),
                    child: ListTile(
                      title: Text("${entry.feedName} Kg", style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("${entry.feedQty} Kg | ${AppLocalizations.of(context)!.date} ${DateFormat.yMd().format(entry.date)}", style: GoogleFonts.alata(color:Colors.white, fontSize: 14)),

                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          // Call the delete method
                          await CattleService().deleteFeedEntry(_auth.currentUser!.uid, widget.cattleId, entry.id);
                          // Remove the entry from the list and update the UI
                          setState(() {
                            feedEntries.removeAt(index);
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
