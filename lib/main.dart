import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'constants/app_constants.dart';
import 'helpers/tf_lifehelpr.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TFLiteHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
