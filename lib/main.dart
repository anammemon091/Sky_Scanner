import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/weather_provider.dart';
import 'presentation/screens/weather_home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

// 1. Change void to Future<void> and add async
Future<void> main() async {
  // 2. Ensures Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Load the .env file before the app starts
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file. Make sure it exists in the root folder.");
  }
  
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
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111328),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      
      home: const WeatherHome(),
    );
  }
}