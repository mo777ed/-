import 'package:flutter/foundation.dart';

import '../models/branch.dart';
import '../repositories/branch_repository.dart';

class BranchProvider extends ChangeNotifier {
  BranchProvider({BranchRepository? repository})
      : _repo = repository ?? BranchRepository();

  final BranchRepository _repo;

  List<Branch> _branches = const <Branch>[];
  List<Branch> get branches => _branches;
  List<String> get names => _branches.map((b) => b.name).toList();

  Future<void> load() async {
    _branches = await _repo.getAll();
    notifyListeners();
  }

  bool _exists(String name, {int? exceptId}) => _branches.any(
      (b) => b.name.trim() == name.trim() && (exceptId == null || b.id != exceptId));

  /// يعيد false إذا كان الاسم مكررًا.
  Future<bool> add(String name) async {
    final clean = name.trim();
    if (clean.isEmpty || _exists(clean)) return false;
    await _repo.add(clean);
    await load();
    return true;
  }

  Future<bool> rename(int id, String name) async {
    final clean = name.trim();
    if (clean.isEmpty || _exists(clean, exceptId: id)) return false;
    await _repo.rename(id, clean);
    await load();
    return true;
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await load();
  }
}
