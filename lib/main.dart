import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hostel_management_app/features/auth/screens/login_screen.dart';

import 'features/home/screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      designSize: const Size(375, 825),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hostel App',
        initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), 
        '/home': (context) => const HomeScreen(),
      },
      ),
    );
  }
}
