import 'package:dating_app/screens/myprofile/legal_document_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// "<before>Terms of Service<between>Privacy Policy<after>" where both
/// document names open their legal screen on tap.
class LegalLinksText extends StatefulWidget {
  const LegalLinksText({
    super.key,
    this.before = '',
    this.between = ' and ',
    this.after = '',
    required this.style,
    this.textAlign = TextAlign.start,
    this.linkColor = const Color(0xFF7B4A9B),
  });

  final String before;
  final String between;
  final String after;
  final TextStyle style;
  final TextAlign textAlign;
  final Color linkColor;

  @override
  State<LegalLinksText> createState() => _LegalLinksTextState();
}

class _LegalLinksTextState extends State<LegalLinksText> {
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _open(LegalDocumentScreen.terms());
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _open(LegalDocumentScreen.privacy());

  void _open(Widget screen) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: widget.linkColor,
      decoration: TextDecoration.underline,
      decorationColor: widget.linkColor,
    );
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: widget.before),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: _termsTap,
          ),
          TextSpan(text: widget.between),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyTap,
          ),
          TextSpan(text: widget.after),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
