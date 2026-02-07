import 'package:dartz/dartz.dart';
import '../repositories/lg_repository.dart';

/// Use case for sending KML content to Liquid Galaxy
class SendKMLToLG {
  final LGRepository repository;

  SendKMLToLG(this.repository);

  /// Executes the send KML use case
  /// [content] The KML string to send to the rig
  /// [fileName] Optional filename for the KML file
  /// Returns Either<String, void> where:
  /// - Left: Error message
  /// - Right: Send success status
  Future<Either<String, void>> call(String content, {String? fileName}) async {
    if (!repository.isConnected()) {
      return const Left('Not connected to Liquid Galaxy');
    }

    if (content.isEmpty) {
      return const Left('KML content cannot be empty');
    }

    final name = fileName ?? 'lg_kml_${DateTime.now().millisecondsSinceEpoch}.kml';
    return await repository.sendKML(content, name);
  }
}
