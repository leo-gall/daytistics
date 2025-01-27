import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptInputField extends StatefulWidget {
  const PromptInputField({super.key});

  @override
  State<PromptInputField> createState() => _PromptInputFieldState();
}

class _PromptInputFieldState extends State<PromptInputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.only(
                    left: 10,
                    right: 60,
                    top: 10,
                    bottom: 10,
                  ),
                  hintText: 'What do you want to know about your well-being?',
                  hintStyle: GoogleFonts.nunito(
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
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: ColorSettings.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) {
                      return IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
