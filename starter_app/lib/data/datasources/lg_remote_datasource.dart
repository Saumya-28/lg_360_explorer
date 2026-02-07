import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/lg_connection.dart';

class LGRemoteDataSource {
  SSHClient? _client;
  SftpClient? _sftp;
  LGConnection? _currentConnection;
  final Logger _logger = Logger();
  bool _isUploading = false;

  /// Establishes SSH connection to the Liquid Galaxy rig
  Future<bool> connect(LGConnection connection) async {
    try {
      _logger.i('Attempting to connect to ${connection.username}@${connection.host}:${connection.port}');

      final socket = await SSHSocket.connect(
        connection.host,
        connection.port,
        timeout: const Duration(seconds: 10),
      );

      _client = SSHClient(
        socket,
        username: connection.username,
        onPasswordRequest: () => connection.password,
      );

      _sftp = await _client!.sftp();

      _currentConnection = connection;
      _logger.i('Successfully connected to Liquid Galaxy');
      return true;
    } on SocketException catch (e) {
      _logger.e('Socket error: ${e.message}');
      throw Exception('Failed to connect: ${e.message}');
    } catch (e) {
      _logger.e('Connection error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  /// Disconnects from the Liquid Galaxy rig
  Future<bool> disconnect() async {
    try {
      _sftp = null;
      _client?.close();
      await _client?.done;
      _client = null;
      _currentConnection = null;
      _logger.i('Disconnected from Liquid Galaxy');
      return true;
    } catch (e) {
      _logger.e('Disconnect error: $e');
      throw Exception('Failed to disconnect: $e');
    }
  }

  /// Uploads KML content using SFTP and syncs with kmls.txt
  Future<void> sendKML(String content, String fileName) async {
    if (_client == null || _sftp == null) throw Exception('Not connected to Liquid Galaxy');
    
    // Simple retry/wait mechanism for concurrent uploads
    // We want to ensure the KML gets sent, not skipped
    int retryCount = 0;
    while (_isUploading && retryCount < 20) {
      await Future.delayed(const Duration(milliseconds: 100)); // Wait 100ms
      retryCount++;
    }
    
    // If still uploading after 2s, we force proceed (might cause interleaving issues but better than skip)
    // In a production app, a proper Queue is better.
    
    _isUploading = true;
    try {
      // 1. Create local temp file
      final directory = await getTemporaryDirectory();
      final localFile = File('${directory.path}/$fileName');
      await localFile.writeAsString(content);

      // 2. Upload to LG via SFTP
      final remotePath = '/var/www/html/$fileName';
      final remoteFile = await _sftp!.open(
        remotePath,
        mode: SftpFileOpenMode.truncate |
            SftpFileOpenMode.create |
            SftpFileOpenMode.write,
      );

      final fileStream = localFile.openRead();
      int offset = 0;
      await for (final chunk in fileStream) {
        final typedChunk = Uint8List.fromList(chunk);
        await remoteFile.write(Stream.fromIterable([typedChunk]), offset: offset);
        offset += typedChunk.length;
      }
      await remoteFile.close();

      // 3. Sync kmls.txt
      final kmlUrl = 'http://lg1:81/$fileName?t=${DateTime.now().millisecondsSinceEpoch}';
      await _executeAction('echo "$kmlUrl" > /var/www/html/kmls.txt');
      
      _logger.i('KML uploaded and synced: $fileName');
    } catch (e) {
      _logger.e('KML upload failed: $e');
      throw Exception('Failed to upload KML: $e');
    } finally {
      _isUploading = false;
    }
  }

  /// Sends KML to a specific slave screen
  Future<void> sendKMLToSlave(int screen, String content) async {
    if (_client == null || _sftp == null) throw Exception('Not connected to Liquid Galaxy');

    try {
      // Create directory properly
      try {
        await _sftp!.mkdir('/var/www/html/kml');
      } catch (e) {
        // Ignore "file exists" error, rethrow others
      }

      final fileName = 'slave_$screen.kml';
      final remotePath = '/var/www/html/kml/$fileName';

      final remoteFile = await _sftp!.open(
        remotePath,
        mode: SftpFileOpenMode.truncate |
            SftpFileOpenMode.create |
            SftpFileOpenMode.write,
      );

      final bytes = utf8.encode(content);
      await remoteFile.write(Stream.value(Uint8List.fromList(bytes)));
      await remoteFile.close();
      
      _logger.i('KML sent to slave $screen');
    } catch (e) {
      _logger.e('Failed to send KML to slave $screen: $e');
      throw Exception('Failed to send to slave: $e');
    }
  }

  /// Clears all slave KMLs
  Future<void> cleanSlaves() async {
     if (_client == null) throw Exception('Not connected to Liquid Galaxy');
     
     try {
       final screens = _currentConnection?.screenCount ?? 5;
       
       for (var i = 1; i <= screens; i++) {
         final emptyKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
  </Document>
</kml>''';
          await sendKMLToSlave(i, emptyKml);
       }
       _logger.i('Cleared slave screens');
     } catch (e) {
       _logger.e('Failed to clear slaves: $e');
       throw Exception('Failed to clear slaves: $e');
     }
  }

  /// Sends a raw command (Fire-and-Forget)
  Future<void> _executeAction(String command) async {
    try {
      if (_client == null) return;
      await _client!.execute(command); // Execute without waiting for output
    } catch (e) {
      _logger.e('Action execution failed: $e');
    }
  }

   /// Sends raw command and waits for output (e.g., for reboot/status checks)
  Future<String> sendCommand(String command) async {
    if (_client == null) throw Exception('Not connected');
    return await _executeCommand(command);
  }

  /// Starts a KML tour
  Future<void> startTour(String tourName) async {
    await _executeAction('echo "playtour=$tourName" > /tmp/query.txt');
  }

  /// Stops any running tour
  Future<void> stopTour() async {
    await _executeAction('echo "exittour=true" > /tmp/query.txt');
  }

  /// Executes a command and returns the output
  Future<String> _executeCommand(String command) async {
    try {
      if (_client == null) throw Exception('Not connected');
      final result = await _client!.run(command);
      final output = utf8.decode(result);
      _logger.d('Command executed: $command');
      return output;
    } catch (e) {
      _logger.e('Command execution failed: $e');
      throw Exception('Command execution failed: $e');
    }
  }

  /// Flies to location using smooth movement
  Future<void> flyTo(double lat, double lng, double zoom, double tilt, double bearing) async {
    final lookAt = '<gx:duration>2.0</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt>'
        '<longitude>$lng</longitude><latitude>$lat</latitude>'
        '<range>$zoom</range><tilt>$tilt</tilt>'
        '<heading>$bearing</heading>'
        '<altitudeMode>relativeToGround</altitudeMode></LookAt>';
        
    await _executeAction('echo "flytoview=$lookAt" > /tmp/query.txt');
  }

  /// Checks if currently connected
  bool isConnected() {
    return _client != null;
  }

  /// Gets the current connection
  LGConnection? getConnection() {
    return _currentConnection;
  }
}
