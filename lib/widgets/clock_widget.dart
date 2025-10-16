import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ClockWidgetPage extends HookWidget {
  const ClockWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Store startTime when widget is first built
    final startTime = useMemoized(() => DateTime.now());
    final now = useState(DateTime.now());
    // Refresh every 1/60th second
    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        now.value = DateTime.now();
      });
      return timer.cancel;
    }, []);

    Duration elapsed = now.value.difference(startTime);
    String formatTime(DateTime dt) => "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
    String formatElapsed(Duration d) => d.inMinutes.toString().padLeft(2, '0') + ":" + (d.inSeconds % 60).toString().padLeft(2, '0');

    return Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                formatTime(now.value),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Text(
                'Elapsed Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                formatElapsed(elapsed),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
