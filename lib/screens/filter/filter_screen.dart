import 'dart:ui';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/discovery_filters.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_screen.dart';
import 'package:dating_app/utils/theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final SwipeController _swipeController = Get.find<SwipeController>();

  RangeValues ageRange = const RangeValues(18, 70);
  double distance = 50;

  bool ageToggle = false;
  bool distanceToggle = false;
  bool verifiedOnly = false;

  String selectedGender = "";

  List<String> interests = [];
  List<String> languages = [];

  bool _showAdvanced = false;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  static const Map<String, String> _genderLabels = {
    'men': 'Men',
    'women': 'Women',
    'other': 'Nonbinary people',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final ok = await _swipeController.loadFilters();
    if (!mounted) return;
    setState(() {
      _applyDraft(_swipeController.filters.value);
      _loading = false;
      if (!ok) {
        _loadError = 'Could not load your saved filters. Showing defaults.';
      }
    });
  }

  void _applyDraft(DiscoveryFilters f) {
    final min =
        f.minAge
            .clamp(DiscoveryFilters.ageFloor, DiscoveryFilters.ageCeiling)
            .toDouble();
    final max =
        f.maxAge
            .clamp(DiscoveryFilters.ageFloor, DiscoveryFilters.ageCeiling)
            .toDouble();
    ageRange = RangeValues(min, max < min ? min : max);
    distance = f.maxDistance.clamp(1, 100).toDouble();
    ageToggle = f.expandAge;
    distanceToggle = f.expandDistance;
    verifiedOnly = f.verifiedOnly;
    selectedGender = _genderLabels[f.interestedIn] ?? '';
    interests = [...f.interests];
    languages = [...f.languages];
  }

  DiscoveryFilters get _draft => _swipeController.filters.value.copyWith(
    interestedIn:
        _genderLabels.entries
            .firstWhere(
              (e) => e.value == selectedGender,
              orElse: () => const MapEntry('', ''),
            )
            .key,
    minAge: ageRange.start.round(),
    maxAge: ageRange.end.round(),
    expandAge: ageToggle,
    maxDistance: distance.round(),
    expandDistance: distanceToggle,
    verifiedOnly: verifiedOnly,
    interests: interests,
    languages: languages,
  );

  void _resetDraft() {
    setState(
      () => _applyDraft(
        const DiscoveryFilters().copyWith(interestedIn: _draft.interestedIn),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters reset. Tap Save to apply.')),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final error = await _swipeController.saveFilters(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filters saved'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : null,
          border: selected ? null : Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
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
                    const Spacer(),
                    TextButton(
                      onPressed: _loading || _saving ? null : _resetDraft,
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: AppTheme.primaryColor),
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
                      _tab(
                        "Basic filters",
                        !_showAdvanced,
                        () => setState(() => _showAdvanced = false),
                      ),
                      const SizedBox(width: 10),
                      _tab(
                        "Advanced filters",
                        _showAdvanced,
                        () => setState(() => _showAdvanced = true),
                      ),
                    ],
                  ),
                ),

                if (_loadError != null) ...[
                  const SizedBox(height: 12),
                  Text(_loadError!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 25),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!_showAdvanced) ...[
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
                          Text(selectedGender.isEmpty ? 'Select' : selectedGender),
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
                          min: DiscoveryFilters.ageFloor.toDouble(),
                          max: DiscoveryFilters.ageCeiling.toDouble(),
                          divisions:
                              DiscoveryFilters.ageCeiling -
                              DiscoveryFilters.ageFloor,
                          activeColor: AppTheme.primaryColor,
                          inactiveColor: AppTheme.primaryColor.withOpacity(
                            0.15,
                          ),
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
                              activeColor: AppTheme.primaryColor,
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
                          activeColor: AppTheme.primaryColor,
                          inactiveColor: AppTheme.primaryColor.withOpacity(
                            0.15,
                          ),
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
                              activeColor: AppTheme.primaryColor,
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
                ] else ...[
                  /// INTERESTS
                  const Text(
                    "Do they share any of your interests?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    interests.isEmpty
                        ? "No interest filter — everyone is shown"
                        : "Only show people who share at least one",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        interests
                            .map(
                              (e) => Chip(
                                label: Text(
                                  e,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    interests.remove(e);
                                  });
                                },
                                backgroundColor: AppTheme.primaryColor
                                    .withOpacity(0.08),
                                deleteIconColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
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
                          Icon(Icons.verified, color: AppTheme.primaryColor),
                          SizedBox(width: 8),
                          Text(
                            "Verified only",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      Switch(
                        value: verifiedOnly,
                        activeColor: AppTheme.primaryColor,
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
                    onTap: () async {
                      final picked = await Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  LanguageScreen(initialSelection: languages),
                        ),
                      );
                      if (picked != null && mounted) {
                        setState(() => languages = picked);
                      }
                    },
                    child: _card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              languages.isEmpty
                                  ? "Select languages"
                                  : languages.join(", "),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                GradientButton(
                  label: "Save",
                  isLoading: _saving,
                  onPressed: _loading ? null : _save,
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
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color:
              selected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(gender),

            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppTheme.primaryColor : Colors.grey,
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
            cursorColor: AppTheme.primaryColor,
            decoration: InputDecoration(
              hintText: "Enter interest",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.2,
                ),
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
                backgroundColor: AppTheme.primaryColor,
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
