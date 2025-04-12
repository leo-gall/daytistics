import 'package:daytistics/application/providers/services/diary/diary_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DaytisticDetailsDiaryView extends ConsumerStatefulWidget {
  const DaytisticDetailsDiaryView({super.key});

  @override
  ConsumerState<DaytisticDetailsDiaryView> createState() =>
      _DaytisticDetailsDiaryViewState();
}

class _DaytisticDetailsDiaryViewState
    extends ConsumerState<DaytisticDetailsDiaryView> {
  final shortEntryController = TextEditingController();
  final happinessMomentController = TextEditingController();

  @override
  void dispose() {
    shortEntryController.dispose();
    happinessMomentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.read(diaryServiceProvider);
    final currentDaytistic = ref.read(currentDaytisticProvider);

    shortEntryController.text = currentDaytistic?.diaryEntry?.shortEntry ?? '';
    happinessMomentController.text =
        currentDaytistic?.diaryEntry?.happinessMoment ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: getInputDecoration('Diary Entry'),
            maxLines: 5,
            controller: shortEntryController,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: getInputDecoration('Moment of Happiness'),
            controller: happinessMomentController,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: handleSave,
            child: const StyledText('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> handleSave() async {
    final currentDaytistic = ref.read(currentDaytisticProvider);
    final diaryService = ref.read(diaryServiceProvider);

    if (currentDaytistic == null) return;

    final diaryEntry = currentDaytistic.diaryEntry?.copyWith(
      daytisticId: currentDaytistic.id,
      shortEntry: shortEntryController.text,
      happinessMoment: happinessMomentController.text,
    );

    if (diaryEntry != null) {
      ref.read(currentDaytisticProvider.notifier).diaryEntry = diaryEntry;
      showToast(message: 'Diary entry updated successfully');
      await diaryService.upsertDiaryEntry(diaryEntry).then((success) {
        if (!success) {
          showToast(
            message: 'Failed to update diary entry',
            type: ToastType.error,
          );
        }
      });
    }
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
