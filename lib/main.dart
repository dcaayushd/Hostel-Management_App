import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/auth/screens/login_screen.dart';

import 'features/home/screen/home_screen.dart';
=======
>>>>>>> parent of dd2390c (Login Screen Created)

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostel App',
>>>>>>> parent of dd2390c (Login Screen Created)
    );
  }
}
