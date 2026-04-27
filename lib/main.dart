import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/weather_provider.dart';
import 'presentation/screens/weather_home.dart';

void main() {
  // Ensures Flutter bindings are initialized before any logic runs
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const SkyScanner(),
    ),
  );
}

class SkyScanner extends StatelessWidget {
  const SkyScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Scanner',
      debugShowCheckedModeBanner: false,
      
      // Customizing the Dark Theme for a more "SaaS" look
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111328),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        // Global Text Theme for consistency
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      
      home: const WeatherHome(),
    );
  }
}