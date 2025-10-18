import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final startTime = DateTime.now().millisecondsSinceEpoch;

const skyboxShaderPath = 'assets/shaders/day_and_night.frag';
// const shaderPath = 'assets/shaders/sun_sky_clouds.frag';

// const moonPath = 'assets/images/moon.png';
// late ui.Image moonImage;
const noiseImagePath = 'assets/images/noise.png';

class Skybox extends StatefulWidget {
  const Skybox({super.key});

  @override
  State<StatefulWidget> createState() => _SkyboxState();
}

class _SkyboxState extends State<Skybox> {
  ui.Image? _noiseImage;
  FragmentShader? _skyboxShader;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final noiseImage = await _loadUiImage(noiseImagePath);
    final skyboxShader = await FragmentProgram.fromAsset(skyboxShaderPath);

    setState(() {
      _noiseImage = noiseImage;
      _skyboxShader = skyboxShader.fragmentShader();
    });
  }

  /// Load a UI Image from an asset
  Future<ui.Image> _loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return await decodeImageFromList(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    if (_noiseImage == null || _skyboxShader == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return CustomPaint(
      painter: SkyboxPainter(
        skyboxShader: _skyboxShader!,
        noiseImage: _noiseImage!,
      ),
    );
  }
}

class SkyboxPainter extends CustomPainter {
  SkyboxPainter({required this.skyboxShader, required this.noiseImage});

  final FragmentShader skyboxShader;
  final ui.Image noiseImage;

  @override
  void paint(Canvas canvas, Size size) {
    // day_and_night.frag
    skyboxShader.setImageSampler(0, noiseImage); // iChannel0
    final double time =
        (DateTime.now().millisecondsSinceEpoch - startTime) / 1000;
    final List<double> shaderParameters = [
      noiseImage.width.toDouble(), // iChannelResolution0.x
      noiseImage.height.toDouble(), // iChannelResolution0.y
      size.width, // iResolution.x
      size.height, // iResolution.y
      0.5, // iMouse.x
      0.25, // iMouse.y
      0.75, // sunx
      -1.0, // suny
      0.5, // moonx
      -0.5, // moony
      2.5, // cloudy
      500.0, // height
      time, // time
    ];

    for (int i = 0; i < shaderParameters.length; i++) {
      skyboxShader.setFloat(i, shaderParameters[i]);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = skyboxShader,
    );
  }

  @override
  bool shouldRepaint(SkyboxPainter oldDelegate) {
    return false;
  }
}
