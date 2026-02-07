import 'package:dartz/dartz.dart';
import '../entities/lg_connection.dart';

/// Abstract repository interface for Liquid Galaxy operations
/// Following Clean Architecture principles
abstract class LGRepository {
  /// Establishes SSH connection to the Liquid Galaxy rig
  /// Returns Either<String, bool> where:
  /// - Left: Error message
  /// - Right: Connection success status
  Future<Either<String, bool>> connect(LGConnection connection);

  /// Disconnects from the Liquid Galaxy rig
  Future<Either<String, bool>> disconnect();

  /// Sends KML content to the Liquid Galaxy
  /// [content] The KML string to send
  /// [fileName] The name of the file
  Future<Either<String, void>> sendKML(String content, String fileName);

  /// Flies to the specified location
  Future<Either<String, void>> flyTo(double lat, double lng, double zoom, double tilt, double bearing);
  
  /// Sends a raw command to the Liquid Galaxy
  /// [command] The shell command to execute
  Future<Either<String, String>> sendCommand(String command);

  /// Checks if currently connected to the rig
  bool isConnected();

  /// Sends KML content to a specific slave screen
  /// [content] The KML string to send
  /// [screen] The slave screen number
  Future<Either<String, void>> sendKMLToSlave(int screen, String content);

  /// Clears KMLs from all slave screens
  Future<Either<String, void>> cleanSlaves();

  /// Gets the current connection configuration
  LGConnection? getConnection();
}
