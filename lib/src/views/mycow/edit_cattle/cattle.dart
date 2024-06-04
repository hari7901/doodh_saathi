import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/cattle_model.dart';
import '../../../utils/cattleId.dart';
import 'detail_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CattleView extends StatefulWidget {
  const CattleView({Key? key}) : super(key: key);

  @override
  State<CattleView> createState() => _CattleViewState();
}

class _CattleViewState extends State<CattleView> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.green.shade500,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cattle').where('userId', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return Text("Error fetching data");
          }

          print("Fetched Documents Count: ${snapshot.data?.docs.length}");

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.noCattleData,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final cattleDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cattleDocs.length,
            itemBuilder: (context, index) {
              final doc = cattleDocs[index];
              final cattleData = doc.data() as Map<String, dynamic>;
              final cattleId = doc.id;

              // Convert Firestore doc to CattleEntry (implement this according to your model)
              final cattle = CattleEntry.fromMap(cattleData..['id'] = cattleId);

              return InkWell(
                onTap: () {
                  Provider.of<CattleIdProvider>(context, listen: false).setCattleId(cattleId);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CattleDetailCard(
                        cattle: cattle,
                        userId: userId,
                        cattleId: cattleId,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    color: Colors.lightGreen,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "android/assets/cow2.png", // Ensure this asset path is correct.
                                width: 30,
                                height: 30,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cattle.name,
                                      style: GoogleFonts.alata(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    maxLines: 1, // Ensure it doesn't wrap into multiple lines
                                    overflow: TextOverflow.ellipsis, // Add this line
                                  ),

                                  Text(
                                    '${AppLocalizations.of(context)!.tag}: ${cattle.tagNumber}',
                                    style: GoogleFonts.alata(fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 24.0),
                                child: Text(AppLocalizations.of(context)!.birth,
                                    style: GoogleFonts.alata(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16)),
                              ),
                              Row(
                                children: [
                                  Icon(FontAwesomeIcons.cow,
                                      size: 24, color: Colors.teal.shade900),
                                  const SizedBox(width: 10),
                                  Text(cattle.birthday,
                                      style: GoogleFonts.alata(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
