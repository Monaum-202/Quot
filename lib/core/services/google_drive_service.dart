import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';
import '../constants/hive_box_names.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (error) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final GoogleSignInAccount? googleUser = _currentUser ?? await _googleSignIn.signInSilently();
    if (googleUser == null) return null;

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = _GoogleAuthClient(authHeaders);
    return drive.DriveApi(authenticateClient);
  }

  Future<bool> backupToDrive() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      
      // We'll backup all .hive files
      final hiveFiles = Directory(appDir.path)
          .listSync()
          .where((file) => file.path.endsWith('.hive'))
          .toList();

      if (hiveFiles.isEmpty) return false;

      // Create a unique folder for the backup based on current date
      final folderName = "InvoiceMaker_Backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}";
      
      final driveFolder = drive.File()
        ..name = folderName
        ..mimeType = "application/vnd.google-apps.folder";

      final createdFolder = await driveApi.files.create(driveFolder);
      final folderId = createdFolder.id;

      for (var file in hiveFiles) {
        final driveFile = drive.File()
          ..name = p.basename(file.path)
          ..parents = [folderId!];

        final localFile = File(file.path);
        final media = drive.Media(localFile.openRead(), localFile.lengthSync());
        
        await driveApi.files.create(driveFile, uploadMedia: media);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restoreFromDrive() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      // Find the latest backup folder
      final query = "mimeType = 'application/vnd.google-apps.folder' and name contains 'InvoiceMaker_Backup_'";
      final folderList = await driveApi.files.list(q: query, orderBy: "createdTime desc", pageSize: 1);

      if (folderList.files == null || folderList.files!.isEmpty) return false;

      final latestFolderId = folderList.files!.first.id;
      
      // List files in that folder
      final fileList = await driveApi.files.list(q: "'$latestFolderId' in parents");

      if (fileList.files == null || fileList.files!.isEmpty) return false;

      final appDir = await getApplicationDocumentsDirectory();

      // Close all boxes before overwriting files
      await Hive.close();

      for (var driveFile in fileList.files!) {
        final drive.Media response = await driveApi.files.get(
          driveFile.id!,
          downloadOptions: drive.DownloadOptions.metadata,
        ) as drive.Media;

        final localFile = File(p.join(appDir.path, driveFile.name));
        final List<int> dataStore = [];
        await response.stream.listen((data) => dataStore.addAll(data)).asFuture();
        await localFile.writeAsBytes(dataStore);
      }

      // Re-initialize Hive (caller should probably restart app or reload data)
      return true;
    } catch (e) {
      return false;
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
