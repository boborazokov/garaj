/// Normalizes `_id` / ObjectId payloads from GraphQL (plain string or `{ \$oid: "..." }`).
String graphqlIdToString(dynamic raw) {
  if (raw == null) return '';
  if (raw is String) return raw.trim();
  if (raw is Map) {
    final m = Map<String, dynamic>.from(raw);
    if (m['\$oid'] != null) {
      return m['\$oid'].toString().trim();
    }
    final nestedId = m['_id'];
    if (nestedId != null) return graphqlIdToString(nestedId);
  }
  return raw.toString().trim();
}

bool graphqlIdsEqual(String? a, String? b) {
  if (a == null || b == null) return false;
  return a.trim().toLowerCase() == b.trim().toLowerCase();
}
