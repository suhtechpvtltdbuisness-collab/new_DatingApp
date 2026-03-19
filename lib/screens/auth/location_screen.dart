import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  /// Function to check location permission
  Future<void> _checkLocation(BuildContext context) async {

    bool serviceEnabled;
    LocationPermission permission;

    /// 1️⃣ Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    /// 2️⃣ Check permission
    permission = await Geolocator.checkPermission();

    /// If permission not given → request permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    /// If permission denied again → stop
    if (permission == LocationPermission.denied) {
      return;
    }

    /// If permission permanently denied
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    /// 3️⃣ If permission granted → get location
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");

      /// Navigate to Home Screen
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E7FF),
              Color(0xFFFFE3EC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.purple,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Can we get your location, please?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "We need it so we can show you people nearby.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF4E8A),
                        Color(0xFF9B51E0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _checkLocation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Check location settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
}