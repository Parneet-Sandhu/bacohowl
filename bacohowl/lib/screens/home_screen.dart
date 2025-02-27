import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io' show File;
import '../constants/theme.dart';
import '../constants/assets.dart';
import '../widgets/player_controls.dart';
import '../widgets/drop_zone.dart';
import 'dart:math';
import 'dart:typed_data';
import '../widgets/background_picker.dart';
import '../widgets/settings_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? currentSong;
  late AnimationController _scaleController;
  List<PlatformFile> playlist = [];
  int currentIndex = 0;
  Map<String, Uint8List> audioBytes = {};
  bool showPlaylist = false;
  String currentBackground = AppAssets.defaultBackground;
  bool showSettings = false;
  bool autoPlay = true;  // Add this property

  @override
  void initState() {
    super.initState();
    setupAudioPlayer();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Add error handling
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted && autoPlay) {  // Check autoPlay setting
        handleForward(); // Play next song when current one completes
      }
    });
  }

  Future<void> pickAndPlayAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<PlatformFile> newSongs;
        if (kIsWeb) {
          newSongs = result.files.where((file) => file.bytes != null).toList();
        } else {
          newSongs = result.files.where((file) => file.path != null).toList();
        }

        if (newSongs.isEmpty) {
          throw Exception('No valid audio files selected');
        }

        setState(() {
          // If playlist is empty, start playing the first new song
          bool wasEmpty = playlist.isEmpty;
          
          // Add new songs to the existing playlist
          playlist.addAll(newSongs);

          // If this was the first song added, start playing it
          if (wasEmpty) {
            currentIndex = 0;
            playAudio(playlist[currentIndex]);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting audio files: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> playAudio(PlatformFile file) async {
    try {
      await _audioPlayer.stop();
      
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('No audio data available for ${file.name}');
        }
        
        // Store bytes in memory
        audioBytes[file.name] = file.bytes!;
        
        // Create an object URL from bytes for web playback
        final url = Uri.dataFromBytes(
          file.bytes!,
          mimeType: 'audio/mp3',
        ).toString();

        await _audioPlayer.play(UrlSource(url));
      } else {
        if (file.path == null) {
          throw Exception('No file path available for ${file.name}');
        }
        await _audioPlayer.play(DeviceFileSource(file.path!));
      }

      setState(() {
        isPlaying = true;
        currentSong = file.name;
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing ${file.name}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() => duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() => position = newPosition);
    });
  }

  void handleForward() {
    if (playlist.isEmpty) return;
    final nextIndex = (currentIndex + 1) % playlist.length;
    setState(() => currentIndex = nextIndex);
    playAudio(playlist[currentIndex]);
  }

  void handleBackward() {
    if (playlist.isEmpty) return;
    final prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    setState(() => currentIndex = prevIndex);
    playAudio(playlist[currentIndex]);
  }

  Widget _buildPlaylistView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playlist',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: pickAndPlayAudio,
                  color: AppTheme.accentColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];
                return ListTile(
                  leading: Icon(
                    Icons.music_note,
                    color: currentIndex == index ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.5),
                  ),
                  title: Text(
                    song.name,
                    style: AppTheme.bodyStyle.copyWith(
                      color: currentIndex == index ? AppTheme.primaryColor : AppTheme.textColor,
                      fontWeight: currentIndex == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeFromPlaylist(index),
                    color: AppTheme.textColor.withOpacity(0.5),
                  ),
                  onTap: () => _playFromPlaylist(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromPlaylist(int index) {
    setState(() {
      if (index == currentIndex) {
        _audioPlayer.stop();
        isPlaying = false;
        currentSong = null;
      } else if (index < currentIndex) {
        currentIndex--;
      }
      playlist.removeAt(index);
    });
  }

  void _playFromPlaylist(int index) {
    setState(() => currentIndex = index);
    playAudio(playlist[index]);
  }

  void _handleBackgroundChange(String newBackground) {
    setState(() {
      currentBackground = newBackground;
      showSettings = false;
    });
  }

  void _handleCustomBackground(String path) {
    setState(() {
      currentBackground = path;
      showSettings = false;
    });
  }

  void _handleAutoPlayChanged(bool value) {
    setState(() => autoPlay = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: currentBackground.startsWith('assets/') 
              ? AssetImage(currentBackground) as ImageProvider
              : kIsWeb 
                ? NetworkImage(currentBackground) as ImageProvider
                : FileImage(File(currentBackground)),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.3),
              AppTheme.secondaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              DropZone(
                onDroppedFile: (file) async => await playAudio(file),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            currentSong ?? 'Select songs to play',
                            style: AppTheme.titleStyle.copyWith(fontSize: 24),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (showPlaylist) _buildPlaylistView(),
                        const SizedBox(height: 10),
                        PlayerControls(
                          audioPlayer: _audioPlayer,
                          isPlaying: isPlaying,
                          duration: duration,
                          position: position,
                          onPlayPause: handlePlayPause,
                          onForward: handleForward,
                          onBackward: handleBackward,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () => setState(() => showPlaylist = !showPlaylist),
                              icon: Icon(
                                showPlaylist ? Icons.playlist_remove : Icons.queue_music,
                                color: AppTheme.accentColor,
                              ),
                              label: Text(
                                showPlaylist ? 'Hide' : 'Show',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: pickAndPlayAudio,
                              icon: const Icon(Icons.add),
                              label: const Text('Add'),
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: AppTheme.accentColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => setState(() => showSettings = !showSettings),
                              icon: Icon(
                                Icons.settings,
                                color: AppTheme.secondaryColor,
                              ),
                              label: Text(
                                'Settings',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showSettings)
                Positioned(
                  top: 100,
                  right: 20,
                  child: SettingsMenu(
                    currentBackground: currentBackground,
                    onBackgroundChanged: _handleBackgroundChange,
                    onCustomBackgroundPicked: _handleCustomBackground,
                    autoPlay: autoPlay,
                    onAutoPlayChanged: _handleAutoPlayChanged,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void handlePlayPause() {
    if (currentSong == null) {
      pickAndPlayAudio();
    } else {
      setState(() {
        if (isPlaying) {
          _audioPlayer.pause();
        } else {
          _audioPlayer.resume();
        }
        isPlaying = !isPlaying;
      });
    }
  }

  @override
  void dispose() {
    audioBytes.clear();
    _audioPlayer.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}

class BubblePainter extends CustomPainter {
  final Color color;
  BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random();
    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
