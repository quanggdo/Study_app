import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class QuizLoadingShimmer extends StatelessWidget {
  const QuizLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    Widget box({double? height, double? width, BorderRadius? radius}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: radius ?? BorderRadius.circular(16),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                box(height: 18, width: 120, radius: BorderRadius.circular(999)),
                const Spacer(),
                box(height: 18, width: 80, radius: BorderRadius.circular(999)),
              ],
            ),
            const SizedBox(height: 12),
            box(height: 56),
            const SizedBox(height: 12),
            box(height: 120),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => box(height: 56),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: box(height: 44)),
                const SizedBox(width: 12),
                Expanded(child: box(height: 44)),
              ],
            ),
            const SizedBox(height: 8),
            box(height: 44),
          ],
        ),
      ),
    );
  }
}

