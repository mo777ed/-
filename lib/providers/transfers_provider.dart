import 'package:flutter/foundation.dart';

import '../models/transfer.dart';
import '../repositories/transfer_repository.dart';

class TransfersProvider extends ChangeNotifier {
  TransfersProvider({TransferRepository? repository})
      : _repo = repository ?? TransferRepository();

  final TransferRepository _repo;

  List<Transfer> _transfers = const <Transfer>[];
  List<Transfer> get transfers => _transfers;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _transfers = await _repo.getAll();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// يحفظ التحويل ويعيد معرّفه.
  Future<int> save(Transfer transfer) async {
    final id = await _repo.insert(transfer);
    await load();
    return id;
  }

  Future<Transfer?> getById(int id) => _repo.getById(id);
}
