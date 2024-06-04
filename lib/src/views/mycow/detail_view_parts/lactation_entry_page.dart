import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/lactation_model.dart';
import '../../../services/cattle_service.dart'; // Ensure you have this model created

class LactationEntryPage extends StatefulWidget {
  final String cattleId;

  LactationEntryPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  _LactationEntryPageState createState() => _LactationEntryPageState();
}

class _LactationEntryPageState extends State<LactationEntryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<LactationEntry> lactationEntries = [];
  final CattleService _cattleService = CattleService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchLactationEntries();
  }


  void _fetchLactationEntries() {
    // Assuming you have a way to get the current userId
    final userId = FirebaseAuth.instance.currentUser
        ?.uid;

    _cattleService.getUserLactationEntries(userId!, widget.cattleId).listen((entries) {
      setState(() {
        lactationEntries = entries;
      });
    });
  }

  void _deleteLactationEntry(String entryId) async {
    // Perform the deletion from Firestore here using the CattleService
    await _cattleService.deleteLactationEntry(_auth.currentUser!.uid, widget.cattleId, entryId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lactation cycle deleted successfully")));
    // Refresh the list after deletion
    _fetchLactationEntries();
  }

  void _addLactationEntry() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select both start and end dates.")));
      return;
    }
    final userId = FirebaseAuth.instance.currentUser
        ?.uid;

    setState(() {
      _isUploading = false;
    });

    await _cattleService.addLactationCycle(userId!, widget.cattleId, _startDate!, _endDate!);

    setState(() {
      _isUploading = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lactation cycle added successfully")));
    _startDate = null;
    _endDate = null;
    _fetchLactationEntries();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lactationCycle, style: GoogleFonts.alata(color: Colors.white)),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(8.0),
          color: Colors.green.shade500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(AppLocalizations.of(context)!.addNewLactationCycle, style: GoogleFonts.alata(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              DatePickers(
                startDate: _startDate,
                endDate: _endDate,
                onStartDatePicked: (date) => setState(() => _startDate = date),
                onEndDatePicked: (date) => setState(() => _endDate = date),
              ),
              SizedBox(height: 10),
              Center(
                child: _isUploading? CircularProgressIndicator(color: Colors.white,)
                : ElevatedButton.icon(
                  onPressed: _addLactationEntry,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.addLactationCycle, style: GoogleFonts.alata(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ),
              SizedBox(height: 20),
              Text('${AppLocalizations.of(context)!.lactationCycle}:', style: GoogleFonts.alata(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              LactationEntriesList(
                lactationEntries: lactationEntries,
                onDelete: (String entryId) {
                  _deleteLactationEntry(entryId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickers extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDatePicked;
  final ValueChanged<DateTime> onEndDatePicked;

  DatePickers({
    this.startDate,
    this.endDate,
    required this.onStartDatePicked,
    required this.onEndDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DatePickerButton(
          label: startDate == null ? AppLocalizations.of(context)!.pickStartDate : '${AppLocalizations.of(context)!.start}: ${DateFormat.yMd().format(startDate!)}',
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) onStartDatePicked(picked);
          },
        ),
        DatePickerButton(
          label: endDate == null ? AppLocalizations.of(context)!.pickEndDate : '${AppLocalizations.of(context)!.end}: ${DateFormat.yMd().format(endDate!)}',
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) onEndDatePicked(picked);
          },
        ),
      ],
    );
  }
}

class DatePickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  DatePickerButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.alata(color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
    );
  }
}

class LactationEntriesList extends StatelessWidget {
  final List<LactationEntry> lactationEntries;
  final Function(String) onDelete;

  LactationEntriesList({
    required this.lactationEntries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return lactationEntries.isEmpty
        ? Center(
      child: Text(AppLocalizations.of(context)!.noLactationCycleAdded, style: GoogleFonts.alata(color: Colors.white, fontSize: 16)),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: lactationEntries.length,
      itemBuilder: (context, index) {
        final entry = lactationEntries[index];
        return Card(
          color: Colors.lightGreen,
          child: ListTile(
            title: Text("${AppLocalizations.of(context)!.start}: ${DateFormat.yMd().format(entry.startDate)}", style: GoogleFonts.alata(color: Colors.white)),
            subtitle: Text("${AppLocalizations.of(context)!.end}: ${DateFormat.yMd().format(entry.endDate)}", style: GoogleFonts.alata(color: Colors.white)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () => onDelete(entry.id),
            ),
          ),
        );
      },
    );
  }
}
