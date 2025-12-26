/// Generic paginated response model for API calls
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final bool hasMore;
  final String? nextCursor;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
    this.nextCursor,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['items'] as List?)
            ?.map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PaginatedResponse<T>(
      items: items,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalCount: json['total_count'] as int? ?? items.length,
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: json['next_cursor'] as String?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((e) => toJsonT(e)).toList(),
      'current_page': currentPage,
      'page_size': pageSize,
      'total_count': totalCount,
      'has_more': hasMore,
      'next_cursor': nextCursor,
    };
  }

  /// Create empty paginated response
  factory PaginatedResponse.empty() {
    return PaginatedResponse<T>(
      items: [],
      currentPage: 1,
      pageSize: 20,
      totalCount: 0,
      hasMore: false,
    );
  }

  /// Append new page to existing response
  PaginatedResponse<T> appendPage(PaginatedResponse<T> newPage) {
    return PaginatedResponse<T>(
      items: [...items, ...newPage.items],
      currentPage: newPage.currentPage,
      pageSize: pageSize,
      totalCount: newPage.totalCount,
      hasMore: newPage.hasMore,
      nextCursor: newPage.nextCursor,
    );
  }

  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasMore;

  /// Get total number of pages
  int get totalPages => (totalCount / pageSize).ceil();
}

/// Pagination parameters for API calls
class PaginationParams {
  final int page;
  final int pageSize;
  final String? cursor;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
  });

  /// Get offset for SQL queries
  int get offset => (page - 1) * pageSize;

  /// Get limit for SQL queries
  int get limit => pageSize;

  /// Create params for next page
  PaginationParams nextPage() {
    return PaginationParams(
      page: page + 1,
      pageSize: pageSize,
    );
  }

  /// Create params with cursor
  PaginationParams withCursor(String cursor) {
    return PaginationParams(
      page: page,
      pageSize: pageSize,
      cursor: cursor,
    );
  }
}
