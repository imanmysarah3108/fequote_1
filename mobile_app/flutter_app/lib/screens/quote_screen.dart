import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import '../providers/quote_provider.dart';
import '../app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'reflect_screen.dart';
import 'settings_screen.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentIndex) {
      setState(() => _currentIndex = page);
    }
    context.read<QuoteProvider>().setSelectedQuoteIndex(page);
  }

  void _goToPrevious() {
    if (!_pageController.hasClients) return;
    final current = _pageController.page?.round() ?? 0;
    if (current > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (!_pageController.hasClients) return;
    final quote = context.read<QuoteProvider>();
    final count = quote.quotes.isEmpty ? 1 : quote.quotes.length;
    final current = _pageController.page?.round() ?? 0;
    if (current < count - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToDashboard() {
    Navigator.pushNamed(context, AppRoutes.moodDashboard);
  }

  void _goToCamera() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReflectScreen()),
    );
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openAiRewrite(List<String> quotes) {
    Navigator.pushNamed(
      context,
      AppRoutes.aiRewrite,
      arguments: quotes[_currentIndex],
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = context.watch<QuoteProvider>();
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final displayQuotes = quote.quotes.isEmpty
        ? ['Your motivational quote will appear here. You are stronger than you think.']
        : quote.quotes;

    final emotionLabel =
        '${quote.emotion[0].toUpperCase()}${quote.emotion.substring(1)}';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                'A quote for your',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '$emotionLabel moment',
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      itemCount: displayQuotes.length,
                      physics: const BouncingScrollPhysics(),
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double scale = 1.0;
                            if (_pageController.position.haveDimensions) {
                              final page =
                                  _pageController.page ?? index.toDouble();
                              scale = (1 - (page - index).abs() * 0.07)
                                  .clamp(0.9, 1.0);
                            }
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: _QuoteCard(
                              quote: displayQuotes[index],
                              maxHeight: screenHeight * 0.42,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 4,
                      child: _CarouselArrow(
                        icon: Icons.chevron_left,
                        onTap: _goToPrevious,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      child: _CarouselArrow(
                        icon: Icons.chevron_right,
                        onTap: _goToNext,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                child: _AiRewriteButton(
                  onTap: () => _openAiRewrite(displayQuotes),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              AppBottomNavBar(
                activeTab: BottomNavTab.camera,
                onDashboard: _goToDashboard,
                onCamera: _goToCamera,
                onSettings: _goToSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  final double maxHeight;

  const _QuoteCard({required this.quote, required this.maxHeight});

  double _fontSizeFor(String text) {
    final len = text.length;
    if (len <= 60) return 15;
    if (len <= 120) return 14;
    if (len <= 200) return 13;
    if (len <= 300) return 12;
    return 11;
  }

  EdgeInsets _paddingFor(String text) {
    final len = text.length;
    if (len <= 80) {
      return const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXl,
        vertical: AppTheme.spaceXl,
      );
    }
    return const EdgeInsets.symmetric(
      horizontal: AppTheme.spaceLg,
      vertical: AppTheme.spaceLg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fontSize = _fontSizeFor(quote);
    final padding = _paddingFor(quote);
    final isLong = quote.length > 200;

    final quoteText = Text(
      quote,
      textAlign: TextAlign.center,
      style: textTheme.bodyLarge?.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: AppTheme.quoteText,
        height: 1.45,
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        maxWidth: 300,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusQuoteCard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppTheme.radiusQuoteCard),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: isLong
                ? SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: quoteText,
                  )
                : quoteText,
          ),
        ),
      ),
    );
  }
}

class _AiRewriteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AiRewriteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Ink(
          height: AppTheme.buttonHeight,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: AppTheme.spaceXs),
              Text(
                'AI Rewrite',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
