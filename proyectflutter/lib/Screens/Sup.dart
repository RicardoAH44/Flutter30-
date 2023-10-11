import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  Set<Marker> _markers = {}; // Conjunto de marcadores
  Set<Polyline> _polylines = {}; // Conjunto de polilíneas para rutas

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

        // Agregar un marcador personalizado para la ubicación del usuario
        _markers.add(
          Marker(
            markerId: MarkerId('user_location'),
            position: _currentLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: 'Tu ubicación actual',
            ),
          ),
        );

        // Llama a la función para buscar hospitales después de obtener la ubicación
        _searchNearbyHospitals();
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
    final apiKey = 'AIzaSyDnVASaBzWWIx0ZaO5E5legQLNGrqMIztk';
    final radius = 10000;
    final type = 'hospital';

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLocation.latitude},${_currentLocation.longitude}&radius=$radius&type=$type&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      // Limpia los marcadores existentes y las polilíneas
      _markers.removeWhere((marker) => marker.markerId != MarkerId('user_location'));
      _polylines.clear();

      // Agrega nuevos marcadores para los hospitales
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
            onTap: () {
              _getDirections(hospitalLocation); // Cambia el nombre de la variable aquí
            },
          ),
        );
      });

      // Actualiza el mapa para mostrar los nuevos marcadores
      setState(() {});
    } else {
      throw Exception('Error al obtener hospitales cercanos');
    }
  }

  Future<void> _getDirections(LatLng hospitalLocation) async { // Cambia el nombre de la variable aquí
    final googleApiKey = 'AIzaSyDnVASaBzWWIx0ZaO5E5legQLNGrqMIztk'; // Reemplaza con tu clave de API de Google
    final directionsApi = 'https://maps.googleapis.com/maps/api/directions/json?';

    final origin = _currentLocation;
    final destination = hospitalLocation; // Cambia el nombre de la variable aquí

    final url = '$directionsApi'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'key=$googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> routes = data['routes'];
      if (routes.isNotEmpty) {
        final points = PolylinePoints().decodePolyline(routes[0]['overview_polyline']['points']);
        List<LatLng> polylineCoordinates = [];
        for (PointLatLng point in points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        // Agrega la ruta como una polilínea al conjunto de polilíneas
        _polylines.add(Polyline(
          polylineId: PolylineId('polyLineId'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ));
      }
    } else {
      throw Exception('Error al obtener direcciones');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa con Ubicación Actual y Hospitales Cercanos'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 15.0,
                ),
                markers: _markers,
                polylines: _polylines, // Muestra las polilíneas en el mapa
              ),
            ),
          ],
        ),
      ),
    );
  }
}
