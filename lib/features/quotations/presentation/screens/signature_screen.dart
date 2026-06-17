import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';

class SignatureScreen extends StatefulWidget {
  final String quotationId;

  const SignatureScreen({super.key, required this.quotationId});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Signature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (_controller.isNotEmpty) {
                final image = await _controller.toPngBytes();
                final docDir = await getApplicationDocumentsDirectory();
                final file = File('${docDir.path}/sig_${widget.quotationId}.png');
                await file.writeAsBytes(image!);
                if (mounted) Navigator.pop(context, file.path);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _controller.clear(),
                  child: const Text('CLEAR'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_controller.isNotEmpty) {
                      final image = await _controller.toPngBytes();
                      final docDir = await getApplicationDocumentsDirectory();
                      final file = File('${docDir.path}/sig_${widget.quotationId}.png');
                      await file.writeAsBytes(image!);
                      if (mounted) Navigator.pop(context, file.path);
                    }
                  },
                  child: const Text('CONFIRM'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
