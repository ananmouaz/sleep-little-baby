import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_noise/constants/app_styles.dart';
import 'package:white_noise/presentation/widgets/animated_button.dart';
import 'package:white_noise/presentation/widgets/animated_music_icon.dart';
import 'package:white_noise/presentation/widgets/fancy_slider.dart';
import 'package:white_noise/presentation/widgets/timer_selector.dart';



class SoundPlayerScreen extends StatefulWidget {
  final String sound;
  final String audioFile;

  const SoundPlayerScreen({
    required this.sound,
    required this.audioFile,
  });

  @override
  _SoundPlayerScreenState createState() => _SoundPlayerScreenState();
}

class _SoundPlayerScreenState extends State<SoundPlayerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  double _volume = 0.5;
  int _duration = 15;
  Timer? _timer;
  late AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _shouldContinuePlaying = false;
  late bool isFirstTime;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Increased crossfade duration for smoother transition
  static const crossFadeDuration = Duration(milliseconds: 500);

  Future<void> _checkFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if it's the first time opening the page
    isFirstTime = prefs.getBool('isFirstTimeOpeningPage') ?? true;
      // Show the rate dialog here
      showRateDialog();
      // Update the value in SharedPreferences
      await prefs.setBool('isFirstTimeOpeningPage', false);
    }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _checkFirstTime();
    _setupAudioPlayer();
    _configureBackgroundAudio();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    await createNotificationChannel();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse response) {
        if (response.actionId == 'pause') {
          _pauseAudio();
        } else if (response.actionId == 'play') {
          _resumeAudio();
        }
      },
    );
    await requestNotificationPermissions(); // Request permission
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    await showMediaNotification(); // Update notification
  }

  void _resumeAudio() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    await showMediaNotification(); // Update notification
  }


  Future<void> requestNotificationPermissions() async {
    if (await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ??
        false) {
      print("Notification permission granted");
    } else {
      print("Notification permission denied");
    }
  }

  Future<void> createNotificationChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'media_channel', // Channel ID
        'Media Playback', // Channel name
        description: 'Controls media playback',
        importance: Importance.high,
      ));
    }
  }



  Future<void> showMediaNotification() async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'media_channel',
        'Media Playback',
        channelDescription: 'Notification for media playback control',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        enableLights: true,
        playSound: false, // Avoid unnecessary sounds
        ongoing: true, // Keep the notification active
        visibility: NotificationVisibility.public,
        actions: [
          AndroidNotificationAction('pause', 'Pause'),
          AndroidNotificationAction('play', 'Play'),
        ],
      );


      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Putting your baby to sleep',
        'Playing ${widget.sound}',
        platformChannelSpecifics,
        payload: 'noop'
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  Future<void> _configureBackgroundAudio() async {
    // Configure audio session for background playback
    try {
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // For iOS, we need to configure the audio session
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        await _audioPlayer.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ));
      }
    } catch (e) {
      print('Error configuring background audio: $e');
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Only cleanup when the app is fully killed
      _cleanup();
    }
  }

  void _cleanup() {
    _shouldContinuePlaying = false;
    _timer?.cancel();
    _audioPlayer.pause();
  }


  void _setupAudioPlayer() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSourceAsset(widget.audioFile);
    await _audioPlayer.setVolume(_volume);

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_shouldContinuePlaying) {
        _smoothRestart();
      }
    });
  }

  void _smoothRestart() async {
    if (!_shouldContinuePlaying) return;

    // Start fading out
    const steps = 50; // Increased steps for smoother transition
    final stepDuration = crossFadeDuration.inMilliseconds ~/ steps;

    // Fade out
    for (var i = steps; i >= 0; i--) {
      if (!_shouldContinuePlaying) break;
      final ratio = i / steps;
      await _audioPlayer.setVolume(_volume * ratio);
      await Future.delayed(Duration(milliseconds: stepDuration ~/ 2));
    }

    if (_shouldContinuePlaying) {
      // Restart playback
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.resume();

      // Fade in
      for (var i = 0; i <= steps; i++) {
        if (!_shouldContinuePlaying) break;
        final ratio = i / steps;
        await _audioPlayer.setVolume(_volume * ratio);
        await Future.delayed(Duration(milliseconds: stepDuration ~/ 2));
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanup();
    _animationController.dispose();
    _audioPlayer.dispose();
    flutterLocalNotificationsPlugin.cancel(0); // Cancel notification on dispose
    super.dispose();
  }

  void showRateDialog() async{
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
    else {
      showCustomRatingDialog();
    }
  }

  void showCustomRatingDialog() {
    final InAppReview inAppReview = InAppReview.instance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate us!"),
        content: Text("Please rate us to help improve the app."),
        actions: [
          TextButton(
            onPressed: () async{
              if (await inAppReview.isAvailable()) {
                // Open the store review page
                inAppReview.openStoreListing();
              }
            },
            child: Text("Rate Now"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without rating.
            },
            child: Text("Later"),
          ),
        ],
      ),
    );
  }

  void _startPlaying() async {
    if (!_isPlaying) {
      _shouldContinuePlaying = true;
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      _startTimer();
      setState(() {
        _isPlaying = true;
      });
      await showMediaNotification(); // Show notification when playing
    } else {
      _shouldContinuePlaying = false;
      await _audioPlayer.pause();
      _timer?.cancel();
      setState(() {
        _isPlaying = false;
      });
      await flutterLocalNotificationsPlugin.cancel(0); // Cancel notification when paused
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(minutes: _duration), () {
      _shouldContinuePlaying = false;
      _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
      _audioPlayer.setVolume(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.purple[100]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedMusicIcon(isPlaying: _isPlaying),
                SizedBox(height: 30),
                Text(
                    'Volume 🔊',
                    style: AppStyles.h3
                ),
                FancySlider(
                  value: _volume,
                  onChanged: _updateVolume,
                ),
                SizedBox(height: 30),
                Text(
                    'Sleep Timer ⏰',
                    style: AppStyles.h3
                ),
                SizedBox(height: 12,),
                TimerSelector(
                  duration: _duration,
                  onChanged: (value) {
                    setState(() {
                      _duration = value ?? 15;
                      if (_isPlaying) {
                        _startTimer();
                      }
                    });
                  },
                ),
                SizedBox(height: 30),
                AnimatedButton(
                  onPressed: _startPlaying,
                  text: _isPlaying ? 'Stop Sound' : 'Play Sound',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}