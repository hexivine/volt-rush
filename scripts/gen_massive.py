lines = []
lines.append("import 'dart:async';\n")
lines.append("import 'package:cloud_firestore/cloud_firestore.dart';\n\n")
lines.append("/// A deliberately massive service to stress-test code review tools.\n")
lines.append("class MassiveService {\n")
lines.append("  final FirebaseFirestore _db = FirebaseFirestore.instance;\n\n")

for i in range(1, 80):
    lines.append(f"  /// Process item {i}\n")
    lines.append(f"  Future<void> processItem{i}(String userId) async {{\n")
    lines.append(f"    final doc = await _db.collection('users').doc(userId).get();\n")
    lines.append(f"    final data = doc.data();\n")
    lines.append(f"    if (data == null) return;\n")
    lines.append(f"    final value = data['field{i}'] as int? ?? 0;\n")
    lines.append(f"    await _db.collection('results').add({{'userId': userId, 'value': value, 'method': 'item{i}', 'ts': DateTime.now().toIso8601String()}});\n")
    lines.append(f"  }}\n\n")

lines.append("}\n")

with open("lib/services/massive_service.dart", "w") as f:
    f.write("".join(lines))

print(f"Generated {len(lines)} lines")
