import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

void main() {
  runApp(const ScreenshotCoordApp());
}

class ScreenshotCoordApp extends StatelessWidget {
  const ScreenshotCoordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Coordinates',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ScreenshotPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({super.key});

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  File? _imageFile;
  ui.Image? _loadedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final data = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      setState(() {
        _imageFile = file;
        _loadedImage = frame.image;
      });
    }
  }

  void _onTap(BuildContext context, TapUpDetails details, BoxConstraints box) {
    if (_loadedImage == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final localOffset = renderBox.globalToLocal(details.globalPosition);

    final displayW = box.maxWidth;
    final displayH = box.maxHeight;
    final naturalW = _loadedImage!.width.toDouble();
    final naturalH = _loadedImage!.height.toDouble();

    final scaleX = naturalW / displayW;
    final scaleY = naturalH / displayH;

    final x = (localOffset.dx * scaleX).clamp(0, naturalW - 1).toInt();
    final y = (localOffset.dy * scaleY).clamp(0, naturalH - 1).toInt();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Coordinates: ($x, $y)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screenshot Coordinate Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: _imageFile == null
          ? const Center(child: Text("Pick a screenshot from gallery"))
          : LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapUp: (details) => _onTap(context, details, constraints),
                  child: Image.file(_imageFile!, fit: BoxFit.contain),
                );
              },
            ),
    );
  }
}
