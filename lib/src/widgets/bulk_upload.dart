import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:shopos/src/config/colors.dart';
import 'custom_button.dart';

class BulkUpload extends StatefulWidget {
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  BulkUpload({
    required this.onSubmit,
    required this.onClose,
  });

  @override
  _BulkUploadState createState() => _BulkUploadState();
}

class _BulkUploadState extends State<BulkUpload> {
  String? _filePath;

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            CustomButton(
              title: _filePath != null ? _filePath! : 'Upload Excel File Here',
              onTap: _selectFile,
              type: ButtonType.outlined,
            ),
            SizedBox(
              height: 30,
            ),
            CustomButton(
              title: 'Submit',
              onTap: widget.onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
