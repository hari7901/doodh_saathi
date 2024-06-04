import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class FeedCalculatorPage extends StatefulWidget {
  @override
  _FeedCalculatorPageState createState() => _FeedCalculatorPageState();
}

class _FeedCalculatorPageState extends State<FeedCalculatorPage> {
  final TextEditingController _bodyWeightController = TextEditingController();
  double _recommendedFeed = 0.0;
  bool _hasCalculated = false; // To track if calculation has been done

  void calculateFeed() {
    final bodyWeight = double.tryParse(_bodyWeightController.text);
    if (bodyWeight != null) {
      // Assuming 3% of body weight as the recommended feed amount
      // and converting the result to grams for display
      _recommendedFeed = bodyWeight * 0.03; // Convert kg to grams
      _hasCalculated = true;
    } else {
      _recommendedFeed = 0.0; // Reset to 0 if input is invalid
      _hasCalculated = false;
    }
    // Clear the input field after calculation
    _bodyWeightController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.feedCalc, style: GoogleFonts.alata(color: Colors.white)),
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
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.enterBodyWeight,
                  style: GoogleFonts.alata(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                controller: _bodyWeightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.bodyWeight,
                  labelStyle: GoogleFonts.alata(color: Colors.white), // Set the label text color to white
                  enabledBorder: OutlineInputBorder( // Normal state border
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder( // Border when TextField is focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear,color: Colors.white,),
                    onPressed: () => _bodyWeightController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: calculateFeed,
                  child: Text(AppLocalizations.of(context)!.calculate,style: GoogleFonts.alata(color:Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: GoogleFonts.alata(fontSize: 18,color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_hasCalculated) ...[
                Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.recommendedFeed} ${_recommendedFeed.toStringAsFixed(2)} Kg',
                    style: GoogleFonts.alata(fontSize: 18, color: Colors.white),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
