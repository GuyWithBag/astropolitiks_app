import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class App extends HookWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.home)),
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.person)),
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your longtitude and latitude',
              ),
            ),
            SizedBox(height: 20),
            Image.network(
              "https://api.capy.lol/v1/capybara",
              height: 300,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Error loading image: $error');
              },
            ),
          ],
        ),
      ),
    );
  }
}
