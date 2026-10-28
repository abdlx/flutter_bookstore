import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/promotion.dart';
import 'firestore_codec.dart';

class FirestorePromotionRepository {
  final FirebaseFirestore db;
  FirestorePromotionRepository(this.db);
  CollectionReference<Map<String, dynamic>> get collection =>
      db.collection('promotions');
  Stream<List<Promotion>> watch() => collection.snapshots().map(
    (s) =>
        s.docs
            .map(
              (d) => Promotion(
                code: d.id,
                active: d.data()['active'] == true,
                type: d.data()['type'] as String,
                amount: (d.data()['amount'] as num).toDouble(),
                minimumSubtotal: (d.data()['minimumSubtotal'] as num? ?? 0)
                    .toDouble(),
                expiresAt: d.data()['expiresAt'] == null
                    ? null
                    : readDate(d.data()['expiresAt']),
              ),
            )
            .toList()
          ..sort((a, b) => a.code.compareTo(b.code)),
  );
  Future<void> save(Promotion promotion, {required bool creating}) async {
    promotion.validate();
    final ref = collection.doc(promotion.code);
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (creating && doc.exists) {
        throw StateError('That promotion code already exists.');
      }
      if (!creating && !doc.exists) {
        throw StateError('This promotion was deleted.');
      }
      tx.set(ref, {
        'active': promotion.active,
        'type': promotion.type,
        'amount': promotion.amount,
        'minimumSubtotal': promotion.minimumSubtotal,
        if (promotion.expiresAt != null)
          'expiresAt': Timestamp.fromDate(promotion.expiresAt!),
      });
    });
  }

  Future<void> delete(String code) => collection.doc(code).delete();
}
