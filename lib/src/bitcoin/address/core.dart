part of 'package:bitcoin_base/src/bitcoin/address/address.dart';

abstract class BitcoinAddressType implements Enumerate {
  @override
  final String value;

  const BitcoinAddressType._(this.value);

  /// Factory method to create a BitcoinAddressType enum value from a name or value.
  static BitcoinAddressType fromValue(String value) {
    return values.firstWhere((element) => element.value == value,
        orElse: () =>
            throw MessageException('Invalid BitcoinAddressType: $value'));
  }

  /// Check if the address type is Pay-to-Script-Hash (P2SH).
  bool get isP2sh;
  int get hashLength;
  bool get isSegwit;

  // Enum values as a list for iteration
  static const List<BitcoinAddressType> values = [
    P2pkhAddressType.p2pkh,
    SegwitAddresType.p2wpkh,
    SegwitAddresType.p2tr,
    SegwitAddresType.p2wsh,
    SegwitAddresType.mweb,
    P2shAddressType.p2wshInP2sh,
    P2shAddressType.p2wpkhInP2sh,
    P2shAddressType.p2pkhInP2sh,
    P2shAddressType.p2pkInP2sh,
    P2shAddressType.p2pkhInP2sh32,
    P2shAddressType.p2pkInP2sh32,
    P2shAddressType.p2pkhInP2sh32wt,
    P2shAddressType.p2pkInP2sh32wt,
    P2shAddressType.p2pkhInP2shwt,
    P2shAddressType.p2pkInP2shwt,
    P2pkhAddressType.p2pkhwt
  ];
  @override
  String toString() => value;
}

abstract class BitcoinBaseAddress {
  BitcoinAddressType get type;
  String toAddress(BasedUtxoNetwork network);
  Script toScriptPubKey();
  String pubKeyHash();
  String get addressProgram;
}

class PubKeyAddressType implements BitcoinAddressType {
  const PubKeyAddressType._(this.value);
  static const PubKeyAddressType p2pk = PubKeyAddressType._("P2PK");
  @override
  bool get isP2sh => false;
  @override
  bool get isSegwit => false;
  @override
  final String value;
  @override
  int get hashLength => 20;
  @override
  String toString() => value;
}

class P2pkhAddressType implements BitcoinAddressType {
  const P2pkhAddressType._(this.value);
  static const P2pkhAddressType p2pkh = P2pkhAddressType._("P2PKH");
  static const P2pkhAddressType p2pkhwt = P2pkhAddressType._("P2PKHWT");

  @override
  bool get isP2sh => false;
  @override
  bool get isSegwit => false;

  @override
  final String value;

  @override
  int get hashLength => 20;
  @override
  String toString() => value;
}

class P2shAddressType implements BitcoinAddressType {
  const P2shAddressType._(this.value, this.hashLength, this.withToken);
  static const P2shAddressType p2wshInP2sh = P2shAddressType._(
      "P2SH/P2WSH", _BitcoinAddressUtils.hash160DigestLength, false);
  static const P2shAddressType p2wpkhInP2sh = P2shAddressType._(
      "P2SH/P2WPKH", _BitcoinAddressUtils.hash160DigestLength, false);
  static const P2shAddressType p2pkhInP2sh = P2shAddressType._(
      "P2SH/P2PKH", _BitcoinAddressUtils.hash160DigestLength, false);
  static const P2shAddressType p2pkInP2sh = P2shAddressType._(
      "P2SH/P2PK", _BitcoinAddressUtils.hash160DigestLength, false);
  @override
  bool get isP2sh => true;
  @override
  bool get isSegwit => false;

  @override
  final int hashLength;
  final bool withToken;

  /// specify BCH NETWORK for now!
  /// Pay-to-Script-Hash-32
  static const P2shAddressType p2pkhInP2sh32 = P2shAddressType._(
      "P2SH32/P2PKH", _BitcoinAddressUtils.scriptHashLenght, false);
  //// Pay-to-Script-Hash-32
  static const P2shAddressType p2pkInP2sh32 = P2shAddressType._(
      "P2SH32/P2PK", _BitcoinAddressUtils.scriptHashLenght, false);

  /// Pay-to-Script-Hash-32-with-token
  static const P2shAddressType p2pkhInP2sh32wt = P2shAddressType._(
      "P2SH32WT/P2PKH", _BitcoinAddressUtils.scriptHashLenght, true);

  /// Pay-to-Script-Hash-32-with-token
  static const P2shAddressType p2pkInP2sh32wt = P2shAddressType._(
      "P2SH32WT/P2PK", _BitcoinAddressUtils.scriptHashLenght, true);

  /// Pay-to-Script-Hash-with-token
  static const P2shAddressType p2pkhInP2shwt = P2shAddressType._(
      "P2SHWT/P2PKH", _BitcoinAddressUtils.hash160DigestLength, true);

  /// Pay-to-Script-Hash-with-token
  static const P2shAddressType p2pkInP2shwt = P2shAddressType._(
      "P2SHWT/P2PK", _BitcoinAddressUtils.hash160DigestLength, true);

  @override
  final String value;

  @override
  String toString() => value;
}

class SegwitAddresType implements BitcoinAddressType {
  const SegwitAddresType._(this.value);
  static const SegwitAddresType p2wpkh = SegwitAddresType._("P2WPKH");
  static const SegwitAddresType p2tr = SegwitAddresType._("P2TR");
  static const SegwitAddresType p2wsh = SegwitAddresType._("P2WSH");
  static const SegwitAddresType mweb = SegwitAddresType._("MWEB");
  @override
  bool get isP2sh => false;
  @override
  bool get isSegwit => true;

  @override
  final String value;

  @override
  int get hashLength {
    switch (this) {
      case SegwitAddresType.p2wpkh:
        return 20;
      default:
        return 32;
    }
  }

  @override
  String toString() => value;
}
