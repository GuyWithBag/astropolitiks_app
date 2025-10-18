import 'dart:io' show Platform;
import 'package:astropolitiks_app/widgets/skybox/skybox.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RectangleWidget extends HookWidget {
  const RectangleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    final localPosition = useState<Offset?>(null);
    final isInteracting = useState(false);
    final rectangleKey = useMemoized(() => GlobalKey(), []);

    void onInteractionUpdate(Offset position) {
      // position is local to widget
      counter.value++;
      localPosition.value = position;
    }

    void onInteractionStart(Offset position) {
      isInteracting.value = true;
      onInteractionUpdate(position);
    }

    void onInteractionEnd() {
      isInteracting.value = false;
      localPosition.value = null;
    }

    Widget buildBody(BoxConstraints constraints) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 600, minHeight: 400),
          child: MouseRegion(
            onHover: (event) {
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                return; // Ignore hovers on mobile
              onInteractionUpdate(event.localPosition);
            },
            onEnter: (event) {
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) return;
              isInteracting.value = true;
            },
            onExit: (event) {
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) return;
              onInteractionEnd();
            },
            child: GestureDetector(
              key: rectangleKey,
              onPanStart: (details) {
                onInteractionStart(details.localPosition);
              },
              onPanUpdate: (details) {
                onInteractionUpdate(details.localPosition);
              },
              onPanEnd: (details) {
                onInteractionEnd();
              },
              onTapDown: (details) {
                // Single tap on rectangle
                onInteractionStart(details.localPosition);
              },
              onTapUp: (details) {
                onInteractionEnd();
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 4),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.blueGrey.withOpacity(0.1),
                    ),
                    width: 600,
                    height: 400,
                    child: Skybox(),
                  ),
                  // Counter display top left
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isInteracting.value ? 1 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Counter: ${counter.value}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Real-time coordinates bottom right
                  if (localPosition.value != null)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'x: ${localPosition.value!.dx.toStringAsFixed(1)},\ny: ${localPosition.value!.dy.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (_, constraints) => buildBody(constraints));
  }
}
