import 'dart:ui';
import 'package:flutter/material.dart';
import 'language_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues ageRange = const RangeValues(25, 30);
  double distance = 80;

  bool ageToggle = true;
  bool distanceToggle = false;
  bool verifiedOnly = false;

  String selectedGender = "Men";

  List<String> interests = ["Music", "Fitness", "Travel", "Art", "Cooking"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffF8E0E8), Color(0xffE9D6F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// FILTER TABS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          "Basic filters",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pink),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          "Advanced filters",
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// WHO WOULD YOU LIKE TO DATE
                const Text(
                  "Who would you like to date?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _showGenderSheet,
                  child: _card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedGender),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// AGE FILTER
                const Text(
                  "How old are they?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Between ${ageRange.start.round()} and ${ageRange.end.round()}",
                      ),

                      RangeSlider(
                        values: ageRange,
                        min: 18,
                        max: 60,
                        activeColor: Colors.pink,
                        inactiveColor: Colors.pink.shade100,
                        onChanged: (values) {
                          setState(() {
                            ageRange = values;
                          });
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "See people 2 years either side if I run out",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),

                          Switch(
                            value: ageToggle,
                            activeColor: Colors.pink,
                            onChanged: (val) {
                              setState(() {
                                ageToggle = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// DISTANCE FILTER
                const Text(
                  "How far away are they?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Up to ${distance.round()} kilometres away"),

                      Slider(
                        value: distance,
                        min: 1,
                        max: 100,
                        activeColor: Colors.pink,
                        inactiveColor: Colors.pink.shade100,
                        onChanged: (value) {
                          setState(() {
                            distance = value;
                          });
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "See people slightly further away if I run out",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),

                          Switch(
                            value: distanceToggle,
                            activeColor: Colors.pink,
                            onChanged: (val) {
                              setState(() {
                                distanceToggle = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// INTERESTS
                const Text(
                  "Do they share any of your interests?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Filter by your interests",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests
                      .map(
                        (e) => Chip(
                          label: Text(e, style: const TextStyle(fontSize: 13)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              interests.remove(e);
                            });
                          },
                          backgroundColor: Colors.pink.shade50,
                          deleteIconColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 10),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.pink,
                    side: const BorderSide(color: Colors.pink),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _showAddInterestDialog,
                  child: const Text("Add more +"),
                ),

                const SizedBox(height: 25),

                /// VERIFIED ONLY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.pink),
                        SizedBox(width: 8),
                        Text(
                          "Verified only",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    Switch(
                      value: verifiedOnly,
                      activeColor: Colors.pink,
                      onChanged: (val) {
                        setState(() {
                          verifiedOnly = val;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// LANGUAGES
                const Text(
                  "Which languages do they know?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageScreen(),
                      ),
                    );
                  },
                  child: _card(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select languages"),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// CARD UI
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  /// GENDER BOTTOM SHEET
  void _showGenderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Who would you like to date?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                _genderOption("Men"),
                _genderOption("Women"),
                _genderOption("Nonbinary people"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _genderOption(String gender) {
    bool selected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });

        Navigator.pop(context);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.pink : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color: selected ? Colors.pink.shade50 : Colors.white,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(gender),

            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.pink : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  /// ADD INTEREST DIALOG
  void _showAddInterestDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Add Interest",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.pink,
            decoration: InputDecoration(
              hintText: "Enter interest",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade100, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade100, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.pink, width: 1.2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                final String interest = controller.text.trim();
                if (interest.isNotEmpty && !interests.contains(interest)) {
                  setState(() {
                    interests.add(interest);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
