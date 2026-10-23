import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

/// Hours and minutes inputs that wrap onto a second line when the dialog is
/// narrow instead of overflowing.
class DurationFields extends StatelessWidget {
  final int hours;
  final int minutes;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;

  const DurationFields({
    super.key,
    required this.hours,
    required this.minutes,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  Widget _box(int value, int max, ValueChanged<int> onChanged, String unit) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 110,
            child: NumberBox<int>(
              value: value,
              min: 0,
              max: max,
              mode: SpinButtonPlacementMode.inline,
              onChanged: (v) => onChanged(v ?? 0),
            ),
          ),
          const SizedBox(width: 6),
          Text(unit),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _box(hours, 24, onHoursChanged, l10n.tlHours),
        _box(minutes, 59, onMinutesChanged, l10n.tlMinutes),
      ],
    );
  }
}
