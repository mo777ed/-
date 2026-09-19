import '../core/constants/app_constants.dart';
import '../core/utils/fmt.dart';
import 'transfer_item.dart';

class Transfer {
  Transfer({
    this.id,
    required this.fromBranch,
    required this.toBranch,
    required this.date,
    required this.employeeName,
    required this.employeePhone,
    required this.createdAt,
    this.items = const <TransferItem>[],
    int? itemsCount,
  }) : itemsCount = itemsCount ?? items.length;

  final int? id;
  final String fromBranch;
  final String toBranch;
  final DateTime date;
  final String employeeName;
  final String employeePhone;
  final DateTime createdAt;
  final List<TransferItem> items;

  /// عدد الأصناف (يُستخدم في قائمة التحويلات دون تحميل الأصناف).
  final int itemsCount;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// رقم التحويل الفريد، مثال: MQ-260918-0007
  String get number {
    final seq = (id ?? 0).toString().padLeft(4, '0');
    return '${AppConstants.transferPrefix}-${Fmt.compact(date)}-$seq';
  }

  Map<String, Object?> toMap() => {
        'from_branch': fromBranch,
        'to_branch': toBranch,
        'transfer_date': Fmt.iso(date),
        'employee_name': employeeName,
        'employee_phone': employeePhone,
        'created_at': createdAt.toIso8601String(),
      };

  factory Transfer.fromMap(
    Map<String, Object?> map, {
    List<TransferItem> items = const <TransferItem>[],
  }) =>
      Transfer(
        id: map['id'] as int?,
        fromBranch: map['from_branch'] as String,
        toBranch: map['to_branch'] as String,
        date: DateTime.parse(map['transfer_date'] as String),
        employeeName: map['employee_name'] as String,
        employeePhone: map['employee_phone'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        items: items,
        itemsCount: map['items_count'] as int?,
      );
}
