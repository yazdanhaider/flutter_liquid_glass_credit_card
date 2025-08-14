import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getCardWidth(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.6;
    } else {
      return 400;
    }
  }

  static double getCardHeight(BuildContext context) {
    double cardWidth = getCardWidth(context);
    return cardWidth * 0.63;
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth < 350) {
      return baseFontSize * 0.8;
    } else if (screenWidth < 768) {
      return baseFontSize;
    } else if (screenWidth < 1024) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }
}

class CardTypeDetector {
  static String detectCardType(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(' ', '').replaceAll('-', '');

    if (cleanNumber.isEmpty) {
      return 'CARD';
    }

    // Visa: starts with 4
    if (cleanNumber.startsWith('4')) {
      return 'VISA';
    }

    // Mastercard: starts with 5[1-5] or 2[2-7]
    if (cleanNumber.startsWith('5')) {
      String secondDigit = cleanNumber.length > 1 ? cleanNumber[1] : '';
      if (['1', '2', '3', '4', '5'].contains(secondDigit)) {
        return 'MASTERCARD';
      }
    }

    if (cleanNumber.startsWith('2')) {
      String secondDigit = cleanNumber.length > 1 ? cleanNumber[1] : '';
      if (['2', '3', '4', '5', '6', '7'].contains(secondDigit)) {
        return 'MASTERCARD';
      }
    }

    // American Express: starts with 34 or 37
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return 'AMEX';
    }

    // Discover: starts with 6
    if (cleanNumber.startsWith('6')) {
      // Check for specific Discover patterns
      if (cleanNumber.startsWith('6011') ||
          cleanNumber.startsWith('644') ||
          cleanNumber.startsWith('645') ||
          cleanNumber.startsWith('646') ||
          cleanNumber.startsWith('647') ||
          cleanNumber.startsWith('648') ||
          cleanNumber.startsWith('649') ||
          (cleanNumber.startsWith('65') && cleanNumber.length >= 3)) {
        return 'DISCOVER';
      }

      // RuPay: starts with 60, 65, 81, 82
      if (cleanNumber.startsWith('60') || cleanNumber.startsWith('65')) {
        return 'RUPAY';
      }
    }

    // RuPay: also starts with 81, 82
    if (cleanNumber.startsWith('81') || cleanNumber.startsWith('82')) {
      return 'RUPAY';
    }

    // Diners Club: starts with 30, 36, 38
    if (cleanNumber.startsWith('30') ||
        cleanNumber.startsWith('36') ||
        cleanNumber.startsWith('38')) {
      return 'DINERS';
    }

    // JCB: starts with 35
    if (cleanNumber.startsWith('35')) {
      return 'JCB';
    }

    // UnionPay: starts with 62
    if (cleanNumber.startsWith('62')) {
      return 'UNIONPAY';
    }

    // Default
    return 'CARD';
  }

  static Color getCardTypeColor(String cardType) {
    switch (cardType) {
      case 'MASTERCARD':
        return const Color(0xFFDAA520);
      default:
        return const Color(0xFF2C2C2C);
    }
  }

  static List<Color> getCardGradientColors(String cardType) {
    switch (cardType) {
      case 'MASTERCARD':
        return [
          const Color(0xFFFFD700).withValues(alpha: 0.9),
          const Color(0xFFDAA520).withValues(alpha: 0.8),
          const Color(0xFFB8860B).withValues(alpha: 0.9),
          const Color(0xFF8B6914).withValues(alpha: 0.7),
        ];
      default:
        return [
          const Color(0xFF2C2C2C).withValues(alpha: 0.9),
          const Color(0xFF1A1A1A).withValues(alpha: 0.8),
          const Color(0xFF0D0D0D).withValues(alpha: 0.9),
          const Color(0xFF000000).withValues(alpha: 0.7),
        ];
    }
  }

  static double getShimmerIntensity(String cardType) {
    switch (cardType) {
      case 'AMEX':
        return 0.15;
      case 'VISA':
        return 0.12;
      case 'MASTERCARD':
        return 0.14;
      case 'RUPAY':
        return 0.1;
      case 'DISCOVER':
        return 0.12;
      case 'DINERS':
        return 0.14;
      case 'JCB':
        return 0.12;
      case 'UNIONPAY':
        return 0.1;
      default:
        return 0.12;
    }
  }

  static Color getMetallicTint(String cardType) {
    switch (cardType) {
      case 'MASTERCARD':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFFC0C0C0);
    }
  }
}
