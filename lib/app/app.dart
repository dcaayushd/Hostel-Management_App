import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../core/services/hostel_repository.dart';
import '../core/state/app_state.dart';
import '../features/notice/providers/notice_provider.dart';
import 'bootstrap/repository_factory.dart';
import 'app_shell.dart';
import 'app_theme.dart';
import 'routes.dart';

class HostelManagementApp extends StatefulWidget {
  const HostelManagementApp({super.key});

  @override
  State<HostelManagementApp> createState() => _HostelManagementAppState();
}

class _HostelManagementAppState extends State<HostelManagementApp> {
  late final Future<HostelRepository> _repositoryFuture =
      buildHostelRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HostelRepository>(
      future: _repositoryFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<HostelRepository> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hostel Management',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hostel Management',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const Scaffold(
              body: Center(
                child: Text('Unable to initialize the app backend.'),
              ),
            ),
          );
        }

        final HostelRepository repository = snapshot.data!;
        return MultiProvider(
          providers: <ChangeNotifierProvider<dynamic>>[
            ChangeNotifierProvider<AppState>(
              create: (_) => AppState(repository)..initialize(),
            ),
            ChangeNotifierProvider<NoticeProvider>(
              create: (_) {
                final NoticeProvider provider = NoticeProvider(repository);
                unawaited(provider.loadNotices().catchError((Object _) {}));
                return provider;
              },
            ),
          ],
          child: Consumer<AppState>(
            builder: (BuildContext context, AppState state, Widget? _) {
              return ScreenUtilInit(
                designSize: const Size(390, 844),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (BuildContext context, Widget? child) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Hostel Management',
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: state.themeMode,
                    themeAnimationDuration: const Duration(milliseconds: 320),
                    themeAnimationCurve: Curves.easeInOutCubic,
                    onGenerateRoute: AppRoutes.onGenerateRoute,
                    home: child,
                  );
                },
                child: const AppShell(),
              );
            },
          ),
        );
      },
    );
  }
}
