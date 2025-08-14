import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../models/credit_card_model.dart';
import '../services/smart_motion_service.dart';
import 'emv_chip_widget.dart';

class CreditCardWidget extends StatefulWidget {
  final CreditCardModel cardData;
  final bool showFullNumber;
  final bool isFlipped;
  final VoidCallback? onTap;

  const CreditCardWidget({
    super.key,
    required this.cardData,
    this.showFullNumber = false,
    this.isFlipped = false,
    this.onTap,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with TickerProviderStateMixin {
  final SmartMotionService _motionService = SmartMotionService();

  double _currentRotationX = 0.0;
  double _currentRotationY = 0.0;
  double _shadowOffsetX = 0.0;
  double _shadowOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    _setupMotionListener();
  }

  @override
  void dispose() {
    _motionService.removeListener(_onMotionUpdate);
    super.dispose();
  }

  void _setupMotionListener() {
    _motionService.addListener(_onMotionUpdate);
    _motionService.setCardFocused(true);
    _motionService.startListening();
  }

  void _onMotionUpdate() {
    if (!mounted) return;

    final tiltX = _motionService.tiltX;

    setState(() {
      _currentRotationX = 0.0;
      _currentRotationY = _degreesToRadians(-tiltX * 0.4);

      _shadowOffsetX = tiltX * 0.2;
      _shadowOffsetY = 0.0;
    });
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  Widget _buildEmvChip(BuildContext context) {
    final cardHeight = ResponsiveHelper.getCardHeight(context);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.141592653589793),
      child: EmvChipWidget(width: cardHeight * 0.15, height: cardHeight * 0.15),
    );
  }

  Widget _buildFrontEmvChip(BuildContext context) {
    final cardHeight = ResponsiveHelper.getCardHeight(context);

    return EmvChipWidget(width: cardHeight * 0.15, height: cardHeight * 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.getCardWidth(context);
    final cardHeight = ResponsiveHelper.getCardHeight(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Transform(
        alignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_currentRotationX)
              ..rotateY(_currentRotationY),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius:
                    15 + (_shadowOffsetX.abs() + _shadowOffsetY.abs()) * 2,
                spreadRadius: 1,
                offset: Offset(_shadowOffsetX, _shadowOffsetY + 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildBackgroundGradient(cardWidth, cardHeight),
              _buildGlassLayer(cardWidth, cardHeight),
              widget.isFlipped
                  ? _buildBackContent(context)
                  : _buildFrontContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: CardTypeDetector.getCardGradientColors(
            widget.cardData.cardType ?? 'CARD',
          ),
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildGlassLayer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildFrontContent(BuildContext context) {
    ResponsiveHelper.getCardHeight(context);
    final padding = ResponsiveHelper.getCardPadding(context);

    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(flex: 2, child: _buildCardHeader(context)),
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [_buildFrontEmvChip(context)],
            ),
          ),
          const Expanded(child: SizedBox()),
          Flexible(flex: 2, child: _buildCardNumber(context)),
          Flexible(flex: 2, child: _buildCardDetails(context)),
        ],
      ),
    );
  }

  Widget _buildBackContent(BuildContext context) {
    final cardHeight = ResponsiveHelper.getCardHeight(context);
    final padding = ResponsiveHelper.getCardPadding(context);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.141592653589793),
      child: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: cardHeight * 0.08),
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,
                height: cardHeight * 0.18,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: cardHeight * 0.08),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getFontSize(context, 10),
                      vertical: ResponsiveHelper.getFontSize(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CVV: ',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveHelper.getFontSize(context, 11),
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          widget.cardData.cvv,
                          style: GoogleFonts.robotoMono(
                            fontSize: ResponsiveHelper.getFontSize(context, 12),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [_buildEmvChip(context)],
              ),
            ),
            SizedBox(height: cardHeight * 0.03),
            SizedBox(height: cardHeight * 0.02),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'AUTHORIZED SIGNATURE',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.getFontSize(context, 8),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: cardHeight * 0.03),
            Flexible(
              flex: 1,
              child: Container(
                width: double.infinity,
                height: cardHeight * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getCardTypeLabel(widget.cardData.cardType ?? 'CARD'),
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getFontSize(context, 12),
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 1.2,
          ),
        ),
        _buildCardTypeLogo(context, widget.cardData.cardType ?? 'CARD'),
      ],
    );
  }

  Widget _buildCardTypeLogo(BuildContext context, String cardType) {
    return _getCardLogo(context, cardType);
  }

  Widget _getCardLogo(BuildContext context, String cardType) {
    final cardHeight = ResponsiveHelper.getCardHeight(context);
    double logoWidth = cardHeight * 0.25;
    double logoHeight = cardHeight * 0.15;

    String? assetPath = _getCardAssetPath(cardType);

    if (assetPath != null) {
      return Container(
        width: logoWidth,
        height: logoHeight,
        padding: EdgeInsets.all(cardHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: SvgPicture.asset(
          assetPath,
          width: logoWidth - (cardHeight * 0.04),
          height: logoHeight - (cardHeight * 0.04),
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: logoWidth,
      height: logoHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.credit_card,
          color: Colors.white,
          size: cardHeight * 0.08,
        ),
      ),
    );
  }

  String? _getCardAssetPath(String cardType) {
    switch (cardType) {
      case 'VISA':
        return 'assets/visa.svg';
      case 'MASTERCARD':
        return 'assets/mastercard.svg';
      case 'AMEX':
        return 'assets/amex.svg';
      case 'RUPAY':
        return 'assets/rupay.svg';
      case 'DISCOVER':
        return 'assets/discover.svg';
      case 'DINERS':
        return 'assets/diners.svg';
      case 'JCB':
        return 'assets/jcb.svg';
      case 'UNIONPAY':
        return 'assets/unionpay.svg';
      default:
        return null;
    }
  }

  String _getCardTypeLabel(String cardType) {
    switch (cardType) {
      case 'VISA':
        return 'VISA CREDIT CARD';
      case 'MASTERCARD':
        return 'MASTERCARD';
      case 'AMEX':
        return 'AMERICAN EXPRESS';
      case 'RUPAY':
        return 'RUPAY CARD';
      case 'DISCOVER':
        return 'DISCOVER CARD';
      case 'DINERS':
        return 'DINERS CLUB';
      case 'JCB':
        return 'JCB CARD';
      case 'UNIONPAY':
        return 'UNIONPAY CARD';
      default:
        return 'CREDIT CARD';
    }
  }

  Widget _buildCardNumber(BuildContext context) {
    return Text(
      widget.showFullNumber
          ? widget.cardData.formattedCardNumber
          : widget.cardData.maskedCardNumber,
      style: GoogleFonts.robotoMono(
        fontSize: ResponsiveHelper.getFontSize(context, 22),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CARDHOLDER NAME',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveHelper.getFontSize(context, 10),
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.cardData.cardHolderName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPIRES',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveHelper.getFontSize(context, 10),
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.cardData.expiryDate,
                style: GoogleFonts.robotoMono(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
