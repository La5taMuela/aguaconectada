import 'package:flutter/material.dart';

class TutorialModal extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool isLastStep;
  final Widget? highlightWidget;
  final Alignment alignment;
  final EdgeInsets padding;

  const TutorialModal({
    Key? key,
    required this.title,
    required this.description,
    required this.onNext,
    this.onSkip,
    this.isLastStep = false,
    this.highlightWidget,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Semi-transparent background
          Positioned.fill(
            child: Container(
              color: Colors.black12,
            ),
          ),

          // Highlighted widget if provided
          if (highlightWidget != null)
            Positioned.fill(
              child: highlightWidget!,
            ),

          // Tutorial modal
          Align(
            alignment: alignment,
            child: Container(
              margin: padding,
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (onSkip != null)
                          TextButton(
                            onPressed: onSkip,
                            child: const Text(
                              'Saltar tutorial',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isLastStep ? 'Finalizar' : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
