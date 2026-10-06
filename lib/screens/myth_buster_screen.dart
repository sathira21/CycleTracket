import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../content/content_repository.dart';
import '../content/content_types.dart';
import '../l10n/lang.dart';
import '../l10n/strings.dart';
import '../routes.dart';
import '../services/session_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/app_toast.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/hide_button.dart';
import '../widgets/lang_builder.dart';
import 'main_screen.dart';

/// S7 – Myth Buster quiz screen (REQ-3.1, REQ-3.2).
///
/// Features:
/// 1. Dark maroon theme with [AppTopBar] (dark mode) and panic [HideButton].
/// 2. Header progress indicator with "QUESTION N OF TOTAL" label.
/// 3. White question card with "?" badge, cultural saying statement in quotes,
///    and sub-prompt "Is this cultural saying true or false?".
/// 4. Stacked response buttons: "It's a MYTH" and "It's a FACT".
/// 5. Feedback card on answer with correct/incorrect badge, explanation, and "Next".
/// 6. Results summary screen with score, best score persistence, "Play again",
///    and "Back to hub".
/// 7. Questions shuffled per run (configurable for deterministic testing).
class MythBusterScreen extends StatefulWidget {
  const MythBusterScreen({
    super.key,
    this.repository = const BundledRepository(),
    this.shuffleQuestions = true,
  });

  final ContentRepository repository;
  final bool shuffleQuestions;

  @override
  State<MythBusterScreen> createState() => _MythBusterScreenState();
}

