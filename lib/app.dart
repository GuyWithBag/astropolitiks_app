import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'widgets/rectangle_widget.dart';
import 'widgets/coordinate_display.dart';
import 'widgets/clock_widget.dart';
import 'widgets/sensor_display.dart';
import 'widgets/fps_control.dart';

class AllInOneDemoPage extends HookWidget {
  const AllInOneDemoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Clock & FPS controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: ClockWidgetPage()),
                const SizedBox(width: 12),
                Expanded(child: FPSControlPage()),
              ],
            ),
            const SizedBox(height: 18),
            // Rectangle widget in center
            Center(child: RectangleWidget()),
            const SizedBox(height: 18),
            // Sensor bar
            SensorDisplayPage(),
          ],
        ),
      ),
    );
  }
}

class App extends HookWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final pageIndex = useState(0);
    final pages = const [
      AllInOneDemoPage(),
      RectangleWidget(),
      CoordinateDisplayPage(),
      ClockWidgetPage(),
      SensorDisplayPage(),
      FPSControlPage(),
    ];
    final pageTitles = [
      'All-in-One',
      'Rectangle',
      'Coordinates',
      'Clock',
      'Sensors',
      'FPS',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[pageIndex.value]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: pages[pageIndex.value],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex.value,
        onTap: (idx) => pageIndex.value = idx,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'All'),
          BottomNavigationBarItem(icon: Icon(Icons.crop_landscape), label: 'Rectangle'),
          BottomNavigationBarItem(icon: Icon(Icons.near_me), label: 'Coordinates'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Clock'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensors'),
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: 'FPS'),
        ],
      ),
    );
  }
}
