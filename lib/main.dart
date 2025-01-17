import 'package:flutter/material.dart';
import 'package:flutter_board/screen/main_screen.dart';
import 'package:flutter_board/screen/board/insert_screen.dart';
import 'package:flutter_board/screen/board/list_screen.dart';
import 'package:flutter_board/screen/board/read_screen.dart';
import 'package:flutter_board/screen/board/update_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 106, 104, 110)),
        useMaterial3: true,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainScreen(),
        '/board/list': (context) => const ListScreen(),
        '/board/read': (context) => const ReadScreen(),
        '/board/insert': (context) => const InsertScreen(),
        '/board/update': (context) => const UpdateScreen(),
      },
    );
  }
}
