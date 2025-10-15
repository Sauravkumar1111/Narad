import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class VisionService extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final ApiService _apiService;
  
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _lastCapturedImagePath;

  VisionService({required ApiService apiService}) : _apiService = apiService;

  // Getters
  List<CameraDescription>? get cameras => _cameras;
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isCapturing => _isCapturing;
  String? get lastCapturedImagePath => _lastCapturedImagePath;

  // Initialize camera
  Future<bool> initializeCamera() async {
    try {
      // Check if running on web
      if (kIsWeb) {
        debugPrint('Camera not supported on web platform');
        return false;
      }

      // Request camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        debugPrint('Camera permission denied');
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return false;
      }

      // Initialize camera controller
      _cameraController = CameraController(
        _cameras![0], // Use first camera (usually back camera)
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      notifyListeners();
      
      debugPrint('Camera initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return false;
    }
  }

  // Capture image from camera
  Future<File?> captureImage() async {
    if (!_isInitialized || _cameraController == null) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      _isCapturing = true;
      notifyListeners();

      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);
      
      _lastCapturedImagePath = imageFile.path;
      _isCapturing = false;
      notifyListeners();

      debugPrint('Image captured: ${imageFile.path}');
      return imageFile;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      _isCapturing = false;
      notifyListeners();
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageSize.toDouble(),
        maxHeight: AppConstants.maxImageSize.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        _lastCapturedImagePath = imageFile.path;
        notifyListeners();
        return imageFile;
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }

  // Pick image from camera (using image_picker)
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageSize.toDouble(),
        maxHeight: AppConstants.maxImageSize.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        _lastCapturedImagePath = imageFile.path;
        notifyListeners();
        return imageFile;
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
    return null;
  }

  // Analyze image with backend
  Future<Map<String, dynamic>?> analyzeImage(File imageFile, {String analysisType = 'both'}) async {
    try {
      debugPrint('Analyzing image: ${imageFile.path}');
      
      // Check if running on web
      if (kIsWeb) {
        debugPrint('Image analysis not supported on web platform');
        return {
          'faces': [],
          'objects': [],
          'message': 'Image analysis not available on web. Please use mobile app for full camera features.'
        };
      }
      
      final response = await _apiService.analyzeImage(imageFile, analysisType: analysisType);
      
      debugPrint('Image analysis result: ${response.message}');
      return response.results;
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      return {
        'faces': [],
        'objects': [],
        'message': 'Error analyzing image: ${e.toString()}'
      };
    }
  }

  // Switch camera (front/back)
  Future<bool> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      debugPrint('Only one camera available');
      return false;
    }

    try {
      final currentCamera = _cameraController!.description;
      final newCameraIndex = currentCamera == _cameras![0] ? 1 : 0;
      
      await _cameraController!.dispose();
      
      _cameraController = CameraController(
        _cameras![newCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      notifyListeners();
      
      debugPrint('Camera switched to: ${_cameras![newCameraIndex].name}');
      return true;
    } catch (e) {
      debugPrint('Error switching camera: $e');
      return false;
    }
  }

  // Start camera preview
  Future<void> startPreview() async {
    if (_cameraController != null && _isInitialized) {
      await _cameraController!.resumePreview();
    }
  }

  // Stop camera preview
  Future<void> stopPreview() async {
    if (_cameraController != null && _isInitialized) {
      await _cameraController!.pausePreview();
    }
  }

  // Start camera stream
  Future<void> startCameraStream(Function(CameraImage) onImage) async {
    if (_cameraController != null && _isInitialized) {
      await _cameraController!.startImageStream(onImage);
    }
  }

  // Stop camera stream
  Future<void> stopCameraStream() async {
    if (_cameraController != null && _isInitialized) {
      await _cameraController!.stopImageStream();
    }
  }

  // Check if camera is available
  Future<bool> isCameraAvailable() async {
    try {
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking camera availability: $e');
      return false;
    }
  }

  // Get camera info
  Map<String, dynamic>? getCameraInfo() {
    if (_cameraController == null) return null;
    
    return {
      'name': _cameraController!.description.name,
      'lensDirection': _cameraController!.description.lensDirection.toString(),
      'sensorOrientation': _cameraController!.description.sensorOrientation,
      'isInitialized': _isInitialized,
      'isCapturing': _isCapturing,
    };
  }

  // Dispose camera resources
  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
