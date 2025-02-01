import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/custom_router.dart';
import 'package:client_flutter/api/api.dart';
import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/providers/network_status_provider.dart';
import 'package:client_flutter/services/auth/user_auth_service.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/services/team/team_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userAuthService = await UserAuthService.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserAuthService>.value(value: userAuthService),
        ChangeNotifierProvider(create: (_) => NetworkStatusProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(userAuthService: userAuthService)),
        ChangeNotifierProvider(create: (_) => TeamService()),
        ChangeNotifierProvider(create: (_) => ProjectService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Api.addInterceptor(context);

    return MaterialApp.router(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      routerConfig: CustomRouter.router,
    );
  }
}
