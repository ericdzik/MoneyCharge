import 'package:flutter/material.dart';

/// Widget Row d'information réutilisable (Icône + Label + Valeur)
/// 
/// Pattern répété dans de nombreux écrans pour afficher des infos
/// 
/// Usage:
/// ```dart
/// InfoRow(
///   icon: Icons.phone,
///   label: 'Téléphone',
///   value: '+228 90 12 34 56',
/// )
/// ```
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool isLink;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: content,
    );
  }
}

/// Chip de statut coloré réutilisable
/// 
/// Usage:
/// ```dart
/// StatusChip(
///   label: 'Actif',
///   color: Colors.green,
/// )
/// StatusChip.success(label: 'Approuvé')
/// StatusChip.error(label: 'Rejeté')
/// StatusChip.warning(label: 'En attente')
/// ```
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  const StatusChip.success({
    super.key,
    required this.label,
    this.icon = Icons.check_circle,
  }) : color = const Color(0xFF4CAF50);

  const StatusChip.error({
    super.key,
    required this.label,
    this.icon = Icons.error,
  }) : color = const Color(0xFFF44336);

  const StatusChip.warning({
    super.key,
    required this.label,
    this.icon = Icons.warning,
  }) : color = const Color(0xFFFF9800);

  const StatusChip.info({
    super.key,
    required this.label,
    this.icon = Icons.info,
  }) : color = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de service réutilisable
/// 
/// Pour afficher les services offerts par un marchand
class ServiceChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const ServiceChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Colors.grey[400]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boutons d'action responsifs (adaptatifs à la largeur)
/// 
/// Passe de Row à Column selon la largeur disponible
class ResponsiveActionButtons extends StatelessWidget {
  final List<Widget> buttons;
  final double breakpoint;
  final MainAxisAlignment alignment;
  final double spacing;

  const ResponsiveActionButtons({
    super.key,
    required this.buttons,
    this.breakpoint = 600,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < breakpoint;

        if (isNarrow) {
          // Mode Column pour petits écrans
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _interleave(
              buttons,
              SizedBox(height: spacing),
            ),
          );
        } else {
          // Mode Row pour grands écrans
          return Row(
            mainAxisAlignment: alignment,
            children: _interleave(
              buttons.map((btn) => Expanded(child: btn)).toList(),
              SizedBox(width: spacing),
            ),
          );
        }
      },
    );
  }

  List<Widget> _interleave(List<Widget> items, Widget separator) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

/// Section avec titre et contenu
/// 
/// Pattern répété pour organiser les informations par sections
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Divider avec label au milieu
class LabeledDivider extends StatelessWidget {
  final String label;
  final Color? color;
  final double thickness;

  const LabeledDivider({
    super.key,
    required this.label,
    this.color,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color ?? Colors.grey[300],
            thickness: thickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: color ?? Colors.grey[300],
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}

/// Badge de notification (petit cercle rouge avec nombre)
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color backgroundColor;
  final Color textColor;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rating display (étoiles)
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final Color unratedColor;
  final bool showValue;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.color = Colors.amber,
    this.unratedColor = Colors.grey,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: color, size: size);
          } else if (index < rating) {
            return Icon(Icons.star_half, color: color, size: size);
          } else {
            return Icon(Icons.star_border, color: unratedColor, size: size);
          }
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
