import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../services/vision_service.dart';
import '../services/memory_service.dart';
import '../services/api_service.dart';
import '../widgets/loader.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isAnalyzing = false;
  String? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final visionService = Provider.of<VisionService>(context, listen: false);
    await visionService.initializeCamera();
  }

  Future<void> _captureAndAnalyze() async {
    final visionService = Provider.of<VisionService>(context, listen: false);
    final memoryService = Provider.of<MemoryService>(context, listen: false);

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      // Capture image
      final imageFile = await visionService.captureImage();
      if (imageFile == null) {
        AppHelpers.showErrorSnackBar(context, 'Failed to capture image');
        return;
      }

      // Add image message to chat
      await memoryService.addImageMessage(
        'Captured image for analysis',
        imageFile.path,
        true,
      );

      // Analyze image
      final results = await visionService.analyzeImage(imageFile);
      if (results != null) {
        final faces = results['faces'] as List? ?? [];
        final objects = results['objects'] as List? ?? [];
        
        String analysisText = 'Image Analysis Results:\n';
        if (faces.isNotEmpty) {
          analysisText += 'Faces detected: ${faces.length}\n';
          for (var face in faces) {
            analysisText += '- ${face['name'] ?? 'Unknown person'}\n';
          }
        }
        if (objects.isNotEmpty) {
          analysisText += 'Objects detected: ${objects.length}\n';
          for (var obj in objects) {
            analysisText += '- ${obj['name'] ?? 'Unknown object'}\n';
          }
        }
        if (faces.isEmpty && objects.isEmpty) {
          analysisText = 'No faces or objects detected in the image.';
        }

        // Add analysis result to chat
        await memoryService.addJarvisMessage(analysisText);

        setState(() {
          _analysisResult = analysisText;
        });

        AppHelpers.showSuccessSnackBar(context, 'Image analyzed successfully');
      } else {
        AppHelpers.showErrorSnackBar(context, 'Failed to analyze image');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final visionService = Provider.of<VisionService>(context, listen: false);
    final memoryService = Provider.of<MemoryService>(context, listen: false);

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      // Pick image from gallery
      final imageFile = await visionService.pickImageFromGallery();
      if (imageFile == null) {
        AppHelpers.showErrorSnackBar(context, 'No image selected');
        return;
      }

      // Add image message to chat
      await memoryService.addImageMessage(
        'Selected image from gallery for analysis',
        imageFile.path,
        true,
      );

      // Analyze image
      final results = await visionService.analyzeImage(imageFile);
      if (results != null) {
        final faces = results['faces'] as List? ?? [];
        final objects = results['objects'] as List? ?? [];
        
        String analysisText = 'Image Analysis Results:\n';
        if (faces.isNotEmpty) {
          analysisText += 'Faces detected: ${faces.length}\n';
          for (var face in faces) {
            analysisText += '- ${face['name'] ?? 'Unknown person'}\n';
          }
        }
        if (objects.isNotEmpty) {
          analysisText += 'Objects detected: ${objects.length}\n';
          for (var obj in objects) {
            analysisText += '- ${obj['name'] ?? 'Unknown object'}\n';
          }
        }
        if (faces.isEmpty && objects.isEmpty) {
          analysisText = 'No faces or objects detected in the image.';
        }

        // Add analysis result to chat
        await memoryService.addJarvisMessage(analysisText);

        setState(() {
          _analysisResult = analysisText;
        });

        AppHelpers.showSuccessSnackBar(context, 'Image analyzed successfully');
      } else {
        AppHelpers.showErrorSnackBar(context, 'Failed to analyze image');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
      body: Consumer<VisionService>(
        builder: (context, visionService, child) {
          // Check if running on web
          if (kIsWeb) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera not supported on web',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please use the mobile app for full camera features',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                  ),
                ],
              ),
            );
          }

          if (!visionService.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing camera...'),
                ],
              ),
            );
          }

          if (visionService.cameraController == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Camera not available'),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Camera preview
              Positioned.fill(
                child: CameraPreview(visionService.cameraController!),
              ),

              // Camera overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.cameraOverlayColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Analysis result overlay
              if (_analysisResult != null)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _analysisResult!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // Loading overlay
              if (_isAnalyzing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.primaryColor),
                          SizedBox(height: 16),
                          Text(
                            'Analyzing image...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      FloatingActionButton(
                        onPressed: _pickImageFromGallery,
                        backgroundColor: AppTheme.cameraButtonInactiveColor,
                        child: const Icon(Icons.photo_library, color: Colors.white),
                      ),

                      // Capture button
                      FloatingActionButton(
                        onPressed: _isAnalyzing ? null : _captureAndAnalyze,
                        backgroundColor: visionService.isCapturing 
                            ? AppTheme.cameraButtonColor 
                            : AppTheme.cameraButtonInactiveColor,
                        child: visionService.isCapturing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Icon(Icons.camera_alt, color: Colors.white),
                      ),

                      // Switch camera button
                      FloatingActionButton(
                        onPressed: visionService.switchCamera,
                        backgroundColor: AppTheme.cameraButtonInactiveColor,
                        child: const Icon(Icons.switch_camera, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
