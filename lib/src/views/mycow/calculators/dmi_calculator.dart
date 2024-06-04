import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DMICalculatorPage extends StatefulWidget {
  final String cattleId;

  DMICalculatorPage({Key? key, required this.cattleId}) : super(key: key);

  @override
  _DMICalculatorPageState createState() => _DMICalculatorPageState();
}

class _DMICalculatorPageState extends State<DMICalculatorPage> {
  final TextEditingController _milkYieldController = TextEditingController();
  final TextEditingController _bodyWeightController = TextEditingController();
  int _selectedLactationPhaseIndex = 0;
  double? _calculatedDMI;
  double? _calculatedFeedDM;
  double? _calculatedFodderDM;
  double? _calculatedSilageDM;
  List<String> _lactationPhases = [];  // Declaration without initialization

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Ensures that the context is available
      if (mounted) {
        setState(() {
          _lactationPhases = [
            AppLocalizations.of(context)!.earlyLact,
            AppLocalizations.of(context)!.mildLact,
            AppLocalizations.of(context)!.latelact,
            AppLocalizations.of(context)!.dryPeriod,
            AppLocalizations.of(context)!.transitionPeriod,
          ];
        });
      }
    });
  }


  final List<double> _lactationFactors = [3.0, 2.5, 2.0, 1.8, 2.2];

  void calculateDMI() {
    final bodyWeight = double.tryParse(_bodyWeightController.text) ?? 0;
    final milkYield = double.tryParse(_milkYieldController.text) ?? 0;
    final dmiFactor = _lactationFactors[_selectedLactationPhaseIndex];

    // Use the given formula for DMI calculation
    final dmi = 8.499 + (0.2725 * dmiFactor) + (0.2132 * milkYield) + (0.0095 * bodyWeight);

    // Assuming 60% of DMI is met through feed and 40% through fodder
    _calculatedFeedDM = dmi * 0.5;
    _calculatedFodderDM = dmi * 0.3;
    _calculatedSilageDM = dmi * 0.2; // 20% of DMI

    setState(() {
      _calculatedDMI = dmi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade500,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dmiCalc, style: GoogleFonts.alata(color: Colors.white)),
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
                Colors.teal,
                Colors.lightGreen,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.lacationPhase, style: GoogleFonts.alata(fontSize: 20, color: Colors.white)),
            SizedBox(height: 10),
            Wrap(
              children: List<Widget>.generate(
                _lactationPhases.length,
                    (index) {
                  return ChoiceChip(
                    label: Text(_lactationPhases[index], style: GoogleFonts.alata(color: _selectedLactationPhaseIndex == index ? Colors.white : Colors.black)),
                    selected: _selectedLactationPhaseIndex == index,
                    selectedColor: Colors.teal,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedLactationPhaseIndex = selected ? index : null!;
                      });
                    },
                    backgroundColor: Colors.lightGreen,
                    labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  );
                },
              ).toList(),
              spacing: 8.0,
              runSpacing: 4.0,
            ),
            SizedBox(height: 20),
            _buildInputField(_milkYieldController, AppLocalizations.of(context)!.milkYield),
            _buildInputField(_bodyWeightController, AppLocalizations.of(context)!.bodyWeight),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateDMI,
              child: Text(AppLocalizations.of(context)!.calculateDMI, style: GoogleFonts.alata(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
            ),
            if (_calculatedDMI != null) _buildResultDMI(),
            if (_calculatedDMI != null) _buildResultSilage(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.alata(color: Colors.white),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        ),
        style: GoogleFonts.alata(color: Colors.white),
      ),
    );
  }

  Widget _buildResultDMI() {
    return Card(
      color: Colors.lightGreen,
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('DMI Results', style: GoogleFonts.alata(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            Divider(color: Colors.white),
            Text('Estimated DMI: ${_calculatedDMI!.toStringAsFixed(2)} kg/day', style: GoogleFonts.alata(fontSize: 18, color: Colors.white)),
            Text('Feed (DM): ${_calculatedFeedDM!.toStringAsFixed(2)} kg', style: GoogleFonts.alata(fontSize: 18, color: Colors.white)),
            Text('Fodder (DM): ${_calculatedFodderDM!.toStringAsFixed(2)} kg', style: GoogleFonts.alata(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSilage() {
    return Card(
      color: Colors.lightGreen,
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Silage(DM)', style: GoogleFonts.alata(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            Divider(color: Colors.white),
            Text('Silage: ${_calculatedSilageDM!.toStringAsFixed(2)} kg', style: GoogleFonts.alata(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
