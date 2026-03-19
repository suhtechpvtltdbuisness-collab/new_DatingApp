import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  bool showOthers = false;

  List<String> languages = [
    "Afar",
    "Afrikaans",
    "Albanian",
    "American Sign Language",
    "Amharic",
    "Arabic",
    "Aramaic",
    "Armenian",
    "Assamese",
  ];

  List<String> selectedLanguages = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffF8E0E8),
              Color(0xffE9D6F3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// HEADER
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [

                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const Text(
                      "Languages they know",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              /// DESCRIPTION
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Looking for people who know specific languages?\n"
                  "Select up to 3 languages and we'll try and connect you "
                  "with people who know all of them.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search for a language",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// LANGUAGE LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {

                    String lang = languages[index];
                    bool selected = selectedLanguages.contains(lang);

                    return GestureDetector(
                      onTap: () {

                        setState(() {

                          if (selected) {
                            selectedLanguages.remove(lang);
                          } else {
                            if (selectedLanguages.length < 3) {
                              selectedLanguages.add(lang);
                            }
                          }

                        });
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? Colors.pink
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(lang),

                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: selected
                                  ? Colors.pink
                                  : Colors.grey,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// BOTTOM SWITCH
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Show other people if I run out",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Expand your search area if needed",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    Switch(
                      value: showOthers,
                      activeColor: Colors.pink,
                      onChanged: (v) {
                        setState(() {
                          showOthers = v;
                        });
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}