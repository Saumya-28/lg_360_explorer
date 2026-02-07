import 'package:logger/logger.dart';
import '../../data/datasources/lg_remote_datasource.dart';
import '../../domain/entities/lg_connection.dart';

/// Core service for Liquid Galaxy operations
/// Provides a high-level API for LG interactions
class LGService {
  final LGRemoteDataSource _dataSource;
  final Logger _logger = Logger();

  LGService(this._dataSource);

  /// Connects to the Liquid Galaxy rig
  Future<bool> connect({
    required String host,
    required String username,
    required String password,
    int port = 22,
    int screenCount = 5,
  }) async {
    try {
      final connection = LGConnection(
        host: host,
        port: port,
        username: username,
        password: password,
        screenCount: screenCount,
      );

      final connected = await _dataSource.connect(connection);
      if (connected) {
        await sendLogoToLeftScreen(_getLogoKML());
      }
      return connected;
    } catch (e) {
      _logger.e('Connection failed: $e');
      rethrow;
    }
  }

  /// Authenticates with the Liquid Galaxy rig
  /// This is handled automatically during connect()
  Future<bool> authenticate(String username, String password) async {
    // Authentication is handled in the connect method
    // This method exists for API compatibility
    return isConnected();
  }

  /// Sends KML content to the Liquid Galaxy
  Future<void> sendKML(String kmlContent, {String? fileName}) async {
    try {
      if (!isConnected()) {
        throw Exception('Not connected to Liquid Galaxy');
      }

      if (kmlContent.isEmpty) {
        throw Exception('KML content cannot be empty');
      }

      // Validate KML has proper header
      if (!kmlContent.contains('<?xml') || !kmlContent.contains('<kml')) {
        throw Exception('Invalid KML: Missing XML or KML headers');
      }

      final name = fileName ?? 'lg_kml_${DateTime.now().millisecondsSinceEpoch}.kml';
      await _dataSource.sendKML(kmlContent, name);
    } catch (e) {
      _logger.e('Failed to send KML: $e');
      rethrow;
    }
  }

  /// Sends KML to a specific slave screen
  Future<void> sendKMLToSlave(int screen, String kmlContent) async {
    try {
      if (!isConnected()) throw Exception('Not connected to Liquid Galaxy');
      await _dataSource.sendKMLToSlave(screen, kmlContent);
    } catch (e) {
      _logger.e('Failed to send to slave $screen: $e');
      rethrow;
    }
  }

  /// Clears KMLs from all slave screens
  Future<void> cleanSlaves() async {
    try {
      if (!isConnected()) throw Exception('Not connected to Liquid Galaxy');
      await _dataSource.cleanSlaves();
    } catch (e) {
      _logger.e('Failed to clean slaves: $e');
      rethrow;
    }
  }

  int get screenCount {
    return _dataSource.getConnection()?.screenCount ?? 5;
  }

  int get leftMostScreen {
    final screens = screenCount;
    if (screens == 1) return 1;
    return (screens / 2).floor() + 2;
  }

  int get rightMostScreen {
    final screens = screenCount;
    if (screens == 1) return 1;
    return (screens / 2).floor() + 1;
  }

  Future<void> sendLogoToLeftScreen(String kmlContent) async {
    await sendKMLToSlave(leftMostScreen, kmlContent);
  }

  Future<void> sendBalloonToRightScreen(String kmlContent) async {
    await sendKMLToSlave(rightMostScreen, kmlContent);
  }

  /// Flies to the specified location
  Future<void> flyTo(double lat, double lng, double zoom, double tilt, double bearing) async {
    try {
      if (!isConnected()) {
        throw Exception('Not connected to Liquid Galaxy');
      }
      await _dataSource.flyTo(lat, lng, zoom, tilt, bearing);
    } catch (e) {
      _logger.e('Failed to fly to location: $e');
      rethrow;
    }
  }

  Future<void> startTour(String tourName) async {
    try {
      if (!isConnected()) {
        throw Exception('Not connected to Liquid Galaxy');
      }
      await _dataSource.startTour(tourName);
    } catch (e) {
      _logger.e('Failed to start tour: $e');
      rethrow;
    }
  }

  Future<void> stopTour() async {
    try {
      if (!isConnected()) {
        throw Exception('Not connected to Liquid Galaxy');
      }
      await _dataSource.stopTour();
    } catch (e) {
      _logger.e('Failed to stop tour: $e');
      rethrow;
    }
  }

  /// Sends a raw command to the Liquid Galaxy
  Future<String> sendCommand(String command) async {
    try {
      if (!isConnected()) {
        throw Exception('Not connected to Liquid Galaxy');
      }

      return await _dataSource.sendCommand(command);
    } catch (e) {
      _logger.e('Failed to send command: $e');
      rethrow;
    }
  }

  // ... (disconnect, isConnected, getConnection remain same)
  // But we need to update clearKML as it uses sendKML

  /// Disconnects from the Liquid Galaxy
  Future<bool> disconnect() async {
    try {
      return await _dataSource.disconnect();
    } catch (e) {
      _logger.e('Disconnect failed: $e');
      rethrow;
    }
  }

  /// Checks if connected to the Liquid Galaxy
  bool isConnected() {
    return _dataSource.isConnected();
  }

  /// Gets the current connection configuration
  LGConnection? getConnection() {
    return _dataSource.getConnection();
  }

  /// Clears Google Earth visualization
  Future<void> clearKML() async {
    const clearKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
  </Document>
</kml>''';

    // Clear Master
    await sendKML(clearKml, fileName: 'clear_kml.kml');
    // Clear Slaves
    await cleanSlaves();
  }

  /// Reboots the Liquid Galaxy rig
  Future<String> rebootLG() async {
    return await sendCommand('reboot');
  }

  /// Shuts down the Liquid Galaxy rig
  Future<String> shutdownLG() async {
    return await sendCommand('poweroff');
  }

  String _getLogoKML() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>Liquid Galaxy Logo</name>
    <ScreenOverlay>
      <name>Logo</name>
      <Icon>
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="0.3" y="0" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>''';
  }
}
