import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/theme.dart';

class DropZone extends StatefulWidget {
  final Widget child;
  final Function(PlatformFile) onDroppedFile;

  const DropZone({
    super.key,
    required this.child,
    required this.onDroppedFile,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isDragging = true);
        return true;
      },
      onAcceptWithDetails: (details) async {
        setState(() => _isDragging = false);
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
        if (result != null) {
          widget.onDroppedFile(result.files.first);
        }
      },
      onLeave: (data) {
        setState(() => _isDragging = false);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: _isDragging
                ? AppTheme.primaryColor.withOpacity(0.2)
                : Colors.transparent,
            border: _isDragging
                ? Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    width: 2,
                  )
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}
