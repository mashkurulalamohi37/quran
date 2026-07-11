import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Audio CDN — Mishary Alafasy 128kbps (everyayah.com)
/// URL format: https://everyayah.com/data/Alafasy_128kbps/001001.mp3
String _buildAudioUrl(int surahId, int ayahIndex) {
  final s = surahId.toString().padLeft(3, '0');
  final a = ayahIndex.toString().padLeft(3, '0');
  return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
}

enum AudioState { idle, loading, playing, paused, error }

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  int _currentSurahId = 0;
  int _currentAyahIndex = 0;
  int _maxAyah = 0;
  AudioState _state = AudioState.idle;
  String _errorMessage = '';

  int get currentSurahId => _currentSurahId;
  int get currentAyahIndex => _currentAyahIndex;
  AudioState get state => _state;
  bool get isPlaying => _state == AudioState.playing;
  bool get isLoading => _state == AudioState.loading;
  bool get hasError => _state == AudioState.error;
  String get errorMessage => _errorMessage;
  bool get isActive => _state != AudioState.idle;

  AudioService() {
    // Listen to player state changes and update state reactively
    _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        _onCompleted();
      } else if (processingState == ProcessingState.loading ||
                 processingState == ProcessingState.buffering) {
        _state = AudioState.loading;
        notifyListeners();
      } else if (playing) {
        _state = AudioState.playing;
        notifyListeners();
      } else if (processingState != ProcessingState.idle) {
        _state = AudioState.paused;
        notifyListeners();
      } else {
        _state = AudioState.idle;
        notifyListeners();
      }
    });

    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        _state = AudioState.error;
        _errorMessage = 'Audio load failed';
        notifyListeners();
      },
    );
  }

  /// Play a specific Ayah. Pass [maxAyah] to enable auto-next.
  Future<void> playAyah({
    required int surahId,
    required int ayahIndex,
    int maxAyah = 0,
  }) async {
    if (_currentSurahId == surahId && _currentAyahIndex == ayahIndex) {
      await togglePlayPause();
      return;
    }

    _currentSurahId = surahId;
    _currentAyahIndex = ayahIndex;
    _maxAyah = maxAyah;
    _state = AudioState.loading;
    notifyListeners();

    try {
      final url = _buildAudioUrl(surahId, ayahIndex);
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Cannot play audio';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Cannot toggle playback';
      notifyListeners();
    }
  }

  Future<void> playNext() async {
    if (_maxAyah > 0 && _currentAyahIndex < _maxAyah) {
      await playAyah(
        surahId: _currentSurahId,
        ayahIndex: _currentAyahIndex + 1,
        maxAyah: _maxAyah,
      );
    }
  }

  Future<void> playPrevious() async {
    if (_currentAyahIndex > 1) {
      await playAyah(
        surahId: _currentSurahId,
        ayahIndex: _currentAyahIndex - 1,
        maxAyah: _maxAyah,
      );
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _state = AudioState.idle;
    notifyListeners();
  }

  bool isPlayingAyah(int surahId, int ayahIndex) {
    return _currentSurahId == surahId &&
        _currentAyahIndex == ayahIndex &&
        _state == AudioState.playing;
  }

  bool isCurrentAyah(int surahId, int ayahIndex) {
    return _currentSurahId == surahId && _currentAyahIndex == ayahIndex;
  }

  void _onCompleted() {
    if (_maxAyah > 0 && _currentAyahIndex < _maxAyah) {
      playNext();
    } else {
      _state = AudioState.idle;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
