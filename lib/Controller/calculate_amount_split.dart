import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Model/members_model.dart';

List<Member> updateMemberAmounts(BuildContext context, List<Member> members,
    double splitAmount, List<bool> checkValues) {
  List<Member> updatedMembers =
      members.map((member) => Member.copy(member)).toList();
  final String currentUserId = Provider.of<User>(context, listen: false).uid;

  for (int i = 0; i < updatedMembers.length; i++) {
    for (int j = 0; j < updatedMembers.length; j++) {
      if (i == j) continue;
      _updateTransactionBetween(updatedMembers[i], updatedMembers[j],
          currentUserId, splitAmount, checkValues[j]);
    }
  }

  for (var member in updatedMembers) {
    _calTotalPayReceive(member);
  }

  return updatedMembers;
}

void _updateTransactionBetween(Member member, Member otherMember,
    String currentUserId, double splitAmount, bool isChecked) {
  double currentReceive =
      member.receive[otherMember.uid]['amount']?.toDouble() ?? 0.0;
  double currentPay = member.pay[otherMember.uid]['amount']?.toDouble() ?? 0.0;
  double newAmount = isChecked ? splitAmount : 0.0;

  if (member.uid == currentUserId) {
    double netDifference = newAmount - currentPay;
    _adjustAmounts(member, otherMember, netDifference, currentReceive);
  } else if (otherMember.uid == currentUserId && isChecked) {
    double netDifference = splitAmount - currentReceive;
    _adjustAmounts(member, otherMember, -netDifference, currentPay);
  }
}

void _calTotalPayReceive(Member member) {
  double totalPay = 0;
  double totalReceive = 0;
  member.pay.forEach((key, value) {
    totalPay += value['amount'];
  });
  member.receive.forEach((key, value) {
    totalReceive += value['amount'];
  });

  member.totalPay = totalPay;
  member.totalReceive = totalReceive;
}

void updateEachMemberAmount(Member currUser, Member member, double amount) {
  // Calculate the net differences for currUser and member
  double netDifferenceForCurrUser =
      amount - (currUser.pay[member.uid]["amount"]?.toDouble() ?? 0.0);
  double netDifferenceForMember =
      amount - (member.receive[currUser.uid]["amount"]?.toDouble() ?? 0.0);

  // Update currUser's receive amount and member's pay amount
  _adjustAmounts(
      currUser,
      member,
      netDifferenceForCurrUser, // This will adjust currUser's 'receive' relative to the member's 'pay'
      currUser.receive[member.uid]["amount"]?.toDouble() ?? 0.0);

  // Update member's pay amount and currUser's receive amount
  _adjustAmounts(
      member,
      currUser,
      -netDifferenceForMember, // This will adjust member's 'pay' relative to currUser's 'receive'
      member.pay[currUser.uid]["amount"]?.toDouble() ?? 0.0);

  // Recalculate the total pay and receive for both members
  _calTotalPayReceive(member);
  _calTotalPayReceive(currUser);
}

void _adjustAmounts(Member member, Member otherMember, double netDifference,
    double opposingAmount) {
  if (netDifference < 0) {
    member.pay[otherMember.uid]['amount'] = opposingAmount - netDifference;
    member.receive[otherMember.uid]['amount'] = 0.0;
  } else if (netDifference == 0) {
    member.receive[otherMember.uid]['amount'] = 0.0;
    member.pay[otherMember.uid]['amount'] = 0.0;
  } else {
    member.pay[otherMember.uid]['amount'] = 0.0;
    member.receive[otherMember.uid]['amount'] = opposingAmount + netDifference;
  }
}
