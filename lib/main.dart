import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'services/expense_service.dart';
import 'services/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure edge-to-edge transparent system navigation
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase cleanly through isolated FirebaseConfig
  // Firebase configuration can be updated or swapped without restructuring any UI or data layers.
  await FirebaseConfig.initialize();

  // Instantiate dedicated Firestore ExpenseService
  final expenseService = ExpenseService();

  runApp(LuminaExpenseApp(expenseService: expenseService));
}
