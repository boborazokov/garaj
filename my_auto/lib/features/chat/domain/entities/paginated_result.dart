import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.totalDocs,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final int totalDocs;

  @override
  List<Object?> get props => [items, page, totalPages, hasNextPage, totalDocs];
}
