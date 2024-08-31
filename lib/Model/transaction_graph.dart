import 'dart:math';

class UserDebt {
  String uid;
  double netAmount;

  UserDebt(this.uid, this.netAmount);
}

class Transaction {
  final String payer;
  final String receiver;
  final double amount;

  Transaction({
    required this.payer,
    required this.receiver,
    required this.amount,
  });
}

List<Transaction> minimizeTransactions(
    Map<String, Map<String, double>> balances) {
  List<UserDebt> debts = [];
  Map<String, double> netAmounts = {};

  // Calculate net amounts for each user
  balances.forEach((user, transactions) {
    transactions.forEach((other, amount) {
      netAmounts[user] = (netAmounts[user] ?? 0) + amount;
      netAmounts[other] = (netAmounts[other] ?? 0) - amount;
    });
  });

  // Convert net amounts to debt objects
  netAmounts.forEach((uid, amount) {
    if (amount != 0) {
      debts.add(UserDebt(uid, amount));
    }
  });

  // Simplify debts
  return simplifyDebts(debts);
}

List<Transaction> simplifyDebts(List<UserDebt> debts) {
  List<Transaction> transactions = [];

  // Simplify debts
  // Sort debts to facilitate matching
  debts.sort((a, b) => a.netAmount.compareTo(b.netAmount));
  int i = 0, j = debts.length - 1;

  while (i < j) {
    double minAmount = min(-debts[i].netAmount, debts[j].netAmount);
    transactions.add(Transaction(
        payer: debts[i].uid, receiver: debts[j].uid, amount: minAmount));

    debts[i].netAmount += minAmount;
    debts[j].netAmount -= minAmount;

    if (debts[i].netAmount == 0) i++;
    if (debts[j].netAmount == 0) j--;
  }

  return transactions;
}
