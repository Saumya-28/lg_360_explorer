import '../../domain/entities/lg_connection.dart';

/// Data model for LG connection that extends the domain entity
/// Adds JSON serialization capabilities
class LGConnectionModel extends LGConnection {
  const LGConnectionModel({
    required super.host,
    required super.port,
    required super.username,
    required super.password,
    super.screenCount,
  });

  /// Creates a model from JSON
  factory LGConnectionModel.fromJson(Map<String, dynamic> json) {
    return LGConnectionModel(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
      screenCount: json['screenCount'] as int? ?? 5,
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'screenCount': screenCount,
    };
  }

  /// Creates a model from a domain entity
  factory LGConnectionModel.fromEntity(LGConnection entity) {
    return LGConnectionModel(
      host: entity.host,
      port: entity.port,
      username: entity.username,
      password: entity.password,
      screenCount: entity.screenCount,
    );
  }
}
