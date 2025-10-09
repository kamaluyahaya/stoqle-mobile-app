// Suggestion params model — immutable + const + value equality
class SuggestionParams {
  final int limit;
  final int offset;
  final String q;

  const SuggestionParams({this.limit = 20, this.offset = 0, this.q = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionParams &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset &&
          q == other.q;

  @override
  int get hashCode => Object.hash(limit, offset, q);
}
