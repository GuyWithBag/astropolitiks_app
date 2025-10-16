import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CoordinateDisplayPage extends HookWidget {
  const CoordinateDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localPosition = useState<Offset?>(null);
    final isInteracting = useState(false);

    void setPosition(Offset? offset) {
      localPosition.value = offset;
      isInteracting.value = offset != null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) => setPosition(details.localPosition),
          onPanUpdate: (details) => setPosition(details.localPosition),
          onPanEnd: (_) => setPosition(null),
          onTapDown: (details) => setPosition(details.localPosition),
          onTapUp: (_) => setPosition(null),
          child: MouseRegion(
            onHover: (event) => setPosition(event.localPosition),
            onExit: (_) => setPosition(null),
            onEnter: (event) => setPosition(event.localPosition),
            child: Container(
              color: Colors.grey.withOpacity(0.08),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  if (localPosition.value != null)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'x: ${localPosition.value!.dx.toStringAsFixed(1)}, y: ${localPosition.value!.dy.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
