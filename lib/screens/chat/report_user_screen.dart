import 'package:flutter/material.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/utils/theme.dart';

class ReportUserScreen extends StatefulWidget {
  final String userName;
  final String? reportedUserId;

  const ReportUserScreen({
    super.key,
    required this.userName,
    this.reportedUserId,
  });

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

  bool _submitting = false;

  void _submitReport() async {
    if (_submitting) return;
    final selectedReason = _reasons[_selectedReasonIndex];
    setState(() => _submitting = true);
    final response = await ChatService().reportMessage(
      '',
      selectedReason,
      reportedUserId: widget.reportedUserId,
      details: _commentController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message.isNotEmpty
              ? response.message
              : 'Could not submit report. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted for "$selectedReason"'),
        backgroundColor: AppTheme.primaryDarkColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        duration: const Duration(seconds: 3),
      ),
    );

    final shouldBlock = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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

    if (!mounted) return;
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
        title: Text(
          'Report ${widget.userName}',
          style: const TextStyle(color: Colors.black),
        ),
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
              textAlignVertical: TextAlignVertical.top,
              cursorColor: AppTheme.primaryColor,
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.inputFocusBorderColor,
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _submitting ? null : _submitReport,
                child: const Text(
                  'Submit Report',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
