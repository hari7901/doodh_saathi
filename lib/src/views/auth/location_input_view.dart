import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  GoogleMapController? _mapController;
  TextEditingController _addressController = TextEditingController();
  LatLng? _pickedLocation;
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _updateLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get current location')));
    }
  }

  Future<void> _updateLocation(LatLng newPosition) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(newPosition.latitude, newPosition.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _pickedLocation = newPosition;
          _currentAddress = '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}';
          _addressController.text = _currentAddress;
          _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get address')));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    _updateLocation(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Location'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _pickedLocation ?? LatLng(0, 0),
              zoom: 14,
            ),
            onTap: _onMapTapped,
            markers: _pickedLocation != null
                ? {Marker(markerId: MarkerId('m1'), position: _pickedLocation!)}
                : {},
          ),
          Positioned(
            top: 10,
            right: 15,
            left: 15,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  controller: _addressController,
                  readOnly: true, // Set to true since we're auto-filling the address
                  decoration: InputDecoration(
                    hintText: 'Current Address',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickedLocation != null ? () {
          // Handle location picked
        } : null,
        child: Icon(Icons.check),
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
