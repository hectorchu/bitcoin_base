import 'dart:typed_data';
import 'package:bitcoin_base/src/models/network.dart';
import 'package:bitcoin_base/src/bitcoin/address/address.dart';
import 'package:bitcoin_base/src/bitcoin/address/segwit_address.dart';
import 'package:bitcoin_base/src/bitcoin/constant/constant.dart';
import 'package:bitcoin_base/src/bitcoin/script/input.dart';
import 'package:bitcoin_base/src/bitcoin/script/output.dart';
import 'package:bitcoin_base/src/bitcoin/script/script.dart';
import 'package:bitcoin_base/src/bitcoin/script/transaction.dart';
import 'package:bitcoin_base/src/bitcoin/script/witness.dart';
import 'package:bitcoin_base/src/crypto/ec/ec_public.dart';
import '../test/utxo.dart';

// from segwit to P2pkhAddress
// need segwit pub key
// output pay-to-pubkey-hash
// input pay-to-witness-pubkey-hash

(String, String) spendP2wkhToP2kh(
    {required P2pkhAddress receiver,
    required ECPublic senderPub,
    required NetworkInfo networkType,
    required String Function(Uint8List, {int sigHash}) sign,
    required List<UTXO> utxo,
    BigInt? value,
    required BigInt estimateFee,
    int? trSize,
    int sighash = SIGHASH_ALL,
    P2wpkhAddress? changeAddress}) {
  int someBytes = 100 + (utxo.length * 100);

  final fee = BigInt.from((trSize ?? someBytes)) * estimateFee;
  final BigInt sumUtxo = utxo.fold(
      BigInt.zero, (previousValue, element) => previousValue + element.value);
  BigInt mustSend = value ?? sumUtxo;
  if (value == null) {
    mustSend = sumUtxo - fee;
  } else {
    BigInt currentValue = value + fee;
    if (trSize != null && sumUtxo < currentValue) {
      throw Exception(
          "need money balance $sumUtxo value + fee = $currentValue");
    }
  }
  if (mustSend.isNegative) {
    throw Exception(
        "your balance must >= transaction ${value ?? sumUtxo} + $fee");
  }
  BigInt needChangeTx = sumUtxo - (mustSend + fee);
  final txin = utxo.map((e) => TxInput(txId: e.txId, txIndex: e.vout)).toList();
  final List<TxWitnessInput> w = [];
  final List<TxOutput> txOut = [
    TxOutput(
        amount: mustSend,
        scriptPubKey: Script(script: receiver.toScriptPubKey()))
  ];
  if (needChangeTx > BigInt.zero) {
    txOut.add(TxOutput(
        amount: needChangeTx,
        scriptPubKey: Script(
            script: changeAddress?.toScriptPubKey() ??
                senderPub.toSegwitAddress().toScriptPubKey())));
  }
  final tx = BtcTransaction(inputs: txin, outputs: txOut, hasSegwit: true);
  for (int i = 0; i < txin.length; i++) {
    final txDigit = tx.getTransactionSegwitDigit(
        txInIndex: i,
        script: Script(script: senderPub.toAddress().toScriptPubKey()),
        sighash: sighash,
        amount: utxo[i].value);
    final signedTx = sign(txDigit);
    w.add(TxWitnessInput(stack: [signedTx, senderPub.toHex()]));
  }

  tx.witnesses.addAll(w);
  if (trSize == null) {
    return spendP2wkhToP2kh(
        estimateFee: estimateFee,
        networkType: networkType,
        receiver: receiver,
        senderPub: senderPub,
        sign: sign,
        utxo: utxo,
        value: value,
        sighash: sighash,
        trSize: tx.getVSize());
  }

  return (tx.serialize(), tx.txId());
}
