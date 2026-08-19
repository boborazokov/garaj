import 'dart:io';
import 'package:equatable/equatable.dart';

enum PhotoUploadStatus { pending, uploading, done, failed }

class ProductPhoto extends Equatable {
  const ProductPhoto({
    required this.id,
    this.file,
    this.networkUrl,
    this.status = PhotoUploadStatus.pending,
    this.progress = 0,
  });

  final String id;
  final File? file;
  final String? networkUrl;
  final PhotoUploadStatus status;
  final double progress;

  bool get isLocal => file != null;
  bool get isNetwork => networkUrl != null && networkUrl!.isNotEmpty;

  ProductPhoto copyWith({
    PhotoUploadStatus? status,
    double? progress,
    String? networkUrl,
  }) {
    return ProductPhoto(
      id: id,
      file: file,
      networkUrl: networkUrl ?? this.networkUrl,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [id, file?.path, networkUrl, status, progress];
}
