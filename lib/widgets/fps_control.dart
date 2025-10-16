import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum FpsMode { native, fps30, fps60, fps120 }

String fpsLabel(FpsMode mode) {
  switch (mode) {
    case FpsMode.native:
      return 'Native (Device)';
    case FpsMode.fps30:
      return '30 FPS';
    case FpsMode.fps60:
      return '60 FPS';
    case FpsMode.fps120:
      return '120 FPS';
  }
}

class FPSControlPage extends HookWidget {
  const FPSControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fpsMode = useState<FpsMode>(FpsMode.fps60);
    return Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select FPS (UI Update Rate)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                children: FpsMode.values.map((mode) {
                  return ChoiceChip(
                    label: Text(fpsLabel(mode)),
                    selected: fpsMode.value == mode,
                    onSelected: (_) {
                      fpsMode.value = mode;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text('Current: ' + fpsLabel(fpsMode.value),
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
