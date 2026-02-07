import 'package:dartz/dartz.dart';
import '../../domain/entities/lg_connection.dart';
import '../../domain/repositories/lg_repository.dart';
import '../datasources/lg_remote_datasource.dart';

/// Implementation of LG repository
/// Bridges domain layer with data layer
class LGRepositoryImpl implements LGRepository {
  final LGRemoteDataSource remoteDataSource;

  LGRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, bool>> connect(LGConnection connection) async {
    try {
      final result = await remoteDataSource.connect(connection);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> disconnect() async {
    try {
      final result = await remoteDataSource.disconnect();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendKML(String content, String fileName) async {
    try {
      await remoteDataSource.sendKML(content, fileName);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> flyTo(double lat, double lng, double zoom, double tilt, double bearing) async {
    try {
      await remoteDataSource.flyTo(lat, lng, zoom, tilt, bearing);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> sendCommand(String command) async {
    try {
      final result = await remoteDataSource.sendCommand(command);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  bool isConnected() {
    return remoteDataSource.isConnected();
  }

  @override
  Future<Either<String, void>> sendKMLToSlave(int screen, String content) async {
    try {
      await remoteDataSource.sendKMLToSlave(screen, content);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> cleanSlaves() async {
    try {
      await remoteDataSource.cleanSlaves();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  LGConnection? getConnection() {
    return remoteDataSource.getConnection();
  }
}
