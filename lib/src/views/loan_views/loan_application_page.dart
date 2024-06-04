import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_profile_service.dart';
import 'loan_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LoanApplicationPage extends StatefulWidget {
  @override
  _LoanApplicationPageState createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _monthlyIncomeController =
      TextEditingController();
  final TextEditingController _panCardController =
  TextEditingController();
   late String _gender;
   late String _employmentStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize _gender and _employmentStatus here
    _gender = AppLocalizations.of(context)?.male ?? 'Male';
    _employmentStatus = AppLocalizations.of(context)?.salaried ?? 'Salaried';
  }


  @override
  void dispose() {
    _aadhaarNumberController.dispose();
    _nameController.dispose();
    _monthlyIncomeController.dispose();
    _panCardController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is currently logged in')),
        );
        return;
      }

      try {
        await UserService.addLoanApplication(
          _aadhaarNumberController.text,
          _panCardController.text,
          _nameController.text,
          _monthlyIncomeController.text,
          _gender!,
          _employmentStatus!,
          userId,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoanPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        canvasColor: Colors.green,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pay Later',
              style: GoogleFonts.alata(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.green,
                  Colors.teal,
                ],
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildCustomTextField(
                    AppLocalizations.of(context)!.adhaarNumber, Icons.person, _aadhaarNumberController,
                    (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Aadhaar number';
                  } else if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                    return 'Enter a valid 12-digit Aadhaar number';
                  }
                  return null;
                }),
                SizedBox(height: 15.0),

                _buildCustomTextField(
                    AppLocalizations.of(context)!.panNumber,
                    Icons.credit_card,
                    _panCardController, // Define a TextEditingController for PAN card
                        (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your PAN card number';
                      } else if (!RegExp(r'^[A-Za-z0-9]{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-character PAN card number';
                      }
                      return null;
                    }
                ),
                SizedBox(height: 15.0),
                _buildCustomTextField(
                    AppLocalizations.of(context)!.name, Icons.account_circle, _nameController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                }),
                SizedBox(height: 15.0),
                _buildCustomTextField(AppLocalizations.of(context)!.monthlyIncome, Icons.monetization_on,
                    _monthlyIncomeController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your monthly income';
                  }
                  return null;
                }),
                SizedBox(height: 15.0),
                _buildGenderSelector(),
                SizedBox(height: 15.0),
                _buildEmploymentStatusSelector(),
                SizedBox(height: 25.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(AppLocalizations.of(context)!.applyForLoan,
                      style: GoogleFonts.alata(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(String label, IconData icon,
      TextEditingController controller, FormFieldValidator<String> validator) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.green,
            Colors.teal,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.alata(color: Colors.white),
            prefixIcon: Icon(icon, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String title, String value, List<String> options,
      IconData icon, ValueChanged<String?> onChanged) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.green,
            Colors.teal,
          ],
        ),
      ),
      padding: EdgeInsets.only(left: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          style: GoogleFonts.alata(color: Colors.white, fontSize: 16),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(width: 10),
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {

    List<String> genderOptions = [
      AppLocalizations.of(context)!.male,
      AppLocalizations.of(context)!.female,
      AppLocalizations.of(context)!.other,
    ];
    return _buildDropdownButton(AppLocalizations.of(context)!.gender, _gender!, genderOptions,
        Icons.person, (newValue) => setState(() => _gender = newValue!));
  }

  Widget _buildEmploymentStatusSelector() {
    List<String> employmentOptions = [
      AppLocalizations.of(context)!.salaried,
      AppLocalizations.of(context)!.selfEmployed,
    ];
    return _buildDropdownButton(
        AppLocalizations.of(context)!.employmentStatus,
        _employmentStatus!,
        employmentOptions,
        Icons.work,
        (newValue) => setState(() => _employmentStatus = newValue!));
  }
}
