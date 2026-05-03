enum SearchResultType { user, project, task, group }

class SearchResultEntity {
  final String id;
  final String title;
  final String? subtitle;
  final String? photoURL;
  final SearchResultType type;
  final Map<String, dynamic> rawData;

  SearchResultEntity({
    required this.id,
    required this.title,
    this.subtitle,
    this.photoURL,
    required this.type,
    required this.rawData,
  });
}
