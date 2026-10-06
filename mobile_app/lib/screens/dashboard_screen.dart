import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For vibration
import 'dart:io';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_colors.dart';
import 'package:vibration/vibration.dart';

class DashboardScreen extends StatefulWidget {
  final String serverIp;

  const DashboardScreen({Key? key, required this.serverIp}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  String _currentAlert = "Establishing Link...";
  Color _alertColor = AppColors.accentCyan;
  bool _isConnected = false;

  Socket? _socket;
  final FlutterTts flutterTts = FlutterTts(); 
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupUIAnimation();
    _initTTS();
    _connectToServer();
  }

  void _setupUIAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    // Forces the app to finish speaking before starting the next sentence
    await flutterTts.setQueueMode(1); 
  }

  void _connectToServer() async {
    try {
      // Connects to Python on Port 8555
      _socket = await Socket.connect(widget.serverIp, 8555);
      
      if (mounted) {
        setState(() {
          _isConnected = true;
          _currentAlert = "System Online. Scanning...";
          _alertColor = AppColors.accentCyan;
        });
      }

      _socket!.listen(
        (List<int> event) {
          String message = utf8.decode(event).trim();
          if (message.isNotEmpty) {
            _handleIncomingAlert(message);
          }
        },
        onError: (error) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleIncomingAlert(String message) async {
    if (!mounted) return;

    // --- THE HUMAN VOICE ENGINE ---
    String spokenSentence = "";
    
    if (message.toLowerCase().contains("clear")) {
      spokenSentence = "Your path is clear. You can safely move forward.";
    } else if (message.toLowerCase().contains("stranger")) {
      spokenSentence = "Caution. A stranger is in your view.";
    } else {
      // For recognized teammates (Sagar, Ananya, Keerthana)
      // It capitalizes the first letter for perfect pronunciation
      String formattedName = message[0].toUpperCase() + message.substring(1).toLowerCase();
      spokenSentence = "$formattedName is right in front of you.";
    }

    // 1. Speak the natural sentence aloud
    await flutterTts.speak(spokenSentence);
    
    // 2. Custom Heavy Vibration (Half a second buzz)
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 500, amplitude: 255); 
    }

    // 3. Update the gorgeous UI colors
    setState(() {
      // The screen will still just show "SAGAR" or "STRANGER" so the UI stays clean
      _currentAlert = message; 
      
      if (message.toLowerCase().contains("clear")) {
        _alertColor = AppColors.safeGreen;
      } else if (message.toLowerCase().contains("stranger")) {
        _alertColor = AppColors.alertRed;
      } else {
        _alertColor = AppColors.accentCyan;
      }
    });
  }

  void _handleDisconnect() {
    if (mounted) {
      setState(() {
        _isConnected = false;
        _currentAlert = "Connection Lost.";
        _alertColor = Colors.grey;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _socket?.close();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? AppColors.accentCyan : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isConnected ? "LINK SECURE" : "DISCONNECTED",
              style: TextStyle(
                color: _isConnected ? AppColors.accentCyan : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _isConnected ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: _alertColor.withOpacity(0.5),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: _alertColor.withOpacity(0.8),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _currentAlert.toLowerCase().contains("clear") 
                          ? Icons.check_circle_outline 
                          : (_currentAlert.toLowerCase().contains("stranger") 
                              ? Icons.warning_amber_rounded 
                              : Icons.face_retouching_natural),
                      size: 80,
                      color: _alertColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _currentAlert.toUpperCase(),
                    key: ValueKey(_currentAlert),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: _alertColor,
                          blurRadius: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                "SMART GLASSES ACTIVE VISION",
                style: TextStyle(
                  color: AppColors.textMuted,
                  letterSpacing: 3,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}