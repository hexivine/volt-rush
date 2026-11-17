/// G3/G7 fixture — race condition: non-atomic check-then-act on a flag.
import 'dart:async';

class BattleProvider {
  bool _isBanking = false;
  final List<String> _ledger = [];

  Future<void> startGame() async {
    // Race: two concurrent calls both pass this check before either sets it
    if (!_isBanking) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      _isBanking = true;
      _ledger.add('banked');
    }
    // _isBanking never reset in some paths -> stuck state
  }

  void reset() {
    _isBanking = false;
    _ledger.clear();
  }
}

/// G3/G7 retry 3: real incremental change (ledger view helper).
extension BattleLedger on BattleProvider {
  List<String> ledgerView() => List.unmodifiable(_ledger);
}
