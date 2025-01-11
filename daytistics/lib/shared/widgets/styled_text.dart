import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _StyledTextBase extends StatelessWidget {
  const _StyledTextBase(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(textStyle: style),
    );
  }
}

class StyledTitle extends StatelessWidget {
  const StyledTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return _StyledTextBase(
      text,
      key: key,
      style: style ?? Theme.of(context).textTheme.titleMedium!,
    );
  }
}

class StyledHeading extends StatelessWidget {
  const StyledHeading(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return _StyledTextBase(
      text,
      key: key,
      style: style ?? Theme.of(context).textTheme.headlineMedium!,
    );
  }
}

class StyledText extends StatelessWidget {
  const StyledText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return _StyledTextBase(
      text,
      key: key,
      style: style ?? Theme.of(context).textTheme.bodyMedium!,
    );
  }
}
