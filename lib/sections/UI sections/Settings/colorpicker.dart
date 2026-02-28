import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAnimDuration = Duration(milliseconds: 150);
const _kMonoStyle = TextStyle(fontFamily: 'monospace');
final _kBorderRadius6 = BorderRadius.circular(6);
final _kBorderRadius8 = BorderRadius.circular(8);

Color _borderColor(bool isDark) => isDark
    ? Colors.white.withValues(alpha: 0.2)
    : Colors.black.withValues(alpha: 0.1);

// ============== FLUENT COLOR PICKER DIALOG ==============

class FluentColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const FluentColorPickerDialog({
    super.key,
    required this.title,
    required this.initialColor,
    required this.onColorSelected,
  });

  static Future<Color?> show({
    required BuildContext context,
    required String title,
    required Color initialColor,
  }) async {
    Color? selectedColor;
    await showDialog<void>(
      context: context,
      builder: (_) => FluentColorPickerDialog(
        title: title,
        initialColor: initialColor,
        onColorSelected: (color) => selectedColor = color,
      ),
    );
    return selectedColor;
  }

  @override
  State<FluentColorPickerDialog> createState() =>
      _FluentColorPickerDialogState();
}

class _FluentColorPickerDialogState extends State<FluentColorPickerDialog> {
  late Color _currentColor;
  late double _hue, _saturation, _value;
  late final TextEditingController _hexController;
  int _selectedTab = 0;

  static const _basicColors = [
    Color(0xFFFF0000),
    Color(0xFFFF4500),
    Color(0xFFFFA500),
    Color(0xFFFFD700),
    Color(0xFFFFFF00),
    Color(0xFF9ACD32),
    Color(0xFF32CD32),
    Color(0xFF00FA9A),
    Color(0xFF00FFFF),
    Color(0xFF1E90FF),
    Color(0xFF0000FF),
    Color(0xFF8A2BE2),
    Color(0xFFFF00FF),
    Color(0xFFFF1493),
    Color(0xFFFFFFFF),
    Color(0xFFC0C0C0),
    Color(0xFF808080),
    Color(0xFF404040),
    Color(0xFF000000),
    Color(0xFF8B4513),
  ];

