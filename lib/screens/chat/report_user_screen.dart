import 'package:flutter/material.dart';

class ReportUserScreen extends StatefulWidget {
  final String userName;

  const ReportUserScreen({super.key, required this.userName});

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedReasonIndex = 0;
  final List<String> _reasons = [
    'Spam',
    'Inappropriate Content',
    'Fake Profile',
    'Harassment',
  ];

  void _submitReport() async {
    final selectedReason = _reasons[_selectedReasonIndex];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted for "$selectedReason"'),
        backgroundColor: Colors.pink.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        duration: const Duration(seconds: 3),
      ),
    );

    final shouldBlock = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Report submitted'),
          content: const Text('Would you like to block this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    Navigator.of(context).pop(shouldBlock == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text('Report ${widget.userName}',
            style: const TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a reason',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: List.generate(_reasons.length, (index) {
                  return RadioListTile<int>(
                    value: index,
                    groupValue: _selectedReasonIndex,
                    title: Text(_reasons[index]),
                    onChanged: (value) {
                      setState(() {
                        _selectedReasonIndex = value ?? 0;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Additional comments (optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _submitReport,
                child: const Text('Submit Report', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
