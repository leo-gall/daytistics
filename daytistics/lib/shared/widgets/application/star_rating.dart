import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int maxRating;
  final int? rating;
  final bool showFullRating;
  final Function(int)? onRatingChanged;

  const StarRating({
    super.key,
    required this.maxRating,
    required this.rating,
    this.onRatingChanged,
    this.showFullRating = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClickable = onRatingChanged != null;

    return Row(
      children: List<Widget>.generate(maxRating, (index) {
        final bool isFilled = index < (rating ?? 0);
        return IconButton(
          alignment: Alignment.center,
          onPressed: isClickable
              ? () {
                  onRatingChanged!(index + 1);
                }
              : null,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 2),
            ),
            minimumSize: WidgetStateProperty.all(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: ColorSettings.primary,
          ),
        );
      }),
    );
  }
}