  static const _extendedColors = [
    // Reds
    Color(0xFFFFCDD2), Color(0xFFEF9A9A), Color(0xFFE57373), Color(0xFFEF5350),
    Color(0xFFF44336), Color(0xFFE53935), Color(0xFFD32F2F), Color(0xFFC62828),
    // Pinks
    Color(0xFFF8BBD9), Color(0xFFF48FB1), Color(0xFFF06292), Color(0xFFEC407A),
    Color(0xFFE91E63), Color(0xFFD81B60), Color(0xFFC2185B), Color(0xFFAD1457),
    // Purples
    Color(0xFFE1BEE7), Color(0xFFCE93D8), Color(0xFFBA68C8), Color(0xFFAB47BC),
    Color(0xFF9C27B0), Color(0xFF8E24AA), Color(0xFF7B1FA2), Color(0xFF6A1B9A),
    // Blues
    Color(0xFFBBDEFB), Color(0xFF90CAF9), Color(0xFF64B5F6), Color(0xFF42A5F5),
    Color(0xFF2196F3), Color(0xFF1E88E5), Color(0xFF1976D2), Color(0xFF1565C0),
    // Cyans
    Color(0xFFB2EBF2), Color(0xFF80DEEA), Color(0xFF4DD0E1), Color(0xFF26C6DA),
    Color(0xFF00BCD4), Color(0xFF00ACC1), Color(0xFF0097A7), Color(0xFF00838F),
    // Greens
    Color(0xFFC8E6C9), Color(0xFFA5D6A7), Color(0xFF81C784), Color(0xFF66BB6A),
    Color(0xFF4CAF50), Color(0xFF43A047), Color(0xFF388E3C), Color(0xFF2E7D32),
    // Yellows
    Color(0xFFFFF9C4), Color(0xFFFFF59D), Color(0xFFFFF176), Color(0xFFFFEE58),
    Color(0xFFFFEB3B), Color(0xFFFDD835), Color(0xFFFBC02D), Color(0xFFF9A825),
    // Oranges
    Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFFFB74D), Color(0xFFFFA726),
    Color(0xFFFF9800), Color(0xFFFB8C00), Color(0xFFF57C00), Color(0xFFEF6C00),
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _syncHSVFromColor(_currentColor);
    _hexController = TextEditingController(text: _colorToHex(_currentColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  // ── Color conversion helpers ──────────────────────────────────────────────

  void _syncHSVFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _applyHSV() {
    setState(() {
      _currentColor =
          HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
      _hexController.text = _colorToHex(_currentColor);
    });
  }

  void _setColor(Color color) {
    setState(() {
      _currentColor = color;
      _syncHSVFromColor(color);
      _hexController.text = _colorToHex(color);
    });
  }

  static String _colorToHex(Color color) =>
      color.value.toRadixString(16).substring(2).toUpperCase();

  static Color? _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length != 6) return null;
    final value = int.tryParse('FF$hex', radix: 16);
    return value != null ? Color(value) : null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _borderColor(isDark)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabSelector(theme, l10n),
          const SizedBox(height: 16),
          Expanded(child: _buildTabContent(theme, isDark, l10n)),
          const SizedBox(height: 16),
          _buildHexInputRow(theme, isDark, l10n),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(l10n.select),
          onPressed: () {
            widget.onColorSelected(_currentColor);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildTabSelector(FluentThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        _TabChip(
          label: l10n.colorPickerSpectrum,
          icon: FluentIcons.color,
          isSelected: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        const SizedBox(width: 8),
        _TabChip(
          label: l10n.colorPickerPresets,
          icon: FluentIcons.grid_view_medium,
          isSelected: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        const SizedBox(width: 8),
        _TabChip(
          label: l10n.colorPickerSliders,
          icon: FluentIcons.slider,
          isSelected: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
      ],
    );
  }

  Widget _buildTabContent(
      FluentThemeData theme, bool isDark, AppLocalizations l10n) {
    return switch (_selectedTab) {
      0 => _buildSpectrumPicker(),
      1 => _buildPresetsPicker(isDark, l10n),
      2 => _buildSlidersPicker(l10n),
      _ => const SizedBox.shrink(),
    };
  }

  // ── Spectrum Tab ──────────────────────────────────────────────────────────

  Widget _buildSpectrumPicker() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: _kBorderRadius8,
            child: _SaturationValuePicker(
              hue: _hue,
              saturation: _saturation,
              value: _value,
              onChanged: (sat, val) {
                _saturation = sat;
                _value = val;
                _applyHSV();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _HueSlider(
          hue: _hue,
          onChanged: (hue) {
            _hue = hue;
            _applyHSV();
          },
        ),
      ],
    );
  }

  // ── Presets Tab ───────────────────────────────────────────────────────────

  Widget _buildPresetsPicker(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.colorPickerBasicColors),
          const SizedBox(height: 8),
          _ColorGrid(
            colors: _basicColors,
            selectedColor: _currentColor,
            isDark: isDark,
            onSelect: _setColor,
          ),
          const SizedBox(height: 16),
          _SectionLabel(l10n.colorPickerExtendedPalette),
          const SizedBox(height: 8),
          _ColorGrid(
            colors: _extendedColors,
            selectedColor: _currentColor,
            isDark: isDark,
            onSelect: _setColor,
          ),
        ],
      ),
    );
  }

  // ── Sliders Tab ───────────────────────────────────────────────────────────

  Widget _buildSlidersPicker(AppLocalizations l10n) {
    final r = _currentColor.red;
    final g = _currentColor.green;
    final b = _currentColor.blue;

    return SingleChildScrollView(
      child: Column(
        children: [
          _ColorSliderRow(
            label: l10n.colorPickerRed,
            value: r.toDouble(),
            max: 255,
            activeColor: Colors.red,
            onChanged: (v) => _setColor(Color.fromARGB(255, v.round(), g, b)),
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: l10n.colorPickerGreen,
            value: g.toDouble(),
            max: 255,
            activeColor: Colors.green,
            onChanged: (v) => _setColor(Color.fromARGB(255, r, v.round(), b)),
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: l10n.colorPickerBlue,
            value: b.toDouble(),
            max: 255,
            activeColor: Colors.blue,
            onChanged: (v) => _setColor(Color.fromARGB(255, r, g, v.round())),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _ColorSliderRow(
            label: l10n.colorPickerHue,
            value: _hue,
            max: 360,
            activeColor: HSVColor.fromAHSV(1, _hue, 1, 1).toColor(),
            onChanged: (v) {
              _hue = v;
              _applyHSV();
            },
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: l10n.colorPickerSaturation,
            value: _saturation * 100,
            max: 100,
            activeColor: _currentColor,
            onChanged: (v) {
              _saturation = v / 100;
              _applyHSV();
            },
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: l10n.colorPickerBrightness,
            value: _value * 100,
            max: 100,
            activeColor: _currentColor,
            onChanged: (v) {
              _value = v / 100;
              _applyHSV();
            },
          ),
        ],
      ),
    );
  }

  // ── Hex Input Row ─────────────────────────────────────────────────────────

  Widget _buildHexInputRow(
      FluentThemeData theme, bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: _kBorderRadius8,
            border: Border.all(color: _borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: _currentColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.colorPickerHexColor,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    '#',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextBox(
                      controller: _hexController,
                      placeholder: l10n.colorPickerHexPlaceholder,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 14),
                      maxLength: 6,
                      onChanged: (value) {
                        final color = _hexToColor(value);
                        if (color != null) {
                          setState(() {
                            _currentColor = color;
                            _syncHSVFromColor(color);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.colorPickerRGB,
              style: TextStyle(
                fontSize: 10,
                color: theme.typography.caption?.color,
              ),
            ),
            Text(
              '${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color Grid (extracted from inline builder)
// ─────────────────────────────────────────────────────────────────────────────

class _ColorGrid extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final bool isDark;
  final ValueChanged<Color> onSelect;

  const _ColorGrid({
    required this.colors,
    required this.selectedColor,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final color in colors)
          _ColorSwatch(
            color: color,
            isSelected: selectedColor.value == color.value,
            isDark: isDark,
            onTap: () => onSelect(color),
          ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _kAnimDuration,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: _kBorderRadius6,
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                FluentIcons.check_mark,
                size: 14,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Chip
// ─────────────────────────────────────────────────────────────────────────────

class _TabChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final selected = widget.isSelected;
    final accent = theme.accentColor;
    final inactiveBg = theme.inactiveBackgroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : inactiveBg.withValues(alpha: _isHovered ? 0.5 : 0.2),
            borderRadius: _kBorderRadius6,
            border: Border.all(
              color: selected ? accent : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: selected ? accent : null),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? accent : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saturation/Value Picker
// ─────────────────────────────────────────────────────────────────────────────

class _SaturationValuePicker extends StatelessWidget {
  final double hue, saturation, value;
  final void Function(double saturation, double value) onChanged;

  const _SaturationValuePicker({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  void _handle(Offset local, Size size) {
    onChanged(
      (local.dx / size.width).clamp(0.0, 1.0),
      1.0 - (local.dy / size.height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (d) => _handle(d.localPosition, size),
          onPanUpdate: (d) => _handle(d.localPosition, size),
          onTapDown: (d) => _handle(d.localPosition, size),
          child: CustomPaint(
            size: size,
            painter:
                _SatValPainter(hue: hue, saturation: saturation, value: value),
          ),
        );
      },
    );
  }
}

class _SatValPainter extends CustomPainter {
  final double hue, saturation, value;

  const _SatValPainter({
    required this.hue,
    required this.saturation,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Saturation gradient (white → hue)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(colors: [
          Colors.white,
          HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
        ]).createShader(rect),
    );

    // Value gradient (transparent → black)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );

    // Indicator
    final center = Offset(saturation * size.width, (1 - value) * size.height);
    final currentColor = HSVColor.fromAHSV(1, hue, saturation, value).toColor();

    canvas.drawCircle(
        center,
        12,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawCircle(
        center,
        10,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.drawCircle(center, 8, Paint()..color = currentColor);
  }

  @override
  bool shouldRepaint(covariant _SatValPainter old) =>
      hue != old.hue || saturation != old.saturation || value != old.value;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hue Slider
// ─────────────────────────────────────────────────────────────────────────────

class _HueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HueSlider({required this.hue, required this.onChanged});

  void _handle(Offset local, double width) {
    onChanged((local.dx / width * 360).clamp(0.0, 360.0));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            onPanStart: (d) => _handle(d.localPosition, width),
            onPanUpdate: (d) => _handle(d.localPosition, width),
            onTapDown: (d) => _handle(d.localPosition, width),
            child: CustomPaint(
              size: Size(width, 24),
              painter: _HuePainter(hue: hue),
            ),
          );
        },
      ),
    );
  }
}

class _HuePainter extends CustomPainter {
  final double hue;
  const _HuePainter({required this.hue});

  // Pre-generate hue stops once — they never change
  static final _hueColors = List.generate(
    7,
    (i) => HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor(),
  );
  static final _hueGradient = LinearGradient(colors: _hueColors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    canvas.drawRRect(rrect, Paint()..shader = _hueGradient.createShader(rect));

    // Indicator
    final center = Offset((hue / 360) * size.width, size.height / 2);
    final indicatorColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();

    canvas.drawCircle(
        center,
        10,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawCircle(
        center,
        8,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.drawCircle(center, 6, Paint()..color = indicatorColor);
  }

  @override
  bool shouldRepaint(covariant _HuePainter old) => hue != old.hue;
}

// ─────────────────────────────────────────────────────────────────────────────
// Color Slider Row
// ─────────────────────────────────────────────────────────────────────────────

class _ColorSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _ColorSliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(0, max),
            min: 0,
            max: max,
            onChanged: onChanged,
            style: SliderThemeData(
              activeColor: WidgetStateProperty.all(activeColor),
              inactiveColor:
                  WidgetStateProperty.all(activeColor.withValues(alpha: 0.2)),
              thumbColor: WidgetStateProperty.all(activeColor),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.round().toString(),
            style: _kMonoStyle.copyWith(fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
