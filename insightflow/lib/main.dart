import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: '.env');

  // Initialize Supabase (gracefully handles missing keys)
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_PROJECT_URL') {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  runApp(const InsightFlowApp());
}

class InsightFlowApp extends StatelessWidget {
  const InsightFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightFlow',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.dark),
      routes: {
        '/': (_) => const HomeScreen(),
        '/history': (_) => const HistoryScreen(),
      },
      initialRoute: '/',
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    const primary = Color(0xFF7C3AED);
    const secondary = Color(0xFF4F46E5);
    const surface = Color(0xFF0F0F13);
    const surfaceContainer = Color(0xFF1A1A22);
    const outline = Color(0xFF2E2E3A);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        surfaceContainerHighest: surfaceContainer,
        outline: outline,
        onSurface: Color(0xFFE8E8F0),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF2D1B69),
        onPrimaryContainer: Color(0xFFDDD6FE),
        secondaryContainer: Color(0xFF1E1B4B),
        onSecondaryContainer: Color(0xFFC7D2FE),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: const Color(0xFFE8E8F0),
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFE8E8F0),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: primary,
        labelColor: primary,
        unselectedLabelColor: Color(0xFF8B8BA0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        filled: true,
        fillColor: surfaceContainer,
      ),
      cardColor: surfaceContainer,
      dividerColor: outline,
      iconTheme: const IconThemeData(color: Color(0xFF8B8BA0)),
    );
  }
}
