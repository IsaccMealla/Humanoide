import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de estado transparente para integración con el header
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2A1F1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Supabase.initialize(
    url: 'https://kgdwepxijaghuspgsvvv.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnZHdlcHhpamFnaHVzcGdzdnZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk1NjI5MjksImV4cCI6MjA5NTEzODkyOX0.vZD9uxTrXjgsD8V1CLMM8VW7gS_vYaNJJE5Tdpb_CnA',
  );

  runApp(const HumanoidCoffeeApp());
}

class HumanoidCoffeeApp extends StatelessWidget {
  const HumanoidCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Humanoid Coffee Co.',
      theme: AppTheme.warmCoffeeTheme,
      home: const AppShell(),
    );
  }
}
