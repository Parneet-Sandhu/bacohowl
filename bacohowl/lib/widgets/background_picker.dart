import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/theme.dart';
import '../constants/assets.dart';
import 'package:flutter/foundation.dart';

class BackgroundPicker extends StatefulWidget {
  final String currentBackground;
  final Function(String) onBackgroundChanged;
  final Function(String) onCustomBackgroundPicked;

  const BackgroundPicker({
    super.key,
    required this.currentBackground,
    required this.onBackgroundChanged,
    required this.onCustomBackgroundPicked,
  });

  @override
  State<BackgroundPicker> createState() => _BackgroundPickerState();
}

class _BackgroundPickerState extends State<BackgroundPicker> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Background',
            style: AppTheme.titleStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final contentWidth = availableWidth - 80; // Account for arrows
              
              return SizedBox(
                height: 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: _scrollLeft,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: contentWidth,
                        child: ListView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...AppAssets.backgrounds.entries.map((entry) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: _BackgroundOption(
                                    name: entry.key,
                                    imagePath: entry.value,
                                    isSelected: widget.currentBackground == entry.value,
                                    onTap: () => widget.onBackgroundChanged(entry.value),
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _AddCustomBackground(
                                onTap: _pickCustomBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: _scrollRight,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomBackground() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Enable bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (kIsWeb) {
          if (file.bytes != null) {
            // For web, create a data URL from bytes
            final url = Uri.dataFromBytes(
              file.bytes!,
              mimeType: 'image/${file.extension?.toLowerCase() ?? 'png'}',
            ).toString();
            widget.onCustomBackgroundPicked(url);
          }
        } else {
          // For desktop/mobile
          if (file.path != null) {
            widget.onCustomBackgroundPicked(file.path!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking background: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _BackgroundOption extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundOption({
    required this.name,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(4),
                child: Text(
                  name,
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCustomBackground extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCustomBackground({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              'Custom',
              style: AppTheme.bodyStyle.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
