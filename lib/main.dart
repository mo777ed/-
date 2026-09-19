import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/branch_provider.dart';
import 'providers/session_provider.dart';
import 'providers/transfers_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SessionProvider();
  await session.load();
  final branches = BranchProvider();
  await branches.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionProvider>.value(value: session),
        ChangeNotifierProvider<BranchProvider>.value(value: branches),
        ChangeNotifierProvider<TransfersProvider>(
          create: (_) => TransfersProvider()..load(),
        ),
      ],
      child: const AlmegdaaApp(),
    ),
  );
}
