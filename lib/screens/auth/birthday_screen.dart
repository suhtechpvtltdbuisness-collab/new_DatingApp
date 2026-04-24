import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'describe_screen.dart';
import 'base_layout.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final List<String> months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  int selectedMonth = 5;
  int selectedDay = 14;
  int selectedYear = 1999;
  final RegistrationController registrationController = Get.find<RegistrationController>();

  int calculateAge() {
    final now = DateTime.now();
    int age = now.year - selectedYear;
    return age;
  }

  void goNext() {
    // Format DOB as YYYY-MM-DD
    String dob = '${selectedYear.toString().padLeft(4, '0')}-${(selectedMonth + 1).toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}';
    registrationController.setDob(dob);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DescribeScreen()),
    );
  }

  Widget wheelPicker({
    required List items,
    required int selectedIndex,
    required Function(int) onChanged,
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 160,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 42,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(
          initialItem: selectedIndex,
        ),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {

            final isSelected = index == selectedIndex;

            return Center(
              child: Text(
                items[index].toString(),
                style: TextStyle(
                  fontSize: isSelected ? 20 : 16,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return baseLayout(
      context: context,
      step: 4,
      totalSteps: 8,
      title: "birthday",
      onContinue: goNext,
      child: Column(
        children: [

          /// Picker
          Stack(
            alignment: Alignment.center,
            children: [

              /// Highlight
              Container(
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.purple),
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.withOpacity(.25),
                      Colors.purple.withOpacity(.25),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  wheelPicker(
                    items: months,
                    selectedIndex: selectedMonth,
                    onChanged: (index) {
                      setState(() {
                        selectedMonth = index;
                      });
                    },
                    width: 130,
                  ),

                  wheelPicker(
                    items: List.generate(31, (i) => i + 1),
                    selectedIndex: selectedDay,
                    onChanged: (index) {
                      setState(() {
                        selectedDay = index;
                      });
                    },
                    width: 70,
                  ),

                  wheelPicker(
                    items: List.generate(60, (i) => 1965 + i),
                    selectedIndex: selectedYear - 1965,
                    onChanged: (index) {
                      setState(() {
                        selectedYear = 1965 + index;
                      });
                    },
                    width: 80,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),
               
          /// Age badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.pink.withOpacity(.25),
                  Colors.purple.withOpacity(.25),
                ],
              ),
            ),
            child: Text(
              "You are ${calculateAge()} years old",
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "By tapping continue, you confirm this is\n"
            "your correct date of birth.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),

        ],
      ),
    );
  }
}