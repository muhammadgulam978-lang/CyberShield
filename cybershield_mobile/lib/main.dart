import 'package:cybershield_mobile/features/auth/bloc/scan_bloc.dart';
import 'package:cybershield_mobile/features/auth/repository/scan_repository.dart';
import 'package:cybershield_mobile/scan/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: "token");

  runApp(CyberShieldApp(isLoggedIn: token != null));
}

class CyberShieldApp extends StatelessWidget {
  final bool isLoggedIn;
  const CyberShieldApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ScanRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => ScanBloc(
              scanRepository: RepositoryProvider.of<ScanRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'CyberShield',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          // ✅ Yahan se 'const' hata diya gaya hai
          home: isLoggedIn ? const ScanScreen() : LoginScreen(),
          routes: {
            // ✅ Yahan se bhi 'const' hata diya gaya hai
            '/login': (context) => LoginScreen(),
            '/scan': (context) => const ScanScreen(),
          },
        ),
      ),
    );
  }
}
