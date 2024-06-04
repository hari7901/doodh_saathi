import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeightCalculatorPage extends StatefulWidget {
  final String cattleId;

  WeightCalculatorPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  _WeightCalculatorPageState createState() => _WeightCalculatorPageState();
}

class _WeightCalculatorPageState extends State<WeightCalculatorPage> {
  final TextEditingController _girthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  double? _calculatedWeight;
  String _selectedUnit = 'cm'; // Default to metric system

  void calculateWeight() {
    final girth = double.tryParse(_girthController.text);
    final length = double.tryParse(_lengthController.text);
    if (girth != null && length != null) {
      if (_selectedUnit == 'cm') {
        // Using metric system
        _calculatedWeight = (girth * girth * length) / 11000;
      } else {
        // Using imperial system
        _calculatedWeight = (girth * girth * length) / 300;
      }
      setState(() {
        _girthController.clear();
        _lengthController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cowWeightCalculator, style: GoogleFonts.alata(color: Colors.white)),
        backgroundColor: Colors.teal,
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for your image
              Container(
                height: 200, // Adjust the size to fit your needs
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('android/assets/cowMeasure.png'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.selectUnit, style: GoogleFonts.alata(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
              DropdownButton<String>(
                value: _selectedUnit,
                onChanged: (value) => setState(() => _selectedUnit = value!),
                items: ['cm', 'in'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),
                underline: Container(
                  height: 2,
                  color: Colors.teal.shade700,
                ),
              ),
              SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.enterGirth, style: GoogleFonts.alata(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
              SizedBox(height: 8),
              TextField(
                style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                controller: _girthController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${AppLocalizations.of(context)!.girth} ($_selectedUnit)',
                  labelStyle: GoogleFonts.alata(color: Colors.white), // Set the label text color to white
                  icon: Icon(Icons.straighten,color: Colors.white,),
                  enabledBorder: OutlineInputBorder( // Normal state border
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder( // Border when TextField is focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.enterLength, style: GoogleFonts.alata(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
              SizedBox(height: 8),
              TextField(
                style: GoogleFonts.alata(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                controller: _lengthController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${AppLocalizations.of(context)!.length} ($_selectedUnit)',
                  labelStyle: GoogleFonts.alata(color: Colors.white), // Set the label text color to white
                  icon: Icon(Icons.straighten, color: Colors.white),
                  enabledBorder: OutlineInputBorder( // Normal state border
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder( // Border when TextField is focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: calculateWeight,
                icon: Icon(Icons.calculate,color: Colors.white,),
                label: Text(AppLocalizations.of(context)!.calcWeight, style: GoogleFonts.alata(fontSize: 18,color:Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  minimumSize: Size(double.infinity, 50), // double.infinity is the width and 50 is the height
                ),
              ),
              if (_calculatedWeight != null) ...[
                SizedBox(height: 20),
                Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.estimatedWeight}: ${_calculatedWeight!.toStringAsFixed(2)} ${_selectedUnit == 'cm' ? 'kg' : 'lbs'}',
                    style: GoogleFonts.alata(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.white),
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
