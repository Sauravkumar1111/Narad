import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CameraConfigScreen extends StatefulWidget {
  const CameraConfigScreen({super.key});

  @override
  State<CameraConfigScreen> createState() => _CameraConfigScreenState();
}

class _CameraConfigScreenState extends State<CameraConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  
  List<Map<String, String>> _cameras = [];
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadCameraConfig();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCameraConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final config = await apiService.getCameraConfig();
      
      if (config['success']) {
        final cameraConfig = config['config'] as Map<String, dynamic>;
        setState(() {
          _cameras = cameraConfig.entries.map((entry) => {
            'location': entry.key,
            'url': entry.value.toString(),
          }).toList();
        });
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to load camera config: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateCamera() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final location = _locationController.text.trim();
      final url = _urlController.text.trim();

      await apiService.updateCameraConfig(location, url);
      
      if (_isEditing && _editingIndex != null) {
        // Update existing camera
        setState(() {
          _cameras[_editingIndex!] = {
            'location': location,
            'url': url,
          };
        });
        AppHelpers.showSuccessSnackBar(context, 'Camera updated successfully');
      } else {
        // Add new camera
        setState(() {
          _cameras.add({
            'location': location,
            'url': url,
          });
        });
        AppHelpers.showSuccessSnackBar(context, 'Camera added successfully');
      }

      _clearForm();
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to save camera: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCamera(int index) async {
    final camera = _cameras[index];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Camera'),
        content: Text('Are you sure you want to delete the camera at ${camera['location']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _cameras.removeAt(index);
      });
      AppHelpers.showSuccessSnackBar(context, 'Camera deleted');
    }
  }

  void _editCamera(int index) {
    final camera = _cameras[index];
    _locationController.text = camera['location']!;
    _urlController.text = camera['url']!;
    
    setState(() {
      _isEditing = true;
      _editingIndex = index;
    });
  }

  void _clearForm() {
    _locationController.clear();
    _urlController.clear();
    setState(() {
      _isEditing = false;
      _editingIndex = null;
    });
  }

  Future<void> _testCamera(String location, String url) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.analyzeCameraFeed(location);
      
      if (result['success']) {
        AppHelpers.showSuccessSnackBar(context, 'Camera test successful!');
      } else {
        AppHelpers.showErrorSnackBar(context, 'Camera test failed');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Camera test failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Configuration'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCameraConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Add/Edit Form
                Container(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Edit Camera' : 'Add New Camera',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Camera Location',
                            hintText: 'e.g., main gate, terrace, front door',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter camera location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'Camera URL (RTSP)',
                            hintText: 'rtsp://username:password@ip:port/stream',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.videocam),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter camera URL';
                            }
                            if (!value.toLowerCase().startsWith('rtsp://')) {
                              return 'URL must start with rtsp://';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _addOrUpdateCamera,
                                icon: Icon(_isEditing ? Icons.save : Icons.add),
                                label: Text(_isEditing ? 'Update Camera' : 'Add Camera'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _clearForm,
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Divider(),
                
                // Camera List
                Expanded(
                  child: _cameras.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No cameras configured',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add cameras to enable surveillance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.padding),
                          itemCount: _cameras.length,
                          itemBuilder: (context, index) {
                            final camera = _cameras[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.videocam),
                                title: Text(
                                  camera['location']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      camera['url']!,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Configured',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'test':
                                        _testCamera(camera['location']!, camera['url']!);
                                        break;
                                      case 'edit':
                                        _editCamera(index);
                                        break;
                                      case 'delete':
                                        _deleteCamera(index);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'test',
                                      child: Row(
                                        children: [
                                          Icon(Icons.play_arrow),
                                          SizedBox(width: 8),
                                          Text('Test Camera'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Instructions
                if (_cameras.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: const Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'How to Use Surveillance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Once cameras are configured, you can ask Jarvis:',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '• "Who is on main gate?"',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '• "Check terrace"',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '• "Monitor front door"',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '• "What\'s happening outside?"',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}






