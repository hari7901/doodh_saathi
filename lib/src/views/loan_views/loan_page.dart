import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../commodity_detail/supplies.dart';

class LoanPage extends StatefulWidget {
  @override
  _LoanPageState createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myLoan, style: GoogleFonts.alata(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal, Colors.lightGreen],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('wallet_info')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                double credit = 0.0;
                snapshot.data?.docs.forEach((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  if (data.containsKey('loan')) {
                    credit = data['loan'].toDouble();
                  }
                });

                return _buildCreditDisplay(credit);
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _buildContinueShoppingButton(),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(AppLocalizations.of(context)!.transactionHistory),
            _buildTransactionHistory(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueShoppingButton() {
    return ElevatedButton(
      onPressed: () =>
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryPage()), // Adjust as necessary
          ),
      child: Text(AppLocalizations.of(context)!.continueShopping, style: GoogleFonts.alata(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  Widget _buildCreditDisplay(double credit) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.availableCredit,
                style: GoogleFonts.alata(fontSize: 18, color: Colors.white)),
            SizedBox(height: 8),
            Text('₹${credit.toStringAsFixed(2)}', style: GoogleFonts.alata(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(title,
            style: GoogleFonts.alata(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String productName = data['productName'] ?? 'Unknown Product';
            Timestamp timestamp = data['date'] as Timestamp;
            DateTime date = timestamp.toDate();
            String formattedDate = DateFormat('MMM dd, yyyy – kk:mm').format(date);
            double amount = data['amount']?.toDouble() ?? 0.0;
            String imageUrl = data['imageUrl'] ?? '';
            int quantity = data['quantity'] ?? 0;

            return Card(
              color: Colors.teal.shade200,
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added MainAxisAlignment
                  children: [
                    imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                    )
                        : SizedBox(width: 80, height: 80, child: Placeholder()), // Shows a placeholder if no image
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(productName, style: GoogleFonts.alata(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 4),
                            Text(formattedDate, style: GoogleFonts.alata(fontSize: 14, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('${AppLocalizations.of(context)!.quantity}: $quantity', style: GoogleFonts.alata(fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    Text('\₹${amount.toStringAsFixed(2)}', style: GoogleFonts.alata(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}
