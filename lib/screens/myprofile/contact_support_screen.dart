import 'package:dating_app/widgets/common/legal_links_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/services/support_service.dart';
import 'package:dating_app/utils/constants.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({
    super.key,
    this.title = 'Contact support',
    this.initialIssueType,
    this.kind = 'contact',
  });

  /// Opens the form as "Report a problem" (technical issue preselected).
  const ContactSupportScreen.reportProblem({super.key})
      : title = 'Report a problem',
        initialIssueType = 'Technical Problem',
        kind = 'problem';

  /// Sent to the backend so support can tell the two forms apart:
  /// 'contact' or 'problem'.
  final String kind;

  /// Header text — "Report a problem" reuses this form.
  final String title;

  /// Pre-selects an entry of the Issue Type dropdown.
  final String? initialIssueType;

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String? _selectedIssueType = _issueTypes.contains(widget.initialIssueType)
      ? widget.initialIssueType
      : null;
  bool _consentGiven = false;
  final List<SupportAttachment> _attachedFiles = [];
  bool _picking = false;
  bool _submitting = false;
  final SupportService _supportService = SupportService();

  @override
  void initState() {
    super.initState();
    _prefillUserInfo();
  }

  void _prefillUserInfo() {
    _appVersionController.text = AppConstants.appVersion;
    _platform = switch (defaultTargetPlatform) {
      _ when kIsWeb => 'Web (browser)',
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      _ => 'Desktop app',
    };
    if (!Get.isRegistered<UserController>()) return;
    final user = Get.find<UserController>().currentUser.value;
    if (user == null) return;
    if (_nameController.text.isEmpty && user.fullName.trim().isNotEmpty) {
      _nameController.text = user.fullName.trim();
    }
    if (_emailController.text.isEmpty && user.email.trim().isNotEmpty) {
      _emailController.text = user.email.trim();
    }
    if (user.email.trim().isNotEmpty) {
      _accountEmailController.text = user.email.trim();
    }
    if (_userIdController.text.isEmpty && user.publicUserId.isNotEmpty) {
      _userIdController.text = user.publicUserId;
    }
  }

  static const int _maxAttachmentBytes = 10 * 1024 * 1024;
  static const int _maxTotalAttachmentBytes = 20 * 1024 * 1024;
  static const int _maxAttachments = 5;
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static const List<String> _allowedExtensions = ['png', 'jpg', 'jpeg', 'pdf'];

  final _accountEmailController = TextEditingController();
  final _txnIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _appVersionController = TextEditingController();
  final _stepsController = TextEditingController();
  final _contentUrlController = TextEditingController();
  final _additionalContextController = TextEditingController();

  String? _accountIssue;
  String? _paymentMethod;
  String? _platform;
  String? _reportReason;
  
  static const List<String> _issueTypes = [
    'Account & Login',
    'Billing & Payments',
    'Technical Problem',
    'Content / Report',
    'Other',
  ];

  static const List<String> _accountIssues = [
    'Password reset not working',
    '2FA / verification issue',
    'Account locked',
    'Other login issue',
  ];

  static const List<String> _paymentMethods = [
    'Credit / Debit card',
    'UPI',
    'Net banking',
    'Wallet',
  ];

  static const List<String> _platforms = [
    'Android',
    'iOS',
    'Web (browser)',
    'Desktop app',
  ];

  static const List<String> _reportReasons = [
    'Spam or misleading',
    'Hateful / abusive',
    'Intellectual property',
    'Privacy concern',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _accountEmailController.dispose();
    _txnIdController.dispose();
    _amountController.dispose();
    _appVersionController.dispose();
    _stepsController.dispose();
    _contentUrlController.dispose();
    _additionalContextController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33C48AAE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33C48AAE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9B6AAA), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE63946), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF7A5A6E),
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.82),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF7A5A6E),
      ),
    ),
  );

  Widget _fieldGap() => const SizedBox(height: 14);

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      hint: Text(
        hint,
        style: const TextStyle(color: Colors.black38, fontSize: 14),
      ),
      decoration: _inputDecoration('').copyWith(hintText: null),
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9B6AAA)),
      style: const TextStyle(color: Color(0xFF2D1A2A), fontSize: 14),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      isExpanded: true,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAccountDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Details — Account'),
      _card([
        _fieldLabel('Account email on file'),
        TextFormField(
          controller: _accountEmailController,
          textAlignVertical: TextAlignVertical.center,
          decoration: _inputDecoration('Registered email'),
          keyboardType: TextInputType.emailAddress,
        ),
        _fieldGap(),
        _fieldLabel('Unable to access'),
        _buildDropdown(
          value: _accountIssue,
          items: _accountIssues,
          hint: 'Select issue',
          onChanged: (v) => setState(() => _accountIssue = v),
        ),
      ]),
    ],
  );

  Widget _buildBillingDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Details — Billing'),
      _card([
        _fieldLabel('Transaction / Invoice ID'),
        TextFormField(
          controller: _txnIdController,
          textAlignVertical: TextAlignVertical.center,
          decoration: _inputDecoration('TXN-XXXXXXXX'),
        ),
        _fieldGap(),
        _fieldLabel('Amount in dispute'),
        TextFormField(
          controller: _amountController,
          decoration: _inputDecoration('e.g. ₹499'),
          keyboardType: TextInputType.number,
        ),
        _fieldGap(),
        _fieldLabel('Payment method'),
        _buildDropdown(
          value: _paymentMethod,
          items: _paymentMethods,
          hint: 'Select method',
          onChanged: (v) => setState(() => _paymentMethod = v),
        ),
      ]),
    ],
  );

  Widget _buildTechnicalDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Details — Technical'),
      _card([
        _fieldLabel('Platform'),
        _buildDropdown(
          value: _platform,
          items: _platforms,
          hint: 'Select platform',
          onChanged: (v) => setState(() => _platform = v),
        ),
        _fieldGap(),
        _fieldLabel('App version'),
        TextFormField(
          controller: _appVersionController,
          textAlignVertical: TextAlignVertical.center,
          decoration: _inputDecoration('e.g. 3.4.1'),
        ),
        _fieldGap(),
        _fieldLabel('Steps to reproduce'),
        TextFormField(
          controller: _stepsController,
          textAlignVertical: TextAlignVertical.top,
          decoration: _inputDecoration('1. Open app\n2. Tap on ...\n3. ...'),
          maxLines: 4,
        ),
      ]),
    ],
  );

  Widget _buildContentDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Details — Content'),
      _card([
        _fieldLabel('Content URL or post ID'),
        TextFormField(
          controller: _contentUrlController,
          textAlignVertical: TextAlignVertical.center,
          decoration: _inputDecoration('Paste link or ID'),
        ),
        _fieldGap(),
        _fieldLabel('Reason for report'),
        _buildDropdown(
          value: _reportReason,
          items: _reportReasons,
          hint: 'Select reason',
          onChanged: (v) => setState(() => _reportReason = v),
        ),
      ]),
    ],
  );

  Widget _buildOtherDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Details — Other'),
      _card([
        _fieldLabel('Additional context'),
        TextFormField(
          controller: _additionalContextController,
          textAlignVertical: TextAlignVertical.top,
          decoration: _inputDecoration(
            'Any other details that might help us...',
          ),
          maxLines: 4,
        ),
      ]),
    ],
  );

  Widget _buildDynamicSection() {
    switch (_selectedIssueType) {
      case 'Account & Login':
        return _buildAccountDetails();
      case 'Billing & Payments':
        return _buildBillingDetails();
      case 'Technical Problem':
        return _buildTechnicalDetails();
      case 'Content / Report':
        return _buildContentDetails();
      case 'Other':
        return _buildOtherDetails();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Opens the native file picker. Nothing is attached until the user
  /// actually chooses a file.
  Future<void> _pickAttachments() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );
      if (!mounted || picked.isEmpty) return;

      final rejected = <String>[];
      var skippedForLimit = false;
      for (final file in picked) {
        final ext = file.name.split('.').last.toLowerCase();
        final size = await file.xFile.length();
        if (!_allowedExtensions.contains(ext) || size > _maxAttachmentBytes) {
          rejected.add(file.name);
          continue;
        }
        if (_attachedFiles.any((f) => f.name == file.name && f.size == size)) {
          continue;
        }
        final total = _attachedFiles.fold<int>(0, (sum, f) => sum + f.size);
        if (_attachedFiles.length >= _maxAttachments ||
            total + size > _maxTotalAttachmentBytes) {
          skippedForLimit = true;
          continue;
        }
        final bytes = await file.xFile.readAsBytes();
        _attachedFiles.add(SupportAttachment(name: file.name, bytes: bytes));
      }
      if (!mounted) return;
      setState(() {});
      if (rejected.isNotEmpty || skippedForLimit) {
        final messages = [
          if (rejected.isNotEmpty)
            'Not attached (PNG, JPG or PDF up to 10 MB only): ${rejected.join(', ')}',
          if (skippedForLimit)
            'You can attach up to $_maxAttachments files, 20 MB in total.',
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(messages.join('\n')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the file picker.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  String _fileLabel(SupportAttachment f) {
    final kb = f.size / 1024;
    final size = kb >= 1024 ? '${(kb / 1024).toStringAsFixed(1)} MB' : '${kb.toStringAsFixed(0)} KB';
    return '${f.name} · $size';
  }

  /// The issue-specific fields, labelled the way support should read them.
  Map<String, String> _detailsForIssue() {
    switch (_selectedIssueType) {
      case 'Account & Login':
        return {
          'Account email on file': _accountEmailController.text,
          'Unable to access': _accountIssue ?? '',
        };
      case 'Billing & Payments':
        return {
          'Transaction / Invoice ID': _txnIdController.text,
          'Amount in dispute': _amountController.text,
          'Payment method': _paymentMethod ?? '',
        };
      case 'Technical Problem':
        return {
          'Platform': _platform ?? '',
          'App version': _appVersionController.text,
          'Steps to reproduce': _stepsController.text,
        };
      case 'Content / Report':
        return {
          'Content URL or post ID': _contentUrlController.text,
          'Reason for report': _reportReason ?? '',
        };
      case 'Other':
        return {'Additional context': _additionalContextController.text};
      default:
        return const {};
    }
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the consent to continue.')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    setState(() => _submitting = true);
    final response = await _supportService.submitTicket(
      kind: widget.kind,
      name: _nameController.text.trim(),
      email: email,
      issueType: _selectedIssueType!,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      details: {
        ..._detailsForIssue(),
        if (_platform != null && _selectedIssueType != 'Technical Problem')
          'Device platform': _platform!,
        if (_selectedIssueType != 'Technical Problem')
          'App version': AppConstants.appVersion,
      },
      attachments: List.of(_attachedFiles),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!response.success) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Couldn't send request"),
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Something went wrong. Your details are still here — please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final ticket = response.data ?? '';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2E9E5B)),
            SizedBox(width: 8),
            Text('Request sent'),
          ],
        ),
        content: Text(
          '${ticket.isNotEmpty ? 'Your ticket number is $ticket.\n\n' : ''}'
          'Our support team will reply to $email. '
          'A confirmation email is on its way.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Header ──────────────────────────────────────────────────
                Row(
                  children: [
                    const BackButton(color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
                  child: Text(
                    widget.kind == 'problem'
                        ? 'Something not working? Tell us what happened and '
                            'attach a screenshot if you can.'
                        : "Send us your question and we'll reply by email.",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF7A5A6E)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Section 1: User Info ─────────────────────────────────────
                _sectionLabel('User Info'),
                _card([
                  _fieldLabel('Name'),
                  TextFormField(
                    controller: _nameController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: _inputDecoration('Your full name'),
                    maxLength: 100,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  _fieldGap(),
                  _fieldLabel('Email'),
                  TextFormField(
                    controller: _emailController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: _inputDecoration('you@example.com'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Required';
                      if (!_emailPattern.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  _fieldGap(),
                  _fieldLabel('User ID'),
                  TextFormField(
                    controller: _userIdController,
                    textAlignVertical: TextAlignVertical.center,
                    readOnly: true,
                    decoration: _inputDecoration('e.g. USR-00123'),
                  ),
                ]),

                // ── Section 2: Issue ─────────────────────────────────────────
                _sectionLabel('Issue'),
                _card([
                  _fieldLabel('Issue Type'),
                  _buildDropdown(
                    value: _selectedIssueType,
                    items: _issueTypes,
                    hint: 'Select an issue type',
                    onChanged: (v) => setState(() => _selectedIssueType = v),
                    validator: (v) =>
                        v == null ? 'Please select an issue type' : null,
                  ),
                  _fieldGap(),
                  _fieldLabel('Subject'),
                  TextFormField(
                    controller: _subjectController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: _inputDecoration('Brief summary of your issue'),
                    maxLength: 150,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  _fieldGap(),
                  _fieldLabel('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: _inputDecoration(
                      'Describe your issue in detail...',
                    ),
                    maxLines: 5,
                    maxLength: 5000,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ]),

                // ── Section 3: Dynamic Details ───────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildDynamicSection(),
                ),

                // ── Section 4: Uploads ───────────────────────────────────────
                _sectionLabel('Attachments'),
                _card([
                  GestureDetector(
                    onTap: _picking ? null : _pickAttachments,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9B6AAA).withOpacity(0.45),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B6AAA).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              color: Color(0xFF9B6AAA),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _picking ? 'Opening files…' : 'Tap to attach files',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A5A6E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'PNG, JPG, PDF up to 10 MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_attachedFiles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _attachedFiles
                          .map(
                            (f) => Chip(
                              label: Text(
                                _fileLabel(f),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B3F7A),
                                ),
                              ),
                              backgroundColor: const Color(
                                0xFF9B6AAA,
                              ).withOpacity(0.15),
                              deleteIconColor: const Color(0xFF9B6AAA),
                              side: BorderSide.none,
                              onDeleted: () =>
                                  setState(() => _attachedFiles.remove(f)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ]),

                // ── Section 5: Submit ────────────────────────────────────────
                _card([
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: _consentGiven,
                          onChanged: (v) =>
                              setState(() => _consentGiven = v ?? false),
                          activeColor: const Color(0xFF9B6AAA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: const BorderSide(color: Color(0xFF9B6AAA)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: const LegalLinksText(
                            before: 'I agree to the ',
                            after:
                                '. I consent to my data being processed to resolve this request.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF5A3A5A),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Gradient Submit Button ───────────────────────────────
                  GestureDetector(
                    onTap: _consentGiven && !_submitting ? _handleSubmit : null,
                    child: Opacity(
                      opacity: _consentGiven && !_submitting ? 1.0 : 0.45,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF3D77), Color(0xFFD81159)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit request',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
