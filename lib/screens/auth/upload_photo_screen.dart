import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'final_step_screen.dart';

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {

  File? image;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void continueNext() {

  if (image == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FinalStepScreen(image: image),
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
              Color(0xFFF3E7FF),
              Color(0xFFFFE3EC),
            ],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "STEP 5 OF 5",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: 1,
                  backgroundColor: Colors.purple.shade100,
                  color: Colors.purple,
                ),

                const SizedBox(height: 40),

                const Text(
                  "Add a profile picture",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(25),
                      dashPattern: const [6,4],
                      color: Colors.purple,
                      strokeWidth: 2,
                      child: Container(
                        width: 220,
                        height: 220,
                        alignment: Alignment.center,

                        child: image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [

                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.purple,
                                  ),

                                  SizedBox(height: 10),

                                  Text(
                                    "Upload a Photo",
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                  width: 220,
                                  height: 220,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

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
                    onPressed: continueNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}