import 'package:flutter/material.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';
import 'encrypted_data_view.dart';

class ApiDetailScreen extends StatelessWidget {
  final ApiRequest request;
  final ApiResponse? response;

  const ApiDetailScreen({
    super.key,
    required this.request,
    this.response,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Request'),
              Tab(text: 'Response'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Request Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Method: ${request.method}'),
                  Text('Path: ${request.path}'),
                  const SizedBox(height: 16),
                  Text('Headers:',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(request.headers.toString()),
                  const SizedBox(height: 16),
                  EncryptedDataView(
                    originalData: request.body?.toString(),
                    encryptedData: request.encryptedBody,
                  ),
                ],
              ),
            ),
            // Response Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: response != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Code: ${response!.statusCode}'),
                        const SizedBox(height: 16),
                        Text('Headers:',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(response!.headers.toString()),
                        const SizedBox(height: 16),
                        EncryptedDataView(
                          originalData: response!.body?.toString(),
                          encryptedData: response!.encryptedBody,
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('No response received yet'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
