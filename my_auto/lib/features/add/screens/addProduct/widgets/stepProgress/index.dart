import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor =
        Theme.of(context).colorScheme.primary.withOpacity(0.3);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: currentStep == 3
          ? BoxDecoration(color: Theme.of(context).colorScheme.surface)
          : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                return Container(
                  width: MediaQuery.of(context).size.width / (totalSteps * 1.7),
                  height: 2,
                  color:
                      (index ~/ 2) + 1 < currentStep ? primary : inactiveColor,
                );
              }

              final step = (index ~/ 2) + 1;
              final isActive = step == currentStep;
              final isCompleted = step < currentStep;

              return Container(
                width: 45,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted ? primary : inactiveColor,
                ),
                child: Center(
                  child: Text(
                    step.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(totalSteps, (index) {
              final step = index + 1;
              final isActive = step == currentStep;
              return SizedBox(
                width: 100,
                child: Text(
                  stepLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? primary : Colors.grey,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
