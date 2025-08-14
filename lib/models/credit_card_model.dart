class CreditCardModel {
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;
  final String? cardType;

  const CreditCardModel({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    this.cardType,
  });

  String get formattedCardNumber {
    String cleanNumber = cardNumber.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cleanNumber[i];
    }
    return formatted;
  }

  String get maskedCardNumber {
    String cleanNumber = cardNumber.replaceAll(' ', '');

    if (cleanNumber.isEmpty) {
      return '•••• •••• •••• ••••';
    }

    if (cleanNumber.length <= 4) {
      return '${cleanNumber.padRight(4, '•')} •••• •••• ••••';
    }

    if (cleanNumber.length <= 8) {
      String first4 = cleanNumber.substring(0, 4);
      String remaining = cleanNumber.substring(4).padRight(4, '•');
      return '$first4 $remaining •••• ••••';
    }

    if (cleanNumber.length <= 12) {
      String first4 = cleanNumber.substring(0, 4);
      return '$first4 xxxx xxxx ••••';
    }

    String first4 = cleanNumber.substring(0, 4);
    String last4 = cleanNumber.substring(cleanNumber.length - 4);
    return '$first4 xxxx xxxx $last4';
  }

  CreditCardModel copyWith({
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    String? cardType,
  }) {
    return CreditCardModel(
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
    );
  }
}
