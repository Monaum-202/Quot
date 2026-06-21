import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:invoice_maker/core/services/google_drive_service.dart';
import 'package:invoice_maker/features/company_profile/presentation/screens/company_profile_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_maker/core/constants/hive_box_names.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _googleDriveService = GoogleDriveService();
  bool _isSyncing = false;
  late Box _settingsBox;
  bool _autoBackupEnabled = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box(HiveBoxNames.settings);
    _autoBackupEnabled = _settingsBox.get('auto_backup', defaultValue: false);
  }

  Future<void> _handleBackup() async {
    setState(() => _isSyncing = true);
    
    final signedIn = await _googleDriveService.signIn();
    if (!signedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed. Please check your internet.')),
        );
      }
      setState(() => _isSyncing = false);
      return;
    }

    final success = await _googleDriveService.backupToDrive();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Backup successful!' : 'Backup failed.')),
      );
    }
    setState(() => _isSyncing = false);
  }

  Future<void> _handleRestore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data?'),
        content: const Text('This will overwrite your current data with the latest backup from Drive. You should restart the app after restore.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('RESTORE')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSyncing = true);
    
    final signedIn = await _googleDriveService.signIn();
    if (!signedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed.')),
        );
      }
      setState(() => _isSyncing = false);
      return;
    }

    final success = await _googleDriveService.restoreFromDrive();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Restore successful! Please restart the app.' : 'Restore failed.')),
      );
    }
    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Company Profile'),
            subtitle: const Text('Edit your business details and logo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompanyProfileScreen()),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Backup & Sync',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.blue),
            ),
          ),
          if (_isSyncing)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else ...[
            SwitchListTile(
              secondary: const Icon(Icons.sync_outlined),
              title: const Text('Auto-Backup on Close'),
              subtitle: const Text('Automatically upload data when you exit'),
              value: _autoBackupEnabled,
              onChanged: (v) {
                setState(() => _autoBackupEnabled = v);
                _settingsBox.put('auto_backup', v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Backup to Google Drive'),
              subtitle: const Text('Upload your data to your Google account'),
              onTap: _handleBackup,
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('Restore from Google Drive'),
              subtitle: const Text('Download latest backup from your Drive'),
              onTap: _handleRestore,
            ),
          ],
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const ListTile(
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
