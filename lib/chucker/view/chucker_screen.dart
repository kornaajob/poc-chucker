// lib/chucker/view/chucker_screen.dart
import 'package:flutter/material.dart';
import 'package:poc_chucker/chucker/widgets/api_detail_screen.dart';
import '../manager/chucker_manager.dart';

class ChuckerScreen extends StatelessWidget {
  const ChuckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = ChuckerManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Calls'),
      ),
      body: ListView.builder(
        itemCount: manager.requests.length,
        itemBuilder: (context, index) {
          final request = manager.requests[index];
          final response = manager.getResponse(request.path);

          return ListTile(
            title: Text('${request.method} ${request.path}'),
            subtitle: Text(response?.statusCode.toString() ?? 'Pending'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApiDetailScreen(
                    request: request,
                    response: response,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
