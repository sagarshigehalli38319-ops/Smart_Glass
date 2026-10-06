import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart'; // We will uncomment this next!

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController();


// Replace your existing function:
  void _connectToGlasses() {
    String ip = _ipController.text.trim();
    if (ip.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(serverIp: ip),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.remove_red_eye_rounded, size: 60, color: AppColors.accentCyan),
              SizedBox(height: 20),
              Text(
                "Smart Glasses\nUplink.",
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Enter your master laptop IPv4 address to establish a secure connection.",
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
              SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: TextField(
                  controller: _ipController,
                  style: TextStyle(color: AppColors.textMain, fontSize: 18),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "e.g., 10.184.244.53",
                    hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.wifi_tethering, color: AppColors.accentCyan),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: _connectToGlasses,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentCyan, Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "INITIALIZE LINK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
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