import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Readmap extends StatefulWidget {
  const Readmap({super.key});

  @override
  State<Readmap> createState() => _ReadmapState();
}

class _ReadmapState extends State<Readmap> {
  String? _latitude;
  String? _longitude;
  String? _address;
  bool _isLoading = false;

  //mendapatkan lokasi
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('IJin Lokasi di perlukan'),
      ));
      setState(() {
        _isLoading = true;
      });
      return;
    }

    //mendapatkan lokasi terkini
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));

      //mendapatkan alamt dari koordinat
      await _getAddress(position);

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //mendapatkan alamat berdasarkan koordinat
  Future<void> _getAddress(Position position) async {
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemark.first;
      setState(() {
        _address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal Mendapatkan Alamat: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Terkini'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  Text('Latitude: $_latitude'),
                  Text('Longitude: $_longitude'),
                  if (_address != null) Text('Alamat: $_address')
                ],
              ),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
