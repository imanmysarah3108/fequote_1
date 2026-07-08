import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../viewmodels/quote_rewrite_viewmodel.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';

class AIRewriteScreen extends StatefulWidget {
  final String selectedQuote;

  const AIRewriteScreen({super.key, required this.selectedQuote});

  @override
  State<AIRewriteScreen> createState() => _AIRewriteScreenState();
}

class _AIRewriteScreenState extends State<AIRewriteScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _contextController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _contextController = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<QuoteRewriteViewModel>();
      vm.setOriginalQuote(widget.selectedQuote);
      await vm.initSpeech();
    });
  }

  void _syncContextFromViewModel(QuoteRewriteViewModel vm) {
    if (_contextController.text != vm.context) {
      _contextController.text = vm.context;
      _contextController.selection = TextSelection.fromPosition(
        TextPosition(offset: _contextController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _contextController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuoteRewriteViewModel>();
    final textTheme = Theme.of(context).textTheme;
    _syncContextFromViewModel(vm);

    if (vm.hasResult && _fadeController.status != AnimationStatus.completed) {
      _fadeController.forward(from: 0);
    }

    return Scaffold(
      body: Container(
        // Full-bleed gradient: fill the viewport so short quotes never expose
        // the Scaffold's black background. The scroll view lives inside and a
        // minHeight = viewport keeps the background full even when content is
        // shorter than the screen. Behaviour unchanged — only visuals/layout.
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: AppTheme.spaceXs),
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.chevron_left,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '✦  AI Rewrite',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(width: AppTheme.minTapTarget),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceLg),
                GlassContainer(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Quote',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spaceMd,
                                vertical: AppTheme.spaceXs,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.buttonGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTheme.labelSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Text(
                        vm.originalQuote,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                GlassContainer(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's happening today?",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceMd,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _contextController,
                                    onChanged: vm.setContext,
                                    maxLines: 3,
                                    minLines: 1,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Type here...',
                                      hintStyle: textTheme.bodyMedium,
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: vm.isListening
                                      ? 'Stop voice input'
                                      : 'Start voice input',
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (vm.isListening) {
                                        await vm.stopListening();
                                      } else {
                                        await vm.startListening();
                                      }
                                    },
                                    child: Container(
                                      width: AppTheme.minTapTarget,
                                      height: AppTheme.minTapTarget,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: vm.isListening
                                            ? AppTheme.primaryPurple.withValues(alpha: 0.5)
                                            : Colors.white.withValues(alpha: 0.15),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Icon(
                                        vm.isListening ? Icons.mic : Icons.mic_none,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (vm.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    vm.error!,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.red.shade200),
                  ),
                ],
                const SizedBox(height: AppTheme.spaceLg),
                GradientButton(
                  label: '✦  Rewrite Quote',
                  isLoading: vm.isLoading,
                  onPressed: () => vm.rewriteQuote(),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                Center(
                  child: Text(
                    '✦  Your Personalized Quote  ✦',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                if (vm.hasResult)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _ResultCard(quote: vm.rewrittenQuote!),
                  )
                else if (vm.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else
                  GlassContainer(
                    borderRadius: AppTheme.radiusQuoteCard,
                    padding: const EdgeInsets.all(AppTheme.spaceXl),
                    child: Center(
                      child: Text(
                        'Your personalized quote will appear here.',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (vm.hasResult) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  GlassContainer(
                    borderRadius: AppTheme.radiusPill,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.copy_rounded,
                            label: 'Copy',
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: vm.rewrittenQuote!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Quote copied to clipboard'),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.refresh_rounded,
                            label: 'Rewrite Again',
                            onTap: () => vm.rewriteAgain(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spaceXl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String quote;

  const _ResultCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusQuoteCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9E8BFF),
            Color(0xFFFFB09C),
            Color(0xFFFF9EC7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusQuoteCard - 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceLg,
              vertical: AppTheme.spaceXl,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusQuoteCard - 2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    '\u201C',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spaceMd,
                    horizontal: AppTheme.spaceXs,
                  ),
                  child: Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    '\u201D',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: AppTheme.minTapTarget,
          height: AppTheme.minTapTarget,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            tooltip: 'Back',
            onPressed: onTap,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: AppTheme.bodySize,
            ),
          ),
        ],
      ),
    );
  }
}