class _MythBusterScreenState extends State<MythBusterScreen> {
  late List<MythQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  bool? _selectedIsMyth;
  bool _quizComplete = false;
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _startQuiz();
  }

  void _loadBestScore() {
    try {
      final box = Hive.box<dynamic>('settings');
      _bestScore = box.get('quiz_best_score', defaultValue: 0) as int;
    } catch (_) {
      _bestScore = 0;
    }
  }

  Future<void> _recordScore(int score) async {
    try {
      final box = Hive.box<dynamic>('settings');
      final currentBest = box.get('quiz_best_score', defaultValue: 0) as int;
      if (score > currentBest) {
        await box.put('quiz_best_score', score);
        if (mounted) setState(() => _bestScore = score);
      }
    } catch (_) {}
  }

  void _startQuiz() {
    final list = List<MythQuestion>.from(widget.repository.mythQuestions());
    if (widget.shuffleQuestions) {
      list.shuffle();
    }
    setState(() {
      _questions = list;
      _currentIndex = 0;
      _score = 0;
      _selectedIsMyth = null;
      _quizComplete = false;
    });
  }

  void _answerQuestion(bool isMyth) {
    if (_selectedIsMyth != null || _quizComplete) return;

    final question = _questions[_currentIndex];
    final isCorrect = (isMyth == question.isMyth);

    setState(() {
      _selectedIsMyth = isMyth;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedIsMyth = null;
      });
    } else {
      if (_score > _bestScore) {
        _bestScore = _score;
      }
      _recordScore(_score);
      setState(() {
        _quizComplete = true;
      });
    }
  }

  void _handleHide(BuildContext context) {
    AppToast.dismiss();
    ScaffoldMessenger.of(context).clearSnackBars();
    try {
      context.read<SessionState>().lock();
    } catch (_) {}
    AppRoutes.resetTo(context, const MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return LangBuilder(
      builder: (context, lang) {
        return Scaffold(
          backgroundColor: AppTheme.maroon,
          appBar: AppTopBar(
            title: t('quiz_title', lang: lang),
            dark: true,
            trailing: HideButton(
              onHide: () => _handleHide(context),
            ),
          ),
          body: SafeArea(
            child: _quizComplete
                ? _buildResultsView(context, lang)
                : _buildQuizView(context, lang),
          ),
        );
      },
    );
  }

  // ── Quiz Active View ───────────────────────────────────────────────

  Widget _buildQuizView(BuildContext context, Lang lang) {
    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final total = _questions.length;
    final currentNumber = _currentIndex + 1;
    final question = _questions[_currentIndex];
    final progressValue = currentNumber / total;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Progress Header ────────────────────────────────────────
          Text(
            t('quiz_progress', lang: lang, params: {
              'n': '$currentNumber',
              'total': '$total',
            }),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          AppProgressBar(
            value: progressValue,
            color: const Color(0xFFF14E80),
            trackColor: Colors.white24,
            height: 8,
          ),
          const SizedBox(height: 20),

          // ── White Question Card ────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Question badge icon
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: Color(0xFFB01848),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Statement in quotes
                Text(
                  '“${question.statement.of(lang)}”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2D142C),
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Sub-prompt
                Text(
                  t('quiz_prompt', lang: lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Response State: Buttons or Feedback ──────────────
                if (_selectedIsMyth == null) ...[
                  // 1. "It's a MYTH" filled pink button
                  Material(
                    color: const Color(0xFFE83A6D),
                    shape: const StadiumBorder(),
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _answerQuestion(true),
                      child: SizedBox(
                        height: 52,
                        child: Center(
                          child: Text(
                            t('its_myth', lang: lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. "It's a FACT" outlined maroon button
                  Material(
                    color: Colors.white,
                    shape: const StadiumBorder(
                      side: BorderSide(
                        color: AppTheme.maroon,
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _answerQuestion(false),
                      child: SizedBox(
                        height: 52,
                        child: Center(
                          child: Text(
                            t('its_fact', lang: lang),
                            style: const TextStyle(
                              color: AppTheme.maroon,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // ── Feedback Banner ────────────────────────────────
                  _buildFeedbackBanner(context, question, lang),
                  const SizedBox(height: 20),

                  // ── Next / See Results Button ──────────────────────
                  Material(
                    color: AppTheme.maroon,
                    shape: const StadiumBorder(),
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _nextQuestion,
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentNumber == total
                                  ? (lang == Lang.si ? 'ප්‍රතිඵල බලන්න' : 'See Results')
                                  : t('next', lang: lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Feedback Banner ────────────────────────────────────────────────

  Widget _buildFeedbackBanner(
    BuildContext context,
    MythQuestion question,
    Lang lang,
  ) {
    final wasCorrect = (_selectedIsMyth == question.isMyth);
    final isMythAnswer = question.isMyth;

    final bgColor = wasCorrect
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFFF1F2);
    final borderColor = wasCorrect
        ? const Color(0xFFBBF7D0)
        : const Color(0xFFFECDD3);
    final accentColor = wasCorrect
        ? const Color(0xFF16A34A)
        : const Color(0xFFE11D48);

    final headline = wasCorrect
        ? t('quiz_correct', lang: lang)
        : t('quiz_incorrect', lang: lang);

    final truthLabel = isMythAnswer
        ? t('its_myth', lang: lang)
        : t('its_fact', lang: lang);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                wasCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '$headline ($truthLabel)',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation.of(lang),
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── Results View ───────────────────────────────────────────────────

  Widget _buildResultsView(BuildContext context, Lang lang) {
    final total = _questions.length;
    final isPerfect = (_score == total);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy / celebration badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: isPerfect
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFFDE8EF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isPerfect
                        ? Icons.emoji_events_rounded
                        : Icons.psychology_rounded,
                    color: isPerfect
                        ? const Color(0xFFD97706)
                        : const Color(0xFFB01848),
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                lang == Lang.si ? 'ප්‍රශ්නාවලිය අවසන්!' : 'Quiz Complete!',
                style: const TextStyle(
                  color: Color(0xFF2D142C),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),

              // Score text
              Text(
                t('quiz_result', lang: lang, params: {
                  'score': '$_score',
                  'total': '$total',
                }),
                style: const TextStyle(
                  color: Color(0xFFB01848),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),

              // Best score
              Text(
                lang == Lang.si
                    ? 'හොඳම ලකුණු: $_bestScore / $total'
                    : 'Personal Best: $_bestScore / $total',
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),

              // "Play again" primary button
              Material(
                color: const Color(0xFFE83A6D),
                shape: const StadiumBorder(),
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _startQuiz,
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(
                        t('play_again', lang: lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // "Back to hub" secondary button
              Material(
                color: Colors.white,
                shape: const StadiumBorder(
                  side: BorderSide(
                    color: AppTheme.maroon,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      AppRoutes.resetTo(context, const MainScreen());
                    }
                  },
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(
                        t('back_to_hub', lang: lang),
                        style: const TextStyle(
                          color: AppTheme.maroon,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
