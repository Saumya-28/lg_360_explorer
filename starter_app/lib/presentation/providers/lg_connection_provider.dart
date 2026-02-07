import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/lg_remote_datasource.dart';
import '../../data/repositories/lg_repository_impl.dart';
import '../../domain/entities/lg_connection.dart';
import '../../domain/repositories/lg_repository.dart';
import '../../domain/usecases/connect_to_lg.dart';
import '../../domain/usecases/send_kml_to_lg.dart';
import '../../core/services/lg_service.dart';

// Data Source Provider
final lgRemoteDataSourceProvider = Provider<LGRemoteDataSource>((ref) {
  return LGRemoteDataSource();
});

// Repository Provider
final lgRepositoryProvider = Provider<LGRepository>((ref) {
  final dataSource = ref.watch(lgRemoteDataSourceProvider);
  return LGRepositoryImpl(remoteDataSource: dataSource);
});

// Use Case Providers
final connectToLGProvider = Provider<ConnectToLG>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return ConnectToLG(repository);
});

final sendKMLToLGProvider = Provider<SendKMLToLG>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return SendKMLToLG(repository);
});

// Service Provider
final lgServiceProvider = Provider<LGService>((ref) {
  final dataSource = ref.watch(lgRemoteDataSourceProvider);
  return LGService(dataSource);
});

// Connection Configuration State
class LGConnectionState {
  final LGConnection? connection;
  final bool isConnected;
  final String? errorMessage;
  final bool isLoading;

  const LGConnectionState({
    this.connection,
    this.isConnected = false,
    this.errorMessage,
    this.isLoading = false,
  });

  LGConnectionState copyWith({
    LGConnection? connection,
    bool? isConnected,
    String? errorMessage,
    bool? isLoading,
  }) {
    return LGConnectionState(
      connection: connection ?? this.connection,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Connection State Notifier
class LGConnectionNotifier extends StateNotifier<LGConnectionState> {
  final ConnectToLG connectUseCase;
  final LGRepository repository;

  LGConnectionNotifier({
    required this.connectUseCase,
    required this.repository,
  }) : super(const LGConnectionState());

  Future<void> connect(LGConnection connection) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await connectUseCase(connection);

    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          isConnected: false,
          errorMessage: error,
        );
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          isConnected: true,
          connection: connection,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> disconnect() async {
    state = state.copyWith(isLoading: true);

    final result = await repository.disconnect();

    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error,
        );
      },
      (success) {
        state = const LGConnectionState();
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Connection State Provider
final lgConnectionProvider =
    StateNotifierProvider<LGConnectionNotifier, LGConnectionState>((ref) {
  final connectUseCase = ref.watch(connectToLGProvider);
  final repository = ref.watch(lgRepositoryProvider);

  return LGConnectionNotifier(
    connectUseCase: connectUseCase,
    repository: repository,
  );
});
