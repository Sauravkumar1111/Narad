import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../services/api_service_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _ttsRateController = TextEditingController();
  final TextEditingController _ttsVolumeController = TextEditingController();
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _ttsRateController.dispose();
    _ttsVolumeController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final configService = Provider.of<ConfigService>(context, listen: false);
    _apiUrlController.text = configService.apiUrl;
    _ttsRateController.text = configService.ttsRate.toString();
    _ttsVolumeController.text = configService.ttsVolume.toString();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
    });

    try {
      final apiServiceManager = Provider.of<ApiServiceManager>(context, listen: false);
      final isConnected = await apiServiceManager.apiService.testConnection();
      
      if (mounted) {
        if (isConnected) {
          AppHelpers.showSuccessSnackBar(context, 'Connection successful!');
        } else {
          AppHelpers.showErrorSnackBar(context, 'Connection failed. Please check your API URL.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, 'Connection test failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  Future<void> _saveApiUrl() async {
    final configService = Provider.of<ConfigService>(context, listen: false);
    final newUrl = _apiUrlController.text.trim();
    
    if (newUrl.isEmpty) {
      AppHelpers.showErrorSnackBar(context, 'API URL cannot be empty');
      return;
    }

    if (!configService.isValidApiUrl(newUrl)) {
      AppHelpers.showErrorSnackBar(context, 'Invalid API URL format');
      return;
    }

    try {
      await configService.updateApiUrl(newUrl);
      AppHelpers.showSuccessSnackBar(context, 'API URL updated successfully');
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to update API URL: ${e.toString()}');
    }
  }

  Future<void> _saveTtsSettings() async {
    final configService = Provider.of<ConfigService>(context, listen: false);
    
    try {
      final rate = double.tryParse(_ttsRateController.text) ?? 0.5;
      final volume = double.tryParse(_ttsVolumeController.text) ?? 1.0;
      
      if (!configService.isValidTtsRate(rate)) {
        AppHelpers.showErrorSnackBar(context, 'TTS Rate must be between 0.1 and 2.0');
        return;
      }
      
      if (!configService.isValidTtsVolume(volume)) {
        AppHelpers.showErrorSnackBar(context, 'TTS Volume must be between 0.0 and 1.0');
        return;
      }

      await configService.updateTtsRate(rate);
      await configService.updateTtsVolume(volume);
      AppHelpers.showSuccessSnackBar(context, 'TTS settings updated successfully');
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to update TTS settings: ${e.toString()}');
    }
  }

  Future<void> _resetToDefaults() async {
    final configService = Provider.of<ConfigService>(context, listen: false);
    
    try {
      await configService.resetToDefaults();
      _loadCurrentSettings();
      AppHelpers.showSuccessSnackBar(context, 'Settings reset to defaults');
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to reset settings: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: Consumer<ConfigService>(
        builder: (context, configService, child) {
          return ListView(
            padding: const EdgeInsets.all(AppConstants.padding),
            children: [
              // API Configuration Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _apiUrlController,
                        decoration: const InputDecoration(
                          labelText: 'API URL',
                          hintText: 'http://192.168.1.4:8000/api/v1',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isTestingConnection ? null : _testConnection,
                              icon: _isTestingConnection
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.wifi),
                              label: Text(_isTestingConnection ? 'Testing...' : 'Test Connection'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveApiUrl,
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current: ${configService.apiUrl}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Voice Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voice Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Voice Mode'),
                        subtitle: const Text('Enable voice input and output'),
                        value: configService.voiceMode,
                        onChanged: (value) async {
                          await configService.updateVoiceMode(value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Continuous Listening'),
                        subtitle: const Text('Keep listening for wake words'),
                        value: configService.continuousListening,
                        onChanged: (value) async {
                          await configService.updateContinuousListening(value);
                        },
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ttsRateController,
                              decoration: const InputDecoration(
                                labelText: 'TTS Rate',
                                hintText: '0.5',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _ttsVolumeController,
                              decoration: const InputDecoration(
                                labelText: 'TTS Volume',
                                hintText: '1.0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveTtsSettings,
                          icon: const Icon(Icons.save),
                          label: const Text('Save TTS Settings'),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: configService.ttsVoice,
                        decoration: const InputDecoration(
                          labelText: 'TTS Voice',
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.ttsVoices.map((voice) {
                          return DropdownMenuItem(
                            value: voice,
                            child: Text(voice.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            await configService.updateTtsVoice(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Camera Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Camera Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Camera Mode'),
                        subtitle: const Text('Enable camera functionality'),
                        value: configService.cameraMode,
                        onChanged: (value) async {
                          await configService.updateCameraMode(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Language Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Language Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: configService.language,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.supportedLanguages.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            await configService.updateLanguage(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Appearance Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Use dark theme'),
                        value: configService.darkMode,
                        onChanged: (value) async {
                          await configService.updateDarkMode(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset All Settings to Defaults'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
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
