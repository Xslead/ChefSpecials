import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _db;

  ReportService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> submitReport(Report report) async {
    await _db.collection('reports').add(report.toMap());
  }

  Stream<List<Report>> getReportsStream({String? status}) {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final all = snap.docs
          .map((d) => Report.fromMap(d.data(), d.id))
          .toList();
      if (status != null) {
        return all.where((r) => r.status == status).toList();
      }
      return all;
    });
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String reviewedBy,
    String? reviewNote,
  }) async {
    await _db.collection('reports').doc(reportId).update({
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewNote': reviewNote,
      'reviewedAt': DateTime.now().toIso8601String(),
    });
  }
}
