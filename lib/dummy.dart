import 'package:black_coffer/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

void main() {
  runApp(const Dummy());
}

class Dummy extends StatelessWidget {
  const Dummy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Assignment',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const Progress(),
    );
  }
}

class Progress extends StatelessWidget {
  const Progress({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          SizedBox(
              height: 50,
              child: LiquidLinearProgressIndicator(
                value: 0.15,
                valueColor: AlwaysStoppedAnimation(getColors(context)
                    .primary), // Defaults to the current Theme's accentColor.
                backgroundColor: getColors(context)
                    .background, // Defaults to the current Theme's backgroundColor.
                borderColor: getColors(context).primary,
                borderWidth: 2.0,
                borderRadius: 8.0,
                center: const Text(
                  "Loading...",
                  style: TextStyle(color: Colors.blue),
                ),
              )),
        ],
      ),
    );
  }
}
