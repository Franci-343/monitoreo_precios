import 'package:flutter/material.dart';

class Web3GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const Web3GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class Web3GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? height;
  final double? width;

  const Web3GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

class Web3NeonTextField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;

  const Web3NeonTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enableInteractiveSelection: true,
        autocorrect: false,
        enableSuggestions: !obscureText,
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: const Color(0xFF00FFF0).withOpacity(0.7),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: const Color(0xFF00FFF0).withOpacity(0.7),
                  ),
                  onPressed: onSuffixIconPressed,
                )
              : null,
        ),
      ),
    );
  }
}

class Web3GradientBackground extends StatelessWidget {
  final Widget child;

  const Web3GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class Web3PriceCard extends StatelessWidget {
  final String productName;
  final String marketName;
  final String price;
  final String currency;
  final String? previousPrice;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onTap;

  const Web3PriceCard({
    super.key,
    required this.productName,
    required this.marketName,
    required this.price,
    this.currency = 'Bs',
    this.previousPrice,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceChange = _calculatePriceChange();
    final isIncreasing = priceChange > 0;
    final isDecreasing = priceChange < 0;

    return GestureDetector(
      onTap: onTap,
      child: Web3GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onFavoritePressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFF00FFF0) : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              marketName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$price $currency',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00FFF0),
                      ),
                    ),
                    if (previousPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Anterior: $previousPrice $currency',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                if (previousPrice != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isIncreasing
                          ? Colors.red.withOpacity(0.2)
                          : isDecreasing
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isIncreasing
                              ? Icons.trending_up
                              : isDecreasing
                              ? Icons.trending_down
                              : Icons.trending_flat,
                          size: 16,
                          color: isIncreasing
                              ? Colors.red
                              : isDecreasing
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${priceChange.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isIncreasing
                                ? Colors.red
                                : isDecreasing
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePriceChange() {
    if (previousPrice == null) return 0;

    try {
      final currentPrice = double.parse(price);
      final prevPrice = double.parse(previousPrice!);

      if (prevPrice == 0) return 0;

      return ((currentPrice - prevPrice) / prevPrice) * 100;
    } catch (e) {
      return 0;
    }
  }
}

class Web3FloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? heroTag;

  const Web3FloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
