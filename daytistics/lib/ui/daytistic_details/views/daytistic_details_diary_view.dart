import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DaytisticDetailsDiaryView extends ConsumerWidget {
  const DaytisticDetailsDiaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: getInputDecoration('Diary Entry'),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: getInputDecoration('Moment of Happiness'),
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Add save logic here
            },
            child: const StyledText('Save'),
          ),
        ],
      ),
    );
  }

  InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.grey[200],
      hintStyle: GoogleFonts.figtree(
        color: Colors.grey,
        fontSize: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
    );
  }
}
