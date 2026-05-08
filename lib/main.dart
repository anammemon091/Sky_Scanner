import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter/foundation.dart'; // This provides kIsWeb
import 'package:provider/provider.dart';
import 'logic/weather_provider.dart';
import 'presentation/screens/weather_home.dart';
// REMOVED: import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- STAGE 4 INTENTS ---
class FocusSearchIntent extends Intent { const FocusSearchIntent(); }
class RefreshWeatherIntent extends Intent { const RefreshWeatherIntent(); }
class GpsLocationIntent extends Intent { const GpsLocationIntent(); }
class QuitAppIntent extends Intent { const QuitAppIntent(); }
class AboutAppIntent extends Intent { const AboutAppIntent(); } 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REMOVED: dotenv.load block. 
  // The API key is now handled via --dart-define in your deploy.yml
  
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
    // Check for macOS or iOS
    final bool isApple = defaultTargetPlatform == TargetPlatform.macOS || 
                         defaultTargetPlatform == TargetPlatform.iOS;
    
    final LogicalKeyboardKey modifier = isApple ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(modifier, kIsWeb ? LogicalKeyboardKey.keyB : LogicalKeyboardKey.keyF): const FocusSearchIntent(),
        LogicalKeySet(modifier, LogicalKeyboardKey.keyG): const GpsLocationIntent(),
        LogicalKeySet(modifier, LogicalKeyboardKey.keyR): const RefreshWeatherIntent(),
        LogicalKeySet(modifier, LogicalKeyboardKey.keyQ): const QuitAppIntent(),
        LogicalKeySet(modifier, LogicalKeyboardKey.keyI): const AboutAppIntent(),
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          final bool isModifierDown = HardwareKeyboard.instance.isControlPressed || 
                                      HardwareKeyboard.instance.isMetaPressed;

          if (isModifierDown && event is KeyDownEvent) {
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.keyF || 
                key == LogicalKeyboardKey.keyG || 
                key == LogicalKeyboardKey.keyR || 
                key == LogicalKeyboardKey.keyB ||
                key == LogicalKeyboardKey.keyQ ||
                key == LogicalKeyboardKey.keyI) {
              return KeyEventResult.handled; 
            }
          }
          return KeyEventResult.ignored;
        },
        child: MaterialApp(
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
        ),
      ),
    );
  }
}