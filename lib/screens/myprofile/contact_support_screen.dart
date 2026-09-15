import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({
    super.key,
    this.title = 'Contact support',
    this.initialIssueType,
  });

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
  final List<({String name, int size})> _attachedFiles = [];
  bool _picking = false;

  static const int _maxAttachmentBytes = 10 * 1024 * 1024;
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
  }) {
    return DropdownButtonFormField<String>(
      value: value,
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
      setState(() {
      });
      for (final file in picked) {
        final ext = file.name.split('.').last.toLowerCase();
        final size = await file.xFile.length();
        if (!_allowedExtensions.contains(ext) || size > _maxAttachmentBytes) {
          rejected.add(file.name);
        } else if (!_attachedFiles.any((f) => f.name == file.name && f.size == size)) {
          _attachedFiles.add((name: file.name, size: size));
        }
      }
      if (!mounted) return;
      setState(() {});
      if (rejected.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not attached (PNG, JPG or PDF up to 10 MB only): ${rejected.join(', ')}'),
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

  String _fileLabel(({String name, int size}) f) {
    final kb = f.size / 1024;
    final size = kb >= 1024 ? '${(kb / 1024).toStringAsFixed(1)} MB' : '${kb.toStringAsFixed(0)} KB';
    return '${f.name} · $size';
  }

  void _handleSubmit() {
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the consent to continue.')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      // The backend has no support-ticket endpoint, so nothing can be sent or
      // stored yet. Say that plainly instead of faking a submission.
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Couldn't send request"),
          content: const Text(
            'In-app support requests are not available yet. Your details are '
            'still here — please try again later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
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
                const SizedBox(height: 20),

                // ── Section 1: User Info ─────────────────────────────────────
                _sectionLabel('User Info'),
                _card([
                  _fieldLabel('Name'),
                  TextFormField(
                    controller: _nameController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: _inputDecoration('Your full name'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  _fieldGap(),
                  _fieldLabel('Email'),
                  TextFormField(
                    controller: _emailController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: _inputDecoration('you@example.com'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  _fieldGap(),
                  _fieldLabel('User ID'),
                  TextFormField(
                    controller: _userIdController,
                    textAlignVertical: TextAlignVertical.center,
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
                  ),
                  _fieldGap(),
                  _fieldLabel('Subject'),
                  TextFormField(
                    controller: _subjectController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: _inputDecoration('Brief summary of your issue'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
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
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF5A3A5A),
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Color(0xFF7B4A9B)),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: Color(0xFF7B4A9B)),
                                ),
                                TextSpan(
                                  text:
                                      '. I consent to my data being processed to resolve this request.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Gradient Submit Button ───────────────────────────────
                  GestureDetector(
                    onTap: _consentGiven ? _handleSubmit : null,
                    child: Opacity(
                      opacity: _consentGiven ? 1.0 : 0.45,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF3D77), Color(0xFFD81159)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
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
