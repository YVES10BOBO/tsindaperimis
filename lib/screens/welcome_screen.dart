import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_info.dart';
import '../state/app_state.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: <Widget>[
              Spacer(),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.directions_car, size: 56, color: AppColors.primary),
              ),
              SizedBox(height: 28),
              Text(
                AppInfo.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              Text(
                AppInfo.tagline,
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 16, height: 1.5),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => AuthScreen(isRegister: false)),
                ),
                child: Text('Injira'),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => AuthScreen(isRegister: true)),
                ),
                child: Text('Iyandikishe'),
              ),
              SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(48),
                ),
                onPressed: () {
                  AppScope.of(context).continueAsGuest();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => MainShell()),
                  );
                },
                child: Text('Komeza nka Mushyitsi (utiyandikishije)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
