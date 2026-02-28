import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final IconData icon;
  final String? retryText;

  const ErrorDisplay({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.icon = FluentIcons.error,
    this.retryText,
  });

  static const _iconSize = 40.0;
  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 24.0);
  static final _errorColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _iconSize, color: _errorColor),
          const SizedBox(height: 16),
          Padding(
            padding: _horizontalPadding,
            child: Text(
              errorMessage,
              style: TextStyle(color: _errorColor),
              textAlign: TextAlign.center,
              semanticsLabel: '${l10n.reportsError}: $errorMessage',
            ),
          ),
          const SizedBox(height: 24),
          Button(
            onPressed: onRetry,
            child: Text(retryText ?? l10n.reportsRetry),
          ),
        ],
      ),
    );
  }
}
