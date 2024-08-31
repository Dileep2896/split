import 'dart:math';
import 'package:split/Model/members_model.dart';

Map<String, double> calculateNetBalances(List<Member> members) {
  Map<String, double> netBalances = {};
  for (var member in members) {
    netBalances[member.uid] = member.totalReceive - member.totalPay;
  }
  return netBalances;
}

List<Member> minimizeCashFlow(List<Member> members) {
  Map<String, double> netBalances = calculateNetBalances(members);
  List<String> debtors = [];
  List<String> creditors = [];

  netBalances.forEach((uid, amount) {
    if (amount < 0) {
      debtors.add(uid);
    } else if (amount > 0) {
      creditors.add(uid);
    }
  });

  while (debtors.isNotEmpty && creditors.isNotEmpty) {
    String debtor = debtors.last;
    String creditor = creditors.last;
    double amount = min(-netBalances[debtor]!, netBalances[creditor]!);

    // Update pay and receive maps in the member objects
    Member debtorMember = members.firstWhere((m) => m.uid == debtor);
    Member creditorMember = members.firstWhere((m) => m.uid == creditor);

    // Ensure maps are initialized
    debtorMember.pay[creditor] = (debtorMember.pay[creditor] ?? {});
    creditorMember.receive[debtor] = (creditorMember.receive[debtor] ?? {});

    // Update or initialize the transaction amount
    double existingDebt = debtorMember.pay[creditor]['amount'] ?? 0;
    debtorMember.pay[creditor]['amount'] = existingDebt + amount;
    double existingCredit = creditorMember.receive[debtor]['amount'] ?? 0;
    creditorMember.receive[debtor]['amount'] = existingCredit + amount;

    // Update totalPay and totalReceive for both members
    debtorMember.totalPay += amount;
    creditorMember.totalReceive += amount;

    // Adjust balances
    netBalances[debtor] = netBalances[debtor]! + amount;
    netBalances[creditor] = netBalances[creditor]! + amount;

    if (netBalances[debtor] == 0) {
      debtors.removeLast();
    }
    if (netBalances[creditor] == 0) {
      creditors.removeLast();
    }
  }

  return members;
}
