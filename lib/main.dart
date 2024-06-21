import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hostel_management_app/features/auth/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenUtilInit(
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      designSize: Size(375, 825),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hostel App',
        home: LoginScreen(),
      ),
    );
  }
}
