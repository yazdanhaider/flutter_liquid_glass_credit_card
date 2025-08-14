import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/credit_card_model.dart';
import '../components/credit_card_widget.dart';
import '../widgets/buttons/cancel_button.dart';
import '../widgets/buttons/pay_button.dart';
import '../widgets/dialogs/payment_success_dialog.dart';
import '../formatters/input_formatters.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_colors.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool isCardFlipped = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final FocusNode _cvvFocusNode = FocusNode();

  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cvvFocusNode.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  void _setupListeners() {
    _cvvFocusNode.addListener(() {
      if (_cvvFocusNode.hasFocus && !isCardFlipped) {
        _flipCard();
      } else if (!_cvvFocusNode.hasFocus && isCardFlipped) {
        _flipCard();
      }
    });

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
      });
    });

    _nameController.addListener(() {
      setState(() {
        cardHolderName = _nameController.text;
      });
    });

    _expiryController.addListener(() {
      setState(() {
        expiryDate = _expiryController.text;
      });
    });

    _cvvController.addListener(() {
      setState(() {
        cvv = _cvvController.text;
      });
    });
  }

  void _flipCard() {
    if (isCardFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      isCardFlipped = !isCardFlipped;
    });
  }

  bool _isFormValid() {
    return cardNumber.length >= 16 &&
        cardHolderName.trim().isNotEmpty &&
        expiryDate.length >= 5 &&
        cvv.length >= 3;
  }

  void _onCancelPressed() {
    _cardNumberController.clear();
    _nameController.clear();
    _expiryController.clear();
    _cvvController.clear();

    setState(() {
      cardNumber = '';
      cardHolderName = '';
      expiryDate = '';
      cvv = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment cancelled',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onPayPressed() {
    PaymentSuccessDialog.show(context, _onCancelPressed);
  }

  @override
  Widget build(BuildContext context) {
    String detectedCardType = CardTypeDetector.detectCardType(cardNumber);

    final currentCard = CreditCardModel(
      cardNumber: cardNumber.isEmpty ? '•••• •••• •••• ••••' : cardNumber,
      cardHolderName: cardHolderName.isEmpty ? 'Your Name' : cardHolderName,
      expiryDate: expiryDate.isEmpty ? 'MM/YY' : expiryDate,
      cvv: cvv.isEmpty ? '•••' : cvv,
      cardType: detectedCardType,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildCardAnimation(currentCard),
                const SizedBox(height: 40),
                _buildInputFields(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Liquid Glass',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Credit Card',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 60,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardAnimation(CreditCardModel currentCard) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * 3.141592653589793),
          child: CreditCardWidget(
            cardData: currentCard,
            showFullNumber: false,
            isFlipped: isCardFlipped,
          ),
        );
      },
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardNumberField(),
        const SizedBox(height: 8),
        _buildHelperText(),
        const SizedBox(height: 20),
        _buildNameField(),
        const SizedBox(height: 20),
        _buildExpiryAndCvvFields(),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return _buildInputField(
      label: 'Card Number',
      hint: 'Enter your card number',
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        CardNumberInputFormatter(),
      ],
    );
  }

  Widget _buildHelperText() {
    return Text(
      'Try: 4111 (Visa), 5555 (Mastercard), 3782 (Amex), 6011 (Discover), 6062 (RuPay)',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.textPrimary.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildNameField() {
    return _buildInputField(
      label: 'Card Holder Name',
      hint: 'Enter name',
      controller: _nameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        LengthLimitingTextInputFormatter(30),
        NameInputFormatter(),
      ],
    );
  }

  Widget _buildExpiryAndCvvFields() {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            label: 'Expiry',
            hint: 'MM/YY',
            controller: _expiryController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              ExpiryDateInputFormatter(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildInputField(
            label: 'CVV',
            hint: '•••',
            controller: _cvvController,
            focusNode: _cvvFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          obscureText: obscureText,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textPrimary.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(flex: 1, child: CancelButton(onPressed: _onCancelPressed)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: PayButton(onPressed: _onPayPressed, isEnabled: _isFormValid()),
        ),
      ],
    );
  }
}
