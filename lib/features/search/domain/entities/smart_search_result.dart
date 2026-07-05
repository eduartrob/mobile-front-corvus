class SmartSearchResult {
  final String detectedSubject;
  final String summary;
  final List<String> links;

  SmartSearchResult({
    required this.detectedSubject,
    required this.summary,
    required this.links,
  });

  factory SmartSearchResult.fromJson(Map<String, dynamic> json) {
    return SmartSearchResult(
      detectedSubject: json['detected_subject'] ?? 'Materia Desconocida',
      summary: json['summary'] ?? '',
      links: List<String>.from(json['links'] ?? []),
    );
  }
}
