import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopos/src/config/config_service.dart';

class AdminControlPage extends StatefulWidget {
  static const routeName = 'admin-control';
  const AdminControlPage({Key? key}) : super(key: key);

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  String? _currentBaseUrl;
  String? _currentExpiryDate;
  bool _isLoading = true;
  String _configSourceUrl = ConfigService.getConfigSourceUrl();

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() {
      _isLoading = true;
    });

    // Get both the currently cached URL and expiry date
    final currentUrl = await ConfigService.getCurrentBaseUrl();
    final currentExpiry = await ConfigService.getCurrentExpiryDate();
    print('===========current expiry in line 33 $currentExpiry');

    setState(() {
      _currentBaseUrl = currentUrl;
      _currentExpiryDate = currentExpiry;
      _isLoading = false;
    });
  }

  Future<void> _refreshConfig() async {
    // This will clear the cache and force a fresh fetch from GitHub
    await ConfigService.clearCachedConfig();
    // Reload the current config display
    await _loadCurrentConfig();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Local cache cleared. App will fetch new config on next restart or API call.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("API Configuration"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshConfig,
              tooltip: 'Clear cache and force refresh on next app start',
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                title: 'Current API Server',
                content: _currentBaseUrl ?? 'Not set (Will use fallback on next call)',
                icon: Icons.api,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'AWS Free Tier Expiry Date',
                content: _currentExpiryDate ?? 'Not specified in config',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Configuration Source',
                content: _configSourceUrl,
                icon: Icons.cloud_download,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Note: The app will use the URL above for all API calls. '
                      'To change it, update the config.json file on GitHub. '
                      'Use the refresh button to clear the local cache and force the app to fetch the new configuration on its next restart.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              content,
              style: const TextStyle(fontFamily: 'Monospace', fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}