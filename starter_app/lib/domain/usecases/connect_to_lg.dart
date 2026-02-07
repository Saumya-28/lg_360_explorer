import 'package:dartz/dartz.dart';
import '../entities/lg_connection.dart';
import '../repositories/lg_repository.dart';

/// Use case for connecting to Liquid Galaxy rig
class ConnectToLG {
  final LGRepository repository;

  ConnectToLG(this.repository);

  /// Executes the connection use case
  /// Returns Either<String, bool> where:
  /// - Left: Error message
  /// - Right: Connection success status
  Future<Either<String, bool>> call(LGConnection connection) async {
    return await repository.connect(connection);
  }
}
