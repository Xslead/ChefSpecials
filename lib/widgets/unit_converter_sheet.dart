import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/unit_converter.dart';

enum _Category { weight, volume, temperature }

class UnitConverterSheet extends StatefulWidget {
  final double? initialValue;
  final String? initialUnit;

  const UnitConverterSheet({super.key, this.initialValue, this.initialUnit});

  static Future<void> show(
    BuildContext context, {
    double? initialValue,
    String? initialUnit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UnitConverterSheet(
        initialValue: initialValue,
        initialUnit: initialUnit,
      ),
    );
  }

  @override
  State<UnitConverterSheet> createState() => _UnitConverterSheetState();
}

class _UnitConverterSheetState extends State<UnitConverterSheet> {
  late _Category _category;
  late TextEditingController _inputController;

  WeightUnit _fromWeight = WeightUnit.g;
  WeightUnit _toWeight = WeightUnit.kg;
  VolumeUnit _fromVolume = VolumeUnit.mL;
  VolumeUnit _toVolume = VolumeUnit.L;
  TempUnit _fromTemp = TempUnit.celsius;
  TempUnit _toTemp = TempUnit.fahrenheit;

  @override
  void initState() {
    super.initState();
    _category = _detectCategory(widget.initialUnit);
    _inputController = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
    _prefillUnits(widget.initialUnit);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  _Category _detectCategory(String? unit) {
    if (unit == null) return _Category.weight;
    final lower = unit.toLowerCase();
    const volumeUnits = ['ml', 'l', 'cups', 'cup', 'tbsp', 'tsp', 'fl oz', 'floz'];
    const tempUnits = ['°c', '°f', 'c', 'f', 'celsius', 'fahrenheit'];
    if (volumeUnits.contains(lower)) return _Category.volume;
    if (tempUnits.contains(lower)) return _Category.temperature;
    return _Category.weight;
  }

  void _prefillUnits(String? unit) {
    if (unit == null) return;
    final lower = unit.toLowerCase();

    switch (_category) {
      case _Category.weight:
        for (final w in WeightUnit.values) {
          if (UnitConverter.weightUnitLabel(w).toLowerCase() == lower) {
            _fromWeight = w;
            _toWeight = w == WeightUnit.g ? WeightUnit.kg : WeightUnit.g;
            break;
          }
        }
      case _Category.volume:
        for (final v in VolumeUnit.values) {
          if (UnitConverter.volumeUnitLabel(v).toLowerCase() == lower) {
            _fromVolume = v;
            _toVolume = v == VolumeUnit.mL ? VolumeUnit.L : VolumeUnit.mL;
            break;
          }
        }
      case _Category.temperature:
        if (lower.contains('f')) {
          _fromTemp = TempUnit.fahrenheit;
          _toTemp = TempUnit.celsius;
        }
    }
  }

  String _computeResult() {
    final input = double.tryParse(_inputController.text);
    if (input == null) return '—';

    double result;
    String unit;
    switch (_category) {
      case _Category.weight:
        result = UnitConverter.convertWeight(input, _fromWeight, _toWeight);
        unit = UnitConverter.weightUnitLabel(_toWeight);
      case _Category.volume:
        result = UnitConverter.convertVolume(input, _fromVolume, _toVolume);
        unit = UnitConverter.volumeUnitLabel(_toVolume);
      case _Category.temperature:
        result = UnitConverter.convertTemperature(input, _fromTemp, _toTemp);
        unit = UnitConverter.tempUnitLabel(_toTemp);
    }

    return UnitConverter.smartFormat(result, unit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutralLightOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.unitConverter,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SegmentedButton<_Category>(
            segments: [
              ButtonSegment(value: _Category.weight, label: Text(l10n.weight)),
              ButtonSegment(value: _Category.volume, label: Text(l10n.volume)),
              ButtonSegment(
                  value: _Category.temperature, label: Text(l10n.temperature)),
            ],
            selected: {_category},
            onSelectionChanged: (s) => setState(() => _category = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.quantity,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildFromDropdown(l10n)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward,
                    color: AppTheme.textSecondaryOf(context)),
              ),
              Expanded(child: _buildToDropdown(l10n)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.result,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _computeResult(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final result = _computeResult();
                    if (result != '—') {
                      Clipboard.setData(ClipboardData(text: result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copied)),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  tooltip: l10n.copied,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFromDropdown(AppLocalizations l10n) {
    switch (_category) {
      case _Category.weight:
        return _dropdown<WeightUnit>(
          label: l10n.fromUnit,
          value: _fromWeight,
          items: WeightUnit.values,
          labelFn: UnitConverter.weightUnitLabel,
          onChanged: (v) => setState(() => _fromWeight = v!),
        );
      case _Category.volume:
        return _dropdown<VolumeUnit>(
          label: l10n.fromUnit,
          value: _fromVolume,
          items: VolumeUnit.values,
          labelFn: UnitConverter.volumeUnitLabel,
          onChanged: (v) => setState(() => _fromVolume = v!),
        );
      case _Category.temperature:
        return _dropdown<TempUnit>(
          label: l10n.fromUnit,
          value: _fromTemp,
          items: TempUnit.values,
          labelFn: UnitConverter.tempUnitLabel,
          onChanged: (v) => setState(() => _fromTemp = v!),
        );
    }
  }

  Widget _buildToDropdown(AppLocalizations l10n) {
    switch (_category) {
      case _Category.weight:
        return _dropdown<WeightUnit>(
          label: l10n.toUnit,
          value: _toWeight,
          items: WeightUnit.values,
          labelFn: UnitConverter.weightUnitLabel,
          onChanged: (v) => setState(() => _toWeight = v!),
        );
      case _Category.volume:
        return _dropdown<VolumeUnit>(
          label: l10n.toUnit,
          value: _toVolume,
          items: VolumeUnit.values,
          labelFn: UnitConverter.volumeUnitLabel,
          onChanged: (v) => setState(() => _toVolume = v!),
        );
      case _Category.temperature:
        return _dropdown<TempUnit>(
          label: l10n.toUnit,
          value: _toTemp,
          items: TempUnit.values,
          labelFn: UnitConverter.tempUnitLabel,
          onChanged: (v) => setState(() => _toTemp = v!),
        );
    }
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelFn,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(labelFn(e))))
          .toList(),
      onChanged: onChanged,
    );
  }
}
