import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioControlWidget extends StatefulWidget {
  final int surahNumber;
  final Function(int) onSurahChange;

  const AudioControlWidget({
    Key? key, 
    required this.surahNumber,
    required this.onSurahChange,
  }) : super(key: key);

  @override
  State<AudioControlWidget> createState() => _AudioControlWidgetState();
}

class _AudioControlWidgetState extends State<AudioControlWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoadingAudio = false;
  String? currentAudioUrl;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isInitialized = false;  // Track if audio is initialized

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.durationStream.listen((d) {
      setState(() => duration = d ?? Duration.zero);
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() => position = p);
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          position = Duration.zero;
          isPlaying = false;
        }
      });
    });
  }

  String _formatSurahNumber(int number) {
    return number.toString().padLeft(3, '0');
  }

  Future<void> _togglePlayPause() async {
    if (!isInitialized) {
      await _playAudio(widget.surahNumber);
      return;
    }

    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      await _audioPlayer.play();
    } else {
      await _audioPlayer.pause();
    }
  }

  Future<void> _playAudio(int surahNumber) async {
    try {
      final formattedNumber = _formatSurahNumber(surahNumber);
      final url = 'https://santrikoding.com/storage/audio/$formattedNumber.mp3';

      // If same audio, just toggle play/pause
      if (currentAudioUrl == url && isInitialized) {
        await _togglePlayPause();
        return;
      }

      // Load new audio
      setState(() {
        isLoadingAudio = true;
        isPlaying = false;
      });

      await _audioPlayer.stop();

      try {
        await _audioPlayer.setUrl(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Loading audio timed out');
          },
        );

        setState(() {
          isLoadingAudio = false;
          currentAudioUrl = url;
          isInitialized = true;  // Mark as initialized after successful load
          isPlaying = true;      // Set to playing state
        });

        await _audioPlayer.play();

      } catch (e) {
        setState(() {
          isLoadingAudio = false;
          isInitialized = false;  // Reset initialization on error
        });
        throw e;
      }

    } catch (e) {
      setState(() {
        isLoadingAudio = false;
        isPlaying = false;
        isInitialized = false;
      });
      print("Error playing audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memutar audio')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 24),
            onPressed: () => _previousSurah(),
            color: const Color(0xFF819BA0),
          ),
          IconButton(
            icon: const Icon(Icons.replay_10, size: 24),
            onPressed: () => _seek(-10),
            color: const Color(0xFF819BA0),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF819BA0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: isLoadingAudio
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
              onPressed: isLoadingAudio ? null : _togglePlayPause,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.forward_10, size: 24),
            onPressed: () => _seek(10),
            color: const Color(0xFF819BA0),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 24),
            onPressed: () => _nextSurah(),
            color: const Color(0xFF819BA0),
          ),
        ],
      ),
    );
  }

  void _previousSurah() {
    if (widget.surahNumber > 1) {
      widget.onSurahChange(widget.surahNumber - 1);
      _playAudio(widget.surahNumber - 1);
    }
  }

  void _nextSurah() {
    if (widget.surahNumber < 114) {
      widget.onSurahChange(widget.surahNumber + 1);
      _playAudio(widget.surahNumber + 1);
    }
  }

  Future<void> _seek(int seconds) async {
    if (!isPlaying && currentAudioUrl != null) {
      await _audioPlayer.play();
      setState(() {
        isPlaying = true;
      });
    }
    
    final newPosition = position + Duration(seconds: seconds);
    if (newPosition <= duration && newPosition >= Duration.zero) {
      await _audioPlayer.seek(newPosition);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}