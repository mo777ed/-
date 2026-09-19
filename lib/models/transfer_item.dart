import '../core/utils/fmt.dart';

class TransferItem {
  const TransferItem({
    this.id,
    required this.barcode,
    this.name,
    required this.quantity,
    this.expiryDate,
  });

  final int? id;
  final String barcode;
  final String? name;
  final int quantity;
  final DateTime? expiryDate;

  String get displayName {
    final n = name?.trim();
    return (n == null || n.isEmpty) ? '—' : n;
  }

  String get displayExpiry =>
      expiryDate == null ? '—' : Fmt.date(expiryDate!);

  Map<String, Object?> toMap(int transferId) {
    final n = name?.trim();
    return {
      'transfer_id': transferId,
      'barcode': barcode,
      'name': (n == null || n.isEmpty) ? null : n,
      'quantity': quantity,
      'expiry_date': expiryDate == null ? null : Fmt.iso(expiryDate!),
    };
  }

  factory TransferItem.fromMap(Map<String, Object?> map) => TransferItem(
        id: map['id'] as int?,
        barcode: map['barcode'] as String,
        name: map['name'] as String?,
        quantity: map['quantity'] as int,
        expiryDate: Fmt.tryParseIso(map['expiry_date'] as String?),
      );
}
