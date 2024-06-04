
import 'package:DoodhSaathi/src/views/mycow/calculators/weight_calc.dart';
import 'package:DoodhSaathi/src/views/mycow/detail_view_parts/vaccination_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/cattle_model.dart';
import '../../../services/herd_activity_service.dart';
import '../../../utils/activity_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../calculators/dmi_calculator.dart';
import '../detail_view_parts/disease_page.dart';
import '../detail_view_parts/feed_entry_page.dart';
import '../detail_view_parts/lactation_entry_page.dart';
import '../detail_view_parts/milk_entry_page.dart';
import '../detail_view_parts/weight_entry_page.dart';
import 'add_cattle_view.dart';

class CattleDetailCard extends StatefulWidget {
  CattleEntry cattle;
  final String userId;
  final String cattleId;

  CattleDetailCard({
    Key? key,
    required this.cattle,
    required this.userId,
    required this.cattleId,
  }) : super(key: key);

  @override
  _CattleDetailCardState createState() => _CattleDetailCardState();
}

class _CattleDetailCardState extends State<CattleDetailCard> {
  List<Widget> cattleInfoRows = [];
  Set<String> addedOptions = Set<String>();
  String weight = '---';
  String milk = '---';
  String lactation = '---';
  DateTime selectedDate = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Assuming you have userId and cattleId available
    Provider.of<ActivityProvider>(context, listen: false)
        .fetchActivities(widget.userId, widget.cattleId);
  }

  @override
  Widget build(BuildContext context) {
    List<ActivityInfo> cattleActivities = widget.cattle.activities;

    ThemeData theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('', style: GoogleFonts.alata(color: Colors.white)),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.primaryColor),
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
          actions: [
            TextButton(
              onPressed: () => _navigateAndEditCattle(context),
              child: Text(AppLocalizations.of(context)!.editProfile,
                  style: GoogleFonts.alata(color: Colors.white, fontSize: 18)),
            ),
            IconButton(
                icon: Icon(Icons.delete_forever_rounded, color: Colors.white),
                onPressed: () => _confirmDelete()),
          ],
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.green.shade500,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      radius: 40,
                      child: ClipOval(
                        child: Image.asset(
                          "android/assets/animal.png",
                          fit: BoxFit.cover,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(widget.cattle.name,
                      style: GoogleFonts.alata(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text(
                      '${AppLocalizations.of(context)!.tag}: ${widget.cattle.tagNumber}',
                      style:
                          GoogleFonts.alata(color: Colors.white, fontSize: 16)),
                  Divider(color: Colors.white, thickness: 1, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.birth}: ',
                                style: GoogleFonts.alata(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: widget.cattle.birthday,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: '${AppLocalizations.of(context)!.herd}: ',
                                style: GoogleFonts.alata(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: widget.cattle.herd.isNotEmpty
                                    ? widget.cattle.herd
                                    : 'N/A',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  AttributeList(cattle: widget.cattle),
                  Divider(color: Colors.white, thickness: 1, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WeightEntryPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.weight,
                            icon: FontAwesomeIcons.weightScale,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MilkEntryPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.milk,
                            icon: FontAwesomeIcons.glassWhiskey,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LactationEntryPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.lactation,
                            icon: FontAwesomeIcons.babyCarriage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Add some space between the two rows

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => VaccinationEntryPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.vaccine,
                            icon: FontAwesomeIcons.syringe,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FeedEntryPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.feed,
                            icon: FontAwesomeIcons.bowlFood,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DiseaseEntryPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.medical,
                            icon: FontAwesomeIcons.briefcaseMedical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 9), // Add some space between the two rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WeightCalculatorPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.weightCalc,
                            icon: FontAwesomeIcons.calculator,
                          ),
                        ),
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DMICalculatorPage(
                                  cattleId: widget.cattleId,
                                ),
                              ),
                            );
                          },
                          child: InfoCard(
                            title: AppLocalizations.of(context)!.dmiCalc,
                            icon: FontAwesomeIcons.calculator,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _navigateAndEditCattle(BuildContext context) async {
    // Assuming AddCattlePage accepts a CattleEntry object and a cattleId for editing
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddCattlePage(
          cattle: widget.cattle, // Pass the current CattleEntry object
          isEditing: true,
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Cattle Profile'),
          content: Text('Are you sure you want to delete this cattle profile?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                final cattleId = widget.cattle.id; // Get the cattle ID
                if (cattleId != null && cattleId.isNotEmpty) {
                  try {

                    await FirebaseFirestore.instance
                        .collection('cattle')
                        .doc(cattleId)
                        .delete();

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .collection('userCattle')
                        .doc(cattleId)
                        .delete();

                    // Remove the cattle entry from CattleModel
                    Provider.of<CattleModel>(context, listen: false)
                        .removeCattleEntry(cattleId);

                    // Pop the current page (detail view) and go back
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Pop detail view
                  } catch (e) {
                    print("Error deleting cattle: $e");
                    // Handle the error (e.g., show an error message to the user)
                  }
                } else {
                  // Handle the case where the document ID is empty or null
                  print("Error: Document ID is empty or null.");
                  // You can display an error message to the user or handle it accordingly.
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;

  InfoCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightGreen, // Background color
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust padding as needed
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center icon and title
          children: [
            Icon(icon, color: Colors.white, size: 24), // Icon with white color
            const SizedBox(height: 10), // Space between icon and title
            Text(
              title,
              style: GoogleFonts.alata(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Adjust font size as needed
                  color: Colors.white), // Title with white color
            ),
          ],
        ),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String value;
  final IconData icon;

  DetailSection(
      {super.key,
      required this.theme,
      required this.title,
      required this.value,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: theme.primaryColor),
        SizedBox(width: 8),
        Text('$title: ',
            style:
                theme.textTheme.subtitle1?.copyWith(color: theme.primaryColor)),
        Flexible(
            child: Text(value,
                style: theme.textTheme.subtitle1,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class AttributeList extends StatelessWidget {
  final CattleEntry cattle;

  AttributeList({required this.cattle});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        AttributeCard(
          theme: theme,
          title: AppLocalizations.of(context)!.mother,
          value: cattle.mother.isNotEmpty ? cattle.mother : 'N/A',
          icon: FontAwesomeIcons.venus,
        ),
        AttributeCard(
          theme: theme,
          title: AppLocalizations.of(context)!.inseminator,
          value: cattle.inseminator.isNotEmpty ? cattle.inseminator : 'N/A',
          icon: FontAwesomeIcons.mars,
        ),
        AttributeCard(
          theme: theme,
          title: AppLocalizations.of(context)!.breed,
          value: cattle.breed.isNotEmpty ? cattle.breed : 'N/A',
          icon: FontAwesomeIcons.dna,
        ),
      ],
    );
  }
}

class AttributeCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String value;
  final IconData icon;

  AttributeCard({
    required this.theme,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      // Reduced padding
      margin: EdgeInsets.only(bottom: 8),
      // Reduced margin
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Spread title and value
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.alata(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white), // Smaller text size
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.alata(fontSize: 14, color: Colors.white),
              // Smaller text size
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
