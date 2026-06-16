import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LogoPickerWidget extends StatelessWidget {
  final String? initialPath;
  final Function(String) onChanged;

  const LogoPickerWidget({
    super.key,
    this.initialPath,
    required this.onChanged,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      onChanged(savedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: initialPath != null ? FileImage(File(initialPath!)) : null,
        child: initialPath == null
            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
            : null,
      ),
    );
  }
}
