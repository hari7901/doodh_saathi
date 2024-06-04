import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NearestVetPage extends StatefulWidget {
  @override
  _NearestVetPageState createState() => _NearestVetPageState();
}

class _NearestVetPageState extends State<NearestVetPage> {
  double _currentSliderValue = 0.0;
  List<Map<String, dynamic>> _nearestVets = [];
  bool _isFetching = true;
  Position? _userPosition;
  String _statusMessage = 'Determining your location...';

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _userPosition = position;
        _isFetching = false;
      });
      _fetchNearestVets(_currentSliderValue);
    }).catchError((error) {
      setState(() {
        _statusMessage = error.toString();
        _isFetching = false;
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable the location services.
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next step is to ask for them again.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _fetchNearestVets(double radius) async {
    if (_userPosition == null) {
      setState(() {
        _statusMessage = "Your location is not determined yet.";
      });
      return;
    }

    setState(() {
      _nearestVets.clear(); // Clear the list to refresh the UI with new fetch
    });

    final vetsCollection = FirebaseFirestore.instance.collection('veterinaries');
    final querySnapshot = await vetsCollection.get();

    List<Map<String, dynamic>> fetchedVets = [];
    for (var vetDoc in querySnapshot.docs) {
      var vetData = vetDoc.data() as Map<String, dynamic>;
      if (vetData['location'] != null) {
        var vetLocation = vetData['location'] as GeoPoint;
        var distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          vetLocation.latitude,
          vetLocation.longitude,
        );

        // Convert distance to kilometers and check against radius
        var distanceInKm = distance / 1000;
        if (distanceInKm <= radius) {
          fetchedVets.add({
            'name': vetData['name'] ?? 'Unknown', // Providing default value
            'distance': distanceInKm,
            'number': vetData['number'] ?? 'No number available', // Providing default value
          });
        }
      }
    }

    setState(() {
      _nearestVets = fetchedVets;
      if (_nearestVets.isEmpty) {
        _statusMessage = '${AppLocalizations.of(context)!.noVetFound} ${radius.toInt()} ${AppLocalizations.of(context)!.kmRadius}.';
      }
    });
  }


  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Handle the error or show a message if the phone call can't be made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nearestVets, style: GoogleFonts.alata(color: Colors.white)),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.green, // Lighter color
                Colors.teal, // Darker color
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isFetching
                ? Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.adjustRadiusToFindVets}:',
                    style: GoogleFonts.alata(fontSize: 24),
                  ),
                ),
                Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 50,
                  divisions: 5,
                  label: '$_currentSliderValue km',
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                    _fetchNearestVets(value);
                  },
                  activeColor: Colors.teal,
                  inactiveColor: Colors.teal.withOpacity(0.3),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _nearestVets.isNotEmpty
                  ? ListView.builder(
                  itemCount: _nearestVets.length ,
                  itemBuilder:(context, index){
                    final vet = _nearestVets[index];
                    return Card(
                      color: Colors.teal.shade400,
                      elevation: 4.0,
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          vet['name'],
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${AppLocalizations.of(context)!.phone}: ${vet['number']}",style: GoogleFonts.alata(color:Colors.white,)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.phone,color: Colors.white,),
                          onPressed: () => _launchPhone(vet['number']),
                        ),
                        onTap: () {

                        },
                      ),
                    );
                  }
              )
                  : Center(child: Text(_statusMessage, style: GoogleFonts.alata(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}
