class ReframeResponse {
  final List<String> suggestions;
  final String tag;

  ReframeResponse({required this.suggestions, required this.tag});

  factory ReframeResponse.fromJson(Map<String, dynamic> json) {
    return ReframeResponse(
      suggestions: List<String>.from(json['suggestions']),
      tag: json['tag'],
    );
  }
} 