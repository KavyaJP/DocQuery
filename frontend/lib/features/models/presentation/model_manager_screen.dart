import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doc_query/features/models/data/backend_service.dart';

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  final BackendService _apiService = BackendService();

  List<LocalModel> _installedModels = [];
  Map<String, dynamic> _recommendations = {};

  bool _isLoadingData = true;
  String? _errorMessage;

  String? _activeDownloadingModel;
  double _downloadProgress = 0.0;

  StreamSubscription<double>? _downloadSubscription;
  final TextEditingController _customModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.fetchLocalModels(),
        _apiService.fetchRecommendedModels(),
      ]);

      setState(() {
        _installedModels = results[0] as List<LocalModel>;
        _recommendations = results[1] as Map<String, dynamic>;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingData = false;
      });
    }
  }

  Future<void> _deleteModel(String modelName) async {
    try {
      await _apiService.removeOllamaModel(modelName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$modelName successfully deleted from disk')),
      );

      _refreshDashboard();
    } catch (e) {
      _showErrorDialog('Deletion Failed', e.toString());
    }
  }

  void _downloadModel(String modelName) {
    if (_activeDownloadingModel != null) {
      _showErrorDialog(
        'Action Blocked',
        'Please wait until your active download finishes.',
      );
      return;
    }

    setState(() {
      _activeDownloadingModel = modelName;
      _downloadProgress = 0.0;
    });

    _downloadSubscription = _apiService
        .pullModelStream(modelName)
        .listen(
          (double progressFraction) {
            setState(() {
              _downloadProgress = progressFraction;
            });
          },
          onError: (error) {
            setState(() {
              _activeDownloadingModel = null;
              _downloadSubscription = null;
            });
            _showErrorDialog('Download Error', error.toString());
          },
          onDone: () {
            setState(() {
              _activeDownloadingModel = null;
              _downloadSubscription = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$modelName is ready to use!')),
            );
            _refreshDashboard();
          },
          cancelOnError: true,
        );
  }

  void _cancelDownload() {
    if (_downloadSubscription != null) {
      _downloadSubscription!.cancel();

      setState(() {
        _activeDownloadingModel = null;
        _downloadProgress = 0.0;
        _downloadSubscription = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download cancelled successfully.')),
      );
    }
  }

  void _showErrorDialog(String title, String clearDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(clearDetails),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Hardware & Model Configuration'),
        actions: [
          IconButton(
            onPressed: _isLoadingData ? null : _refreshDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Models Status',
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Connection Error: $_errorMessage'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshDashboard,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                  ),
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'Custom Model Ingestion',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customModelController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., deepseek-r1:1.5b',
                                  isDense:
                                      true, // Condenses padding for clean desktop layout
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                // Disables typing into the field if a download is currently running
                                enabled: _activeDownloadingModel == null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              icon: const Icon(Icons.download),
                              tooltip: 'Pull custom model from registry',
                              // Disables the click completely if input is empty OR a download is active
                              onPressed: _activeDownloadingModel != null
                                  ? null
                                  : () {
                                      final String textInput =
                                          _customModelController.text.trim();
                                      if (textInput.isNotEmpty) {
                                        _downloadModel(textInput);
                                        _customModelController
                                            .clear();
                                      }
                                    },
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        Text(
                          'Hardware Recommendations',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Based on your system VRAM, fetch optimized architectures.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ..._recommendations.entries.map((entry) {
                          final String vramTier = entry.key;
                          final String targetModel = entry.value.toString();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.memory),
                              title: Text(targetModel),
                              subtitle: Text('Optimized for: $vramTier'),
                              trailing: IconButton(
                                icon: const Icon(Icons.download_for_offline),
                                onPressed: _activeDownloadingModel != null
                                    ? null
                                    : () => _downloadModel(targetModel),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeDownloadingModel != null) ...[
                          Card(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Downloading: $_activeDownloadingModel',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            tooltip:
                                                'Cancel this network process',
                                            onPressed: _cancelDownload,
                                            constraints:
                                                const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: _downloadProgress,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Text(
                          'Installed System Models',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),

                        if (_installedModels.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                'No local processing weights detected.\nPull a recommended configuration from the left pane.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: _installedModels.length,
                              itemBuilder: (context, index) {
                                final model = _installedModels[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.storage,
                                      color: Colors.blue,
                                    ),
                                    title: Text(model.name),
                                    subtitle: Text(
                                      'Size: ${model.formattedSize} | Params: ${model.parameterSize}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: _activeDownloadingModel != null
                                          ? null
                                          : () => _deleteModel(model.name),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
