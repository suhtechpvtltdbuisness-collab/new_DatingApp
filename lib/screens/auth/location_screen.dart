import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dating_app/utils/theme.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final RegistrationController registrationController = Get.find<RegistrationController>();
  bool isLoading = false;
  int denyCount = 0;

  /// Function to check location permission
  Future<void> _checkLocation(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      bool serviceEnabled;
      LocationPermission permission;

      /// 1️⃣ Check if location service is enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        setState(() => isLoading = false);
        return;
      }

      /// 2️⃣ Check permission
      permission = await Geolocator.checkPermission();

      /// If permission not given → request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          denyCount++;
        }
      }

      /// If permission denied again → stop
      if (permission == LocationPermission.denied) {
        if (denyCount >= 2) {
          _showSettingsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission is required to continue")),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      /// If permission permanently denied
      if (permission == LocationPermission.deniedForever) {
        _showSettingsDialog();
        setState(() => isLoading = false);
        return;
      }

      /// 3️⃣ If permission granted → get location
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Store location in controller
        registrationController.setLocation([
          position.longitude.toString(),
          position.latitude.toString()
        ]);

        // Navigate to Home Screen after getting location
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get location. Please try again.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text("Location access is mandatory to use this app. Please enable it in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
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
              Color(0xFFFFD9EA),
              Color(0xFFE7D9FF),
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
                  color: AppTheme.accentColor,
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
                        Color(0xFFFF3D77),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _checkLocation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Enable Location Access",
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