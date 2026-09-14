import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dating_app/utils/theme.dart';

/// Picks a photo from [source].
///
/// On web, image_picker's camera source only opens the file dialog on desktop
/// browsers, so camera capture goes through [CameraCaptureScreen] instead.
Future<XFile?> pickProfilePhoto(
  BuildContext context,
  ImagePicker picker,
  ImageSource source,
) {
  if (kIsWeb && source == ImageSource.camera) {
    return Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
  }
  return picker.pickImage(
    source: source,
    imageQuality: 70,
    maxWidth: 1600,
    maxHeight: 1600,
  );
}

/// Full-screen live camera preview that pops with the captured [XFile].
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;
  String? _error;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }
      final front = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      await _startCamera(front >= 0 ? front : 0);
    } catch (e) {
      if (mounted) setState(() => _error = _describe(e));
    }
  }

  Future<void> _startCamera(int index) async {
    final old = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    setState(() {
      _controller = null;
      _cameraIndex = index;
    });
    await old?.dispose();
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      await controller.dispose();
      if (mounted) setState(() => _error = _describe(e));
    }
  }

  String _describe(Object e) {
    if (e is CameraException &&
        (e.code.contains('ermission') || e.code.contains('NotAllowed'))) {
      return 'Camera access was blocked. Allow camera permission in your browser and try again.';
    }
    return 'Could not open the camera.';
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(file);
    } catch (e) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Take a Photo'),
      ),
      body:
          _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Center(
                      child:
                          controller == null
                              ? const CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              )
                              : AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 56),
                        const SizedBox(width: 32),
                        GestureDetector(
                          onTap: controller == null ? null : _capture,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _capturing
                                        ? Colors.white54
                                        : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        SizedBox(
                          width: 56,
                          child:
                              _cameras.length > 1
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.cameraswitch,
                                      color: Colors.white,
                                    ),
                                    onPressed:
                                        () => _startCamera(
                                          (_cameraIndex + 1) % _cameras.length,
                                        ),
                                  )
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
