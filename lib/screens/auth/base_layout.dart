import 'package:flutter/material.dart';
import 'package:dating_app/utils/theme.dart';

Widget baseLayout({
  required BuildContext context,
  required int step,
  required int totalSteps,
  required String title,
  required Widget child,
  required VoidCallback onContinue,
}) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 20),

                      /// Back Button
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

                      /// Step Text
                      Text(
                        "STEP $step OF $totalSteps",
                        style: const TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Progress Bar
                      LinearProgressIndicator(
                        value: step / totalSteps,
                        backgroundColor: AppTheme.accentColor.withOpacity(0.15),
                        color: AppTheme.accentColor,
                      ),

                      const SizedBox(height: 40),

                      /// Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Page Content
                      child,

                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 20),

                      /// Continue Button
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
                          onPressed: onContinue,
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
            );
          },
        ),
      ),
    ),
  );
}