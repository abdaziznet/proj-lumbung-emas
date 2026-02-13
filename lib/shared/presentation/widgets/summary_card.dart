import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final double? subtitleValue;
  final String? subtitleLabel;
  final bool isProfit;
  final IconData icon;
  final GoldTextureStyle textureStyle;
  final bool obscureValues;
  final VoidCallback? onToggleObscure;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitleValue,
    this.subtitleLabel,
    this.isProfit = true,
    required this.icon,
    this.textureStyle = GoldTextureStyle.emboss,
    this.obscureValues = false,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFCF3),
            Color(0xFFFFF5DC),
            Color(0xFFF6E2A6),
          ],
          stops: [0.0, 0.58, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCFA94A).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE4C777),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: CustomPaint(
                painter: _GoldTexturePainter(style: textureStyle),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6C5420),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF).withValues(alpha: 0.75),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: onToggleObscure,
                                icon: Icon(
                                  obscureValues
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: const Color(0xFF9C7724),
                                  size: 18,
                                ),
                                visualDensity: VisualDensity.compact,
                                splashRadius: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF).withValues(alpha: 0.75),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: const Color(0xFF9C7724),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'FINE GOLD 999.9',
                          style: TextStyle(
                            color: Color(0x66885F1A),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      obscureValues ? 'Rp •••••••' : currencyFormat.format(value),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF2F2A1E),
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                if (subtitleValue != null) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isProfit
                                  ? const Color(0xFF167A45)
                                  : const Color(0xFFB93838))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isProfit
                                    ? const Color(0xFF167A45)
                                    : const Color(0xFFB93838))
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isProfit ? Icons.trending_up : Icons.trending_down,
                              color: isProfit
                                  ? const Color(0xFF167A45)
                                  : const Color(0xFFB93838),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              obscureValues
                                  ? 'Rp •••••'
                                  : currencyFormat.format(subtitleValue!.abs()),
                              style: TextStyle(
                                color: isProfit
                                    ? const Color(0xFF167A45)
                                    : const Color(0xFFB93838),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        subtitleLabel ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF7A6A43),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldTexturePainter extends CustomPainter {
  final GoldTextureStyle style;

  const _GoldTexturePainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x66FFF8DC),
          Color(0x00FFF8DC),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, topGlow);

    final diagonalHighlight = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x66FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(size.width * 0.64, -20, size.width * 0.35, size.height + 40),
      );
    final path = Path()
      ..moveTo(size.width * 0.68, 0)
      ..lineTo(size.width * 0.88, 0)
      ..lineTo(size.width * 0.58, size.height)
      ..lineTo(size.width * 0.38, size.height)
      ..close();
    canvas.drawPath(path, diagonalHighlight);

    if (style == GoldTextureStyle.emboss) {
      final frameOuter = Paint()
        ..color = const Color(0x66A67C28)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final frameInner = Paint()
        ..color = const Color(0x88FFF0C2)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final outer = RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
        const Radius.circular(18),
      );
      final inner = RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 14, size.width - 28, size.height - 28),
        const Radius.circular(14),
      );
      canvas.drawRRect(outer, frameOuter);
      canvas.drawRRect(inner, frameInner);

    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum GoldTextureStyle {
  satin,
  emboss,
}
