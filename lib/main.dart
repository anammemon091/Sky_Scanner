import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter/foundation.dart'; // This provides kIsWeb
import 'package:provider/provider.dart';
import 'logic/weather_provider.dart';
import 'presentation/screens/weather_home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- STAGE 4 INTENTS ---
class FocusSearchIntent extends Intent { const FocusSearchIntent(); }
class RefreshWeatherIntent extends Intent { const RefreshWeatherIntent(); }
class GpsLocationIntent extends Intent { const GpsLocationIntent(); }
class QuitAppIntent extends Intent { const QuitAppIntent(); }
class AboutAppIntent extends Intent { const AboutAppIntent(); } // 5th Shortcut

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final bool isApple = Theme.of(context).platform == TargetPlatform.macOS || 
                         Theme.of(context).platform == TargetPlatform.iOS;
    
    final LogicalKeyboardKey modifier = isApple ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // 1. Search (Ctrl+B on Web, Ctrl+F on Desktop)
        LogicalKeySet(modifier, kIsWeb ? LogicalKeyboardKey.keyB : LogicalKeyboardKey.keyF): const FocusSearchIntent(),
        // 2. GPS Location
        LogicalKeySet(modifier, LogicalKeyboardKey.keyG): const GpsLocationIntent(),
        // 3. Refresh
        LogicalKeySet(modifier, LogicalKeyboardKey.keyR): const RefreshWeatherIntent(),
        // 4. Quit App
        LogicalKeySet(modifier, LogicalKeyboardKey.keyQ): const QuitAppIntent(),
        // 5. About/Info (The 5th mandatory shortcut)
        LogicalKeySet(modifier, LogicalKeyboardKey.keyI): const AboutAppIntent(),
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          final bool isModifierDown = HardwareKeyboard.instance.isControlPressed || 
                                      HardwareKeyboard.instance.isMetaPressed;

          if (isModifierDown && event is KeyDownEvent) {
            final key = event.logicalKey;
            // Shield these keys from triggering default browser behaviors
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