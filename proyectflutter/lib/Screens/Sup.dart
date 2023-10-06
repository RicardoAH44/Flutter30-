import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const SupPage());

class SupPage extends StatefulWidget {
  const SupPage({Key? key}) : super(key: key);

  @override
  _SupPageState createState() => _SupPageState();
}

class _SupPageState extends State<SupPage> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng _currentLocation = LatLng(0.0, 0.0); // Ubicación inicial
  Set<Marker> _markers = {}; // Set to store markers

  @override
  void initState() {
    super.initState();
    _centerMapOnUserLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _centerMapOnUserLocation() async {
    try {
      var userLocation = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
      });
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(userLocation.latitude!, userLocation.longitude!),
        ),
      );
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  Future<void> _searchNearbyHospitals() async {
    final apiKey = 'AIzaSyDnVASaBzWWIx0ZaO5E5legQLNGrqMIztk'; // Replace with your API key
    final radius = 10000; // Radius in meters to search for nearby hospitals (adjust as needed)
    final type = 'hospital';

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLocation.latitude},${_currentLocation.longitude}&radius=$radius&type=$type&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      // Clear existing markers
      _markers.clear();

      // Add new markers for hospitals
      results.forEach((hospital) {
        final name = hospital['name'];
        final lat = hospital['geometry']['location']['lat'];
        final lng = hospital['geometry']['location']['lng'];

        final hospitalLocation = LatLng(lat, lng);

        _markers.add(
          Marker(
            markerId: MarkerId(name),
            position: hospitalLocation,
            infoWindow: InfoWindow(
              title: name,
            ),
          ),
        );
      });

      // Update the map to display the new markers
      setState(() {});
    } else {
      throw Exception('Error al obtener hospitales cercanos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa con Ubicación Actual'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 11.0,
                ),
                markers: _markers, // Display markers from the set
              ),
            ),
            ElevatedButton(
              onPressed: _searchNearbyHospitals,
              child: Text('Buscar Hospitales Cercanos'),
            ),
          ],
        ),
      ),
    );
  }
}
