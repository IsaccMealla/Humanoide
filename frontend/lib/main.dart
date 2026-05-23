import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kgdwepxijaghuspgsvvv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnZHdlcHhpamFnaHVzcGdzdnZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk1NjI5MjksImV4cCI6MjA5NTEzODkyOX0.vZD9uxTrXjgsD8V1CLMM8VW7gS_vYaNJJE5Tdpb_CnA',
  );

  runApp(const RobotBaristaApp());
}

class RobotBaristaApp extends StatelessWidget {
  const RobotBaristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robot Barista',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
