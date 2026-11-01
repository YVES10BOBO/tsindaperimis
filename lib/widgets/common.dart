import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/models.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.radius = 18,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
        ),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.background,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color? background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0).toDouble(),
        minHeight: height,
        color: color,
        backgroundColor: background ?? AppColors.border,
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 96,
    this.stroke = 10,
    this.color = AppColors.primary,
    this.label,
    this.fontSize = 22,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final String? label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0).toDouble(),
            strokeWidth: stroke,
            color: color,
            backgroundColor: AppColors.border,
          ),
          Center(
            child: Text(
              label ?? '${(value * 100).round()}%',
              style: TextStyle(
                  fontSize: fontSize, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, required this.onTap});

  final LearnCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.tint(category.color, category.softColor),
      borderColor: category.color.withAlpha(AppColors.isDark ? 90 : 50),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      radius: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(category.icon, color: category.color, size: 34),
          const SizedBox(height: 8),
          Text(
            category.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color ?? AppColors.text)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

enum OptionState { neutral, selected, correct, wrong, dimmed }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  final String letter;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.border;
    Color bg = AppColors.surface;
    Color badgeBg = AppColors.background;
    Color badgeFg = AppColors.text;
    Color fg = AppColors.text;
    IconData? trailing;

    switch (state) {
      case OptionState.neutral:
        break;
      case OptionState.selected:
        border = AppColors.primary;
        bg = AppColors.primarySoft;
        badgeBg = AppColors.primary;
        badgeFg = Colors.white;
        break;
      case OptionState.correct:
        border = AppColors.success;
        bg = AppColors.successSoft;
        badgeBg = AppColors.success;
        badgeFg = Colors.white;
        trailing = Icons.check_circle;
        break;
      case OptionState.wrong:
        border = AppColors.error;
        bg = AppColors.errorSoft;
        badgeBg = AppColors.error;
        badgeFg = Colors.white;
        trailing = Icons.cancel;
        break;
      case OptionState.dimmed:
        fg = AppColors.muted;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        color: bg,
        borderColor: border,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(letter,
                  style: TextStyle(fontWeight: FontWeight.w800, color: badgeFg)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 15.5, height: 1.35, color: fg)),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              Icon(trailing,
                  color: state == OptionState.correct ? AppColors.success : AppColors.error),
            ],
          ],
        ),
      ),
    );
  }
}

String optionLetter(int i) => String.fromCharCode(65 + i);

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4)),
        ],
      ),
    );
  }
}

/// Ishusho y'umukoresha (inyuguti ya mbere y'izina ku ibara yahisemo).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, required this.colorIndex, this.radius = 28});

  final String name;
  final int colorIndex;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Color c =
        AppColors.avatarColors[colorIndex % AppColors.avatarColors.length];
    final String initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: c,
      child: Text(initial,
          style: TextStyle(
              fontSize: radius * 0.8, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }
}

/// Umwanya w'ijambo ry'ibanga ufite buto yo kurihisha / kurigaragaza.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _hidden ? 'Erekana' : 'Hisha',
          icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}

void showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Akamenyetso k'"Ubumenyi bw'inyongera" (ntibikunze kubazwa mu kizamini).
class ExtraKnowledgeBadge extends StatelessWidget {
  const ExtraKnowledgeBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 6),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purpleBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.lightbulb_outline, size: compact ? 13 : 15, color: AppColors.purple),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              compact ? "Ubumenyi bw'inyongera" : "Ubumenyi bw'inyongera · ntibikunze kubazwa mu kizamini",
              style: TextStyle(
                  fontSize: compact ? 11 : 12, fontWeight: FontWeight.w700, color: AppColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
