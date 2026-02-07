import 'package:equatable/equatable.dart';

/// Entity representing Liquid Galaxy connection configuration
class LGConnection extends Equatable {
  final String host;
  final int port;
  final String username;
  final String password;
  final int screenCount;

  const LGConnection({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.screenCount = 5,
  });

  @override
  List<Object?> get props => [host, port, username, password, screenCount];

  LGConnection copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    int? screenCount,
  }) {
    return LGConnection(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      screenCount: screenCount ?? this.screenCount,
    );
  }
}
