import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import '../providers/quote_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/api_service.dart';
import 'quote_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quote = context.watch<QuoteProvider>();
    // When FER couldn't read the expression, branch to a warm fallback instead
    // of showing the sentinel string as a "detected" emotion. The normal
    // detected path below is unchanged.
    if (quote.noEmotionDetected) {
      return const _NoDetectionResult();
    }
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Eyebrow makes the SOURCE of the emotion explicit (the FER
                // basis), so users trust that their expression was read.
                // Display only — the emotion value is unchanged.
                Text(
                  'DETECTED FROM YOUR EXPRESSION',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'You seem a bit',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _EmotionBubble(emotion: quote.emotion.toLowerCase()),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  "We've analyzed your expression. Let's take a deep breath and find a moment of peace through words.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const Spacer(flex: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.read<NavigationProvider>().setIndex(1);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const QuoteScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          child: Center(
                            child: Text(
                              'Find My Quote',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                // Secondary action: same behaviour (pop back to camera), now an
                // obvious, adequately sized tap target.
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: AppTheme.minTapTarget,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                      ),
                      child: Text(
                        'Scan Again',
                        style: textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionBubble extends StatelessWidget {
  final String emotion;

  const _EmotionBubble({required this.emotion});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Colour derived from the already-detected emotion string. This does not
    // change how the emotion is computed — only how it is displayed, so the
    // detected mood reads consistently everywhere (SUS heuristic #6).
    final Color color = AppTheme.emotionColor(emotion);
    // Capitalise for display; the underlying value is untouched.
    final String label = emotion.isEmpty
        ? emotion
        : emotion[0].toUpperCase() + emotion.substring(1);

    return Semantics(
      label: 'Detected emotion: $label',
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.35),
              color.withValues(alpha: 0.55),
              color.withValues(alpha: 0.78),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 40,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(-6, -6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback shown when FER returns the "no emotion detected" sentinel. Warm,
/// non-error framing with two clear actions: retry the scan (primary) or pick a
/// mood manually, which routes into the normal quote flow via /quotes.
class _NoDetectionResult extends StatefulWidget {
  const _NoDetectionResult();

  @override
  State<_NoDetectionResult> createState() => _NoDetectionResultState();
}

class _NoDetectionResultState extends State<_NoDetectionResult> {
  bool _loadingQuotes = false;

  Future<void> _pickEmotion() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EmotionPickerSheet(),
    );
    if (selected == null || !mounted) return;

    setState(() => _loadingQuotes = true);
    try {
      final quotes = await ApiService.fetchQuotesByEmotion(selected);
      if (!mounted) return;
      // Route the manually chosen emotion into the SAME quote flow as a real
      // detection — identical navigation to "Find My Quote".
      context.read<QuoteProvider>().setResult(emotion: selected, quotes: quotes);
      context.read<NavigationProvider>().setIndex(1);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuoteScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingQuotes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't load quotes just now. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color accent = AppTheme.emotionColor('neutral');

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundGradient,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      'LET’S TRY THAT AGAIN',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    // Neutral bubble (no emotion to colour) — mirrors the
                    // detected bubble's shape so the screen stays consistent.
                    Semantics(
                      label: 'Expression not recognised',
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.35),
                              accent.withValues(alpha: 0.45),
                              accent.withValues(alpha: 0.68),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sentiment_neutral_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    Text(
                      "We couldn't quite read your expression",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      "This usually comes down to lighting or camera angle. "
                      "Try again, or tell us how you're feeling.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    const Spacer(flex: 2),
                    // Primary action: retry FER capture (the preferred path).
                    _GlassPrimaryButton(
                      label: 'Scan Again',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    // Secondary fallback: manual mood selection.
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickEmotion,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusPill),
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: AppTheme.minTapTarget,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceMd,
                          ),
                          child: Text(
                            "Pick how you're feeling",
                            style: textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                ),
              ),
            ),
          ),
          if (_loadingQuotes)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'Finding quotes for you…',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared glass pill primary button (matches the detected screen's CTA styling).
class _GlassPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Manual mood picker — the four real FER labels (happy / sad / angry /
/// surprise). Returns the chosen emotion via [Navigator.pop].
class _EmotionPickerSheet extends StatelessWidget {
  const _EmotionPickerSheet();

  static const List<String> _emotions = ['happy', 'sad', 'angry', 'surprise'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.gradientTop,
              AppTheme.gradientMid,
              AppTheme.gradientBottom,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLg,
              AppTheme.spaceMd,
              AppTheme.spaceLg,
              AppTheme.spaceLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  'How are you feeling?',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  "We'll find quotes to match.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spaceLg),
                for (final emotion in _emotions) ...[
                  _EmotionOption(
                    emotion: emotion,
                    onTap: () => Navigator.pop(context, emotion),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionOption extends StatelessWidget {
  final String emotion;
  final VoidCallback onTap;

  const _EmotionOption({required this.emotion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color color = AppTheme.emotionColor(emotion);
    final String label = emotion[0].toUpperCase() + emotion.substring(1);

    return Semantics(
      button: true,
      label: 'Select $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppTheme.minTapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceSm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
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