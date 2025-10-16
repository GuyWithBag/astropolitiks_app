import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class SensorDisplayPage extends HookWidget {
  const SensorDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Only on mobile platforms, show sensor data
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    // Rotation angles
    final rotation = useState(vm.Vector3.zero()); // pitch, roll, yaw
    final targetRotation = useState(
      vm.Vector3.zero(),
    ); // target for interpolation
    final lastUpdate = useState(DateTime.now());
    final enablePitch = useState(true);
    final enableRoll = useState(true);
    final enableYaw = useState(true);
    final enableSmoothing = useState(true);

    // Animation controller for smooth interpolation
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 16), // ~60fps
    );

    useEffect(() {
      if (!isMobile) return null;

      final gyroSub = gyroscopeEventStream().listen((gyroEvent) {
        final now = DateTime.now();
        final dt = now.difference(lastUpdate.value).inMilliseconds / 1000.0;
        lastUpdate.value = now;

        if (dt > 0 && dt < 0.5) {
          // Ignore huge time gaps
          // Get current angles
          final pitch = targetRotation.value.x;
          final roll = targetRotation.value.y;
          final yaw = targetRotation.value.z;

          // Integrate gyroscope (only if enabled)
          targetRotation.value = vm.Vector3(
            enablePitch.value ? pitch + gyroEvent.x * dt : pitch,
            enableRoll.value ? roll + gyroEvent.y * dt : roll,
            enableYaw.value ? yaw + gyroEvent.z * dt : yaw,
          );
        }
      }, cancelOnError: false);

      return () {
        gyroSub.cancel();
      };
    }, [isMobile]);

    // Smooth interpolation using animation ticker
    useEffect(() {
      void tick() {
        if (enableSmoothing.value) {
          // Lerp towards target with smoothing factor
          const smoothing = 0.15; // Lower = smoother but more lag
          rotation.value = vm.Vector3(
            rotation.value.x +
                (targetRotation.value.x - rotation.value.x) * smoothing,
            rotation.value.y +
                (targetRotation.value.y - rotation.value.y) * smoothing,
            rotation.value.z +
                (targetRotation.value.z - rotation.value.z) * smoothing,
          );
        } else {
          // No smoothing - use raw values directly
          rotation.value = targetRotation.value;
        }
      }

      animationController.repeat();
      animationController.addListener(tick);

      return () {
        animationController.removeListener(tick);
        animationController.stop();
      };
    }, []);

    Widget buildSensorData() {
      final pitch = rotation.value.x;
      final roll = rotation.value.y;
      final yaw = rotation.value.z;

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 3D Visualization using Transform widget
            SizedBox(
              width: 280,
              height: 280,
              child: Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(pitch)
                    ..rotateY(roll)
                    ..rotateZ(yaw),
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[900]!, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Camera notch indicator
                        Container(
                          width: 50,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const Spacer(),
                        // Screen content
                        Icon(
                          Icons.phone_android,
                          size: 50,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const Spacer(),
                        // Home indicator
                        Container(
                          width: 35,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sensor readings
            Text(
              'Pitch: ${(pitch * 180 / math.pi).toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Roll: ${(roll * 180 / math.pi).toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Yaw: ${(yaw * 180 / math.pi).toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Smoothing toggle
            SwitchListTile(
              title: const Text('Smooth Animation'),
              dense: true,
              value: enableSmoothing.value,
              onChanged: (value) => enableSmoothing.value = value,
            ),
            const SizedBox(height: 8),
            // Toggle buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Pitch'),
                  selected: enablePitch.value,
                  onSelected: (value) => enablePitch.value = value,
                  selectedColor: Colors.blue[200],
                ),
                FilterChip(
                  label: const Text('Roll'),
                  selected: enableRoll.value,
                  onSelected: (value) => enableRoll.value = value,
                  selectedColor: Colors.blue[200],
                ),
                FilterChip(
                  label: const Text('Yaw'),
                  selected: enableYaw.value,
                  onSelected: (value) => enableYaw.value = value,
                  selectedColor: Colors.blue[200],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Reset buttons
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    rotation.value = vm.Vector3(
                      0,
                      rotation.value.y,
                      rotation.value.z,
                    );
                    targetRotation.value = vm.Vector3(
                      0,
                      targetRotation.value.y,
                      targetRotation.value.z,
                    );
                  },
                  child: const Text('Reset Pitch'),
                ),
                OutlinedButton(
                  onPressed: () {
                    rotation.value = vm.Vector3(
                      rotation.value.x,
                      0,
                      rotation.value.z,
                    );
                    targetRotation.value = vm.Vector3(
                      targetRotation.value.x,
                      0,
                      targetRotation.value.z,
                    );
                  },
                  child: const Text('Reset Roll'),
                ),
                OutlinedButton(
                  onPressed: () {
                    rotation.value = vm.Vector3(
                      rotation.value.x,
                      rotation.value.y,
                      0,
                    );
                    targetRotation.value = vm.Vector3(
                      targetRotation.value.x,
                      targetRotation.value.y,
                      0,
                    );
                  },
                  child: const Text('Reset Yaw'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                rotation.value = vm.Vector3.zero();
                targetRotation.value = vm.Vector3.zero();
              },
              child: const Text('Reset All'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isMobile
              ? buildSensorData()
              : const Text('Orientation not available on this device.'),
        ),
      ),
    );
  }
}
