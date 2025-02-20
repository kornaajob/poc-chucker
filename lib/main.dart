import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/home_screen.dart';
import 'viewmodel/user_viewmodel.dart';
import 'service/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserViewModel(ApiService()),
        ),
      ],
      child: const MaterialApp(
        // ลบ navigatorObservers ของ Chucker ออก
        home: HomeScreen(),
      ),
    );
  }
}
