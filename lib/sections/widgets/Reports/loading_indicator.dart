import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final double strokeWidth;
  final double? progressValue;
  final TextStyle? textStyle;

  const LoadingIndicator({
    super.key,
    required this.message,
    this.strokeWidth = 4.0,
    this.progressValue,
    this.textStyle,
  });

  static const _defaultTextStyle = TextStyle(fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProgressRing(
            activeColor: FluentTheme.of(context).accentColor,
            strokeWidth: strokeWidth,
            value: progressValue,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: textStyle ?? _defaultTextStyle,
            textAlign: TextAlign.center,
            semanticsLabel: message,
          ),
        ],
      ),
    );
  }
}

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
      message: AppLocalizations.of(context)!.loadingApplication,
      strokeWidth: 5.0,
    );
  }
}

class DataLoadingIndicator extends StatelessWidget {
  const DataLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
      message: AppLocalizations.of(context)!.loadingData,
      strokeWidth: 3.0,
    );
  }
}
