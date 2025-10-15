import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class NewFeaturesScreen extends StatefulWidget {
  const NewFeaturesScreen({super.key});

  @override
  State<NewFeaturesScreen> createState() => _NewFeaturesScreenState();
}

class _NewFeaturesScreenState extends State<NewFeaturesScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendCommand(String command) async {
    if (command.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.sendChatMessage(command);
      
      AppHelpers.showSuccessSnackBar(context, response.response);
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to execute command: ${e.toString()}');
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
        title: const Text('New Features'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Jarvis New Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try out the latest features added to Jarvis',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Google Search
            _buildFeatureCard(
              icon: Icons.search,
              title: 'Google Search',
              description: 'Search Google for current information',
              color: Colors.blue,
              examples: [
                'Search Google for artificial intelligence trends',
                'Google search machine learning tutorials',
                'Search for Python programming best practices'
              ],
            ),

            // Note Management
            _buildFeatureCard(
              icon: Icons.note_add,
              title: 'Note Management',
              description: 'Create, search, and manage your notes',
              color: Colors.green,
              examples: [
                'Create a note titled "Meeting Notes" with content "Discussed project timeline"',
                'Search my notes for "meeting"',
                'Create a note titled "Ideas" with tags "ideas, brainstorming"'
              ],
            ),

            // Google Meet
            _buildFeatureCard(
              icon: Icons.video_call,
              title: 'Google Meet',
              description: 'Schedule Google Meet meetings',
              color: Colors.purple,
              examples: [
                'Schedule a meeting titled "Team Standup" for 30 minutes',
                'Create Google Meet for "Project Review" with attendees john@example.com',
                'Schedule a meeting titled "Client Call" for 60 minutes'
              ],
            ),

            // Location Services
            _buildFeatureCard(
              icon: Icons.location_on,
              title: 'Location Services',
              description: 'Find restaurants, hotels, and get directions',
              color: Colors.orange,
              examples: [
                'Find restaurants near Times Square',
                'Find hotels in Paris',
                'Get directions from Central Park to Brooklyn Bridge'
              ],
            ),

            // Travel Services
            _buildFeatureCard(
              icon: Icons.flight,
              title: 'Travel Services',
              description: 'Search flights, hotels, and get travel recommendations',
              color: Colors.teal,
              examples: [
                'Search flights from NYC to London on 2024-12-25',
                'Find hotels in Tokyo from 2024-12-20 to 2024-12-25',
                'Get travel recommendations for Paris'
              ],
            ),

            // Communication
            _buildFeatureCard(
              icon: Icons.phone,
              title: 'Communication',
              description: 'Make calls, send messages, and open messaging apps',
              color: Colors.red,
              examples: [
                'Call +1234567890',
                'Send SMS to +1234567890 with message "Running late"',
                'Open WhatsApp for +1234567890'
              ],
            ),

            const SizedBox(height: 24),

            // Custom Command Input
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Try Custom Command',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a command...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              final command = _textController.text.trim();
                              if (command.isNotEmpty) {
                                _sendCommand(command);
                                _textController.clear();
                              }
                            },
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Executing...'),
                              ],
                            )
                          : const Text('Execute Command'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionButton('Search Google', Icons.search, Colors.blue),
                _buildQuickActionButton('Create Note', Icons.note_add, Colors.green),
                _buildQuickActionButton('Schedule Meeting', Icons.video_call, Colors.purple),
                _buildQuickActionButton('Find Restaurants', Icons.restaurant, Colors.orange),
                _buildQuickActionButton('Search Flights', Icons.flight, Colors.teal),
                _buildQuickActionButton('Make Call', Icons.phone, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<String> examples,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppConstants.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Examples:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.grey)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _sendCommand(example),
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        // Generate a sample command based on the action
        String command = '';
        switch (title) {
          case 'Search Google':
            command = 'Search Google for artificial intelligence trends';
            break;
          case 'Create Note':
            command = 'Create a note titled "Quick Note" with content "This is a quick note"';
            break;
          case 'Schedule Meeting':
            command = 'Schedule a meeting titled "Quick Meeting" for 30 minutes';
            break;
          case 'Find Restaurants':
            command = 'Find restaurants near Times Square';
            break;
          case 'Search Flights':
            command = 'Search flights from NYC to London on 2024-12-25';
            break;
          case 'Make Call':
            command = 'Call +1234567890';
            break;
        }
        _sendCommand(command);
      },
      icon: Icon(icon, size: 16),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }
}
