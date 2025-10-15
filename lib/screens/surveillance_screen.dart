import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SurveillanceScreen extends StatefulWidget {
  const SurveillanceScreen({super.key});

  @override
  State<SurveillanceScreen> createState() => _SurveillanceScreenState();
}

class _SurveillanceScreenState extends State<SurveillanceScreen> {
  List<String> _cameras = [];
  bool _isLoading = false;
  String? _selectedCamera;
  Map<String, dynamic>? _cameraConfig;
  String? _lastFeedImage;

  @override
  void initState() {
    super.initState();
    _loadCameras();
    _loadCameraConfig();
  }

  Future<void> _loadCameras() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final cameras = await apiService.getAvailableCameras();
      
      setState(() {
        _cameras = cameras;
        if (cameras.isNotEmpty && _selectedCamera == null) {
          _selectedCamera = cameras.first;
        }
      });
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to load cameras: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCameraConfig() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final config = await apiService.getCameraConfig();
      
      setState(() {
        _cameraConfig = config['config'];
      });
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to load camera config: ${e.toString()}');
    }
  }

  Future<void> _monitorCamera(String location) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.monitorCamera(location, duration: 10);
      
      if (result['success']) {
        String message = result['message'];
        if (result['person_detected']) {
          message += '\n\n👤 Person detected!';
          if (result['faces_detected'] > 0) {
            message += '\n👁️ ${result['faces_detected']} face(s) detected';
          }
        }
        
        AppHelpers.showSuccessSnackBar(context, message);
      } else {
        AppHelpers.showErrorSnackBar(context, 'Monitoring failed');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to monitor camera: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeCameraFeed(String location) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.analyzeCameraFeed(location);
      
      if (result['success']) {
        String message = 'Analysis complete for $location\n';
        message += '👤 Faces: ${result['faces_count']}\n';
        message += '🎯 Objects: ${result['objects_count']}';
        
        if (result['faces_count'] > 0) {
          message += '\n\nFaces detected:';
          for (var face in result['faces']) {
            message += '\n• ${face['identity']} (${(face['confidence'] * 100).toStringAsFixed(1)}%)';
          }
        }
        
        if (result['objects_count'] > 0) {
          message += '\n\nObjects detected:';
          for (var obj in result['objects']) {
            message += '\n• ${obj['name']} (${(obj['confidence'] * 100).toStringAsFixed(1)}%)';
          }
        }
        
        AppHelpers.showSuccessSnackBar(context, message);
      } else {
        AppHelpers.showErrorSnackBar(context, 'Analysis failed');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to analyze camera feed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCameraFeed(String location) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.getCameraFeed(location);
      
      if (result['success']) {
        setState(() {
          _lastFeedImage = result['image'];
        });
        AppHelpers.showSuccessSnackBar(context, 'Camera feed captured');
      } else {
        AppHelpers.showErrorSnackBar(context, 'Failed to get camera feed');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to get camera feed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCamera() async {
    final locationController = TextEditingController();
    final urlController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Camera'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location (e.g., main_gate)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Camera URL (RTSP)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      final location = locationController.text.trim();
      final url = urlController.text.trim();

      if (location.isEmpty || url.isEmpty) {
        AppHelpers.showErrorSnackBar(context, 'Please fill in all fields');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.updateCameraConfig(location, url);
        
        AppHelpers.showSuccessSnackBar(context, 'Camera added successfully');
        _loadCameras();
        _loadCameraConfig();
      } catch (e) {
        AppHelpers.showErrorSnackBar(context, 'Failed to add camera: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Surveillance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCamera,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadCameras();
              _loadCameraConfig();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Camera Selection
                if (_cameras.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Camera:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _selectedCamera,
                          isExpanded: true,
                          items: _cameras.map((camera) {
                            return DropdownMenuItem<String>(
                              value: camera,
                              child: Text(camera),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCamera = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Camera Feed Display
                if (_lastFeedImage != null)
                  Container(
                    margin: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest Feed:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              Uri.dataFromString(_lastFeedImage!).data?.contentAsBytes() ?? Uint8List(0),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action Buttons
                if (_selectedCamera != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        children: [
                          // Monitor Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _monitorCamera(_selectedCamera!),
                              icon: const Icon(Icons.videocam),
                              label: const Text('Monitor Camera (10s)'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.margin),

                          // Analyze Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _analyzeCameraFeed(_selectedCamera!),
                              icon: const Icon(Icons.analytics),
                              label: const Text('Analyze Feed'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.margin),

                          // Get Feed Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _getCameraFeed(_selectedCamera!),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Capture Feed'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Camera Configuration
                if (_cameraConfig != null)
                  Container(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Camera Configuration:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_cameraConfig as Map<String, dynamic>).entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${entry.key}:',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                // Empty State
                if (_cameras.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No cameras configured',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add cameras to start surveillance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addCamera,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Camera'),
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






