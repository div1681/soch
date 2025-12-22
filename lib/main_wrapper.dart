import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soch/models/user_model.dart';
import 'package:soch/screens/auth/login_screen.dart';
import 'package:soch/screens/home/navigator_screen.dart';
import 'package:soch/services/auth_services.dart';
import 'package:soch/services/notifications/foreground_noti.dart';
import 'package:soch/services/notifications/notification_channel.dart';
import 'package:soch/services/notifications/permission.dart';
import 'package:soch/services/notifications/upload_fcm.dart';
import 'package:soch/services/user_services.dart';
import 'package:soch/widgets/skeleton_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/utils/app_theme.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {


  @override
  void initState() {
    super.initState();
    _requestPermission();

    WidgetsBinding.instance.addPostFrameCallback ((_) async {
      noti_listener.init(context);
      await NotificationChannelService.setupHighImportanceChannel();
    });
    
  }

  _requestPermission() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await requestPermission();
  }

  _uploadfcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await uploadFcmToken();
    
  }
bool _tokengenerated = false;
  
  Widget _buildExtendedSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Text(
          'SOCH.',
          style: GoogleFonts.outfit(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: AppTheme.accent,
            letterSpacing: 8.0, 
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return _buildExtendedSplash(context);
        }
        if (!authSnap.hasData){
          _tokengenerated = false;
           return const LoginScreen();
        }

        if(!_tokengenerated){
          _tokengenerated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            
            await _uploadfcmToken();
          });
        }

        return FutureBuilder<UserModel?>(
          future: UserService().getCurrentUser(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return _buildExtendedSplash(context);
            }
            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: Text('User doc missing')),
              );
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
