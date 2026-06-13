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
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.chevron_left,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'AI Rewrite',
                            style: textTheme.headlineMedium?.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Quote',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9E8BFF), Color(0xFFFFB09C)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vm.originalQuote,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "What's happening today?",
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _contextController,
                          onChanged: vm.setContext,
                          maxLines: 3,
                          minLines: 1,
                          style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type here...',
                            hintStyle: textTheme.bodyMedium,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (vm.isListening) {
                            await vm.stopListening();
                          } else {
                            await vm.startListening();
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: vm.isListening
                                ? AppTheme.primaryPurple.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.15),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: Icon(
                            vm.isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.white,
                            size: 22,
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
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Rewrite Quote',
                  icon: Icons.auto_awesome,
                  isLoading: vm.isLoading,
                  onPressed: () => vm.rewriteQuote(),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Your Personalized Quote',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.auto_awesome, color: Colors.white70, size: 14),
                  ],
                ),
                const SizedBox(height: 16),
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
                    borderRadius: 32,
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Your personalized quote will appear here.',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (vm.hasResult) ...[
                  const SizedBox(height: 20),
                  GlassContainer(
                    borderRadius: 28,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  backgroundColor: AppTheme.primaryPurple,
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
                const SizedBox(height: 32),
              ],
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
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9E8BFF),
            Color(0xFFFFB09C),
            Color(0xFFFF9EC7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    '"',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    '"',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onTap,
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
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
