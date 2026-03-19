import 'package:flutter/material.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:get/get.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final swipeController = Get.find<SwipeController>();

  @override
  void initState() {
    super.initState();
    swipeController.getMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        elevation: 0,
      ),
      body: Obx(
        () => swipeController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : swipeController.matches.isEmpty
                ? Center(
                    child: Text(
                      swipeController.errorMessage.value.isEmpty
                          ? 'No matches yet'
                          : swipeController.errorMessage.value,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: swipeController.matches.length,
                    itemBuilder: (context, index) {
                      final match = swipeController.matches[index];
                      return ListTile(
                        title: Text(match.userId),
                        subtitle: Text(match.status.name),
                        trailing: match.isPending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      swipeController.rejectMatch(match.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () {
                                      swipeController.acceptMatch(match.id);
                                    },
                                  ),
                                ],
                              )
                            : const Icon(Icons.check, color: Colors.green),
                      );
                    },
                  ),
      ),
    );
  }
}
